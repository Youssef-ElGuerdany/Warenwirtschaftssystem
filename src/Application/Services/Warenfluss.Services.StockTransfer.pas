unit Warenfluss.Services.StockTransfer;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Events,
  Warenfluss.Domain.Product,
  Warenfluss.Domain.Warehouse,
  Warenfluss.Domain.StockMovement,
  Warenfluss.Domain.StockValidator,
  Warenfluss.DTOs.Inventory,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TStockTransferService = class(TInterfacedObject, IStockTransferService)
  private
    FStockRepo: IStockRepository;
    FProductRepo: IProductRepository;
    FWarehouseRepo: IWarehouseRepository;
    FUnitOfWork: IUnitOfWork;
    FAuditService: IAuditService;
  public
    constructor Create(AStockRepo: IStockRepository; AProductRepo: IProductRepository;
      AWarehouseRepo: IWarehouseRepository; AUnitOfWork: IUnitOfWork; AAuditService: IAuditService);

    function TransferStock(const ADTO: TStockTransferDTO; AUserID: TEntityID): TOperationResult;
  end;

implementation

constructor TStockTransferService.Create(AStockRepo: IStockRepository; AProductRepo: IProductRepository;
  AWarehouseRepo: IWarehouseRepository; AUnitOfWork: IUnitOfWork; AAuditService: IAuditService);
begin
  inherited Create;
  FStockRepo := AStockRepo;
  FProductRepo := AProductRepo;
  FWarehouseRepo := AWarehouseRepo;
  FUnitOfWork := AUnitOfWork;
  FAuditService := AAuditService;
end;

function TStockTransferService.TransferStock(const ADTO: TStockTransferDTO; AUserID: TEntityID): TOperationResult;
var
  Prod: TProduct;
  SrcWH, TgtWH: TWarehouse;
  SrcItem, TgtItem: TStockItem;
  AvailQty: Double;
  MoveOut, MoveIn: TStockMovement;
begin
  Prod := FProductRepo.GetByID(ADTO.ProductID);
  if Prod = nil then
    raise EEntityNotFoundException.Create('Product', IntToStr(ADTO.ProductID));

  SrcWH := FWarehouseRepo.GetByID(ADTO.SourceWarehouseID);
  if SrcWH = nil then
    raise EEntityNotFoundException.Create('Warehouse (Source)', IntToStr(ADTO.SourceWarehouseID));

  TgtWH := FWarehouseRepo.GetByID(ADTO.TargetWarehouseID);
  if TgtWH = nil then
    raise EEntityNotFoundException.Create('Warehouse (Target)', IntToStr(ADTO.TargetWarehouseID));

  SrcItem := FStockRepo.GetStockItem(ADTO.ProductID, ADTO.SourceWarehouseID);
  if SrcItem <> nil then
    AvailQty := SrcItem.AvailableQuantity
  else
    AvailQty := 0;

  TStockValidator.ValidateTransfer(ADTO.ProductID, ADTO.SourceWarehouseID, ADTO.TargetWarehouseID,
    ADTO.Quantity, AvailQty);

  if Assigned(FUnitOfWork) then FUnitOfWork.BeginTransaction;
  try
    // Debit source
    SrcItem.Quantity := SrcItem.Quantity - ADTO.Quantity;
    FStockRepo.SaveStockItem(SrcItem);

    // Credit target
    TgtItem := FStockRepo.GetStockItem(ADTO.ProductID, ADTO.TargetWarehouseID);
    if TgtItem = nil then
    begin
      TgtItem := TStockItem.Create;
      TgtItem.ProductID := ADTO.ProductID;
      TgtItem.WarehouseID := ADTO.TargetWarehouseID;
      TgtItem.Quantity := 0;
      TgtItem.ReservedQuantity := 0;
    end;
    TgtItem.Quantity := TgtItem.Quantity + ADTO.Quantity;
    FStockRepo.SaveStockItem(TgtItem);

    // Create Outgoing Movement
    MoveOut := TStockMovement.Create;
    try
      MoveOut.MovementType := smtTransferOut;
      MoveOut.ProductID := ADTO.ProductID;
      MoveOut.WarehouseID := ADTO.SourceWarehouseID;
      MoveOut.TargetWarehouseID := ADTO.TargetWarehouseID;
      MoveOut.Quantity := ADTO.Quantity;
      MoveOut.ReferenceType := 'TRANSFER';
      MoveOut.ReferenceID := 0;
      MoveOut.UnitCost := Prod.CostPrice;
      MoveOut.Reason := ADTO.Reason;
      MoveOut.UserID := AUserID;
      MoveOut.Timestamp := Now;
      FStockRepo.AddStockMovement(MoveOut);
    finally
      MoveOut.Free;
    end;

    // Create Incoming Movement
    MoveIn := TStockMovement.Create;
    try
      MoveIn.MovementType := smtTransferIn;
      MoveIn.ProductID := ADTO.ProductID;
      MoveIn.WarehouseID := ADTO.TargetWarehouseID;
      MoveIn.TargetWarehouseID := ADTO.SourceWarehouseID;
      MoveIn.Quantity := ADTO.Quantity;
      MoveIn.ReferenceType := 'TRANSFER';
      MoveIn.ReferenceID := 0;
      MoveIn.UnitCost := Prod.CostPrice;
      MoveIn.Reason := ADTO.Reason;
      MoveIn.UserID := AUserID;
      MoveIn.Timestamp := Now;
      FStockRepo.AddStockMovement(MoveIn);
    finally
      MoveIn.Free;
    end;

    if Assigned(FUnitOfWork) then FUnitOfWork.Commit;

    // Audit and Domain Event
    if Assigned(FAuditService) then
      FAuditService.LogAction(AUserID, 'User', 'STOCK_TRANSFERRED', 'Product', ADTO.ProductID,
        Format('Transferred %.2f of %s from WH %s to WH %s', [ADTO.Quantity, Prod.SKU, SrcWH.Name, TgtWH.Name]), '127.0.0.1');

    TDomainEventBus.Instance.Publish(TStockTransferredEvent.Create(ADTO.ProductID, ADTO.SourceWarehouseID,
      ADTO.TargetWarehouseID, ADTO.Quantity, AUserID));

    Result := TOperationResult.Ok('Stock transferred successfully.', ADTO.ProductID);
  except
    on E: Exception do
    begin
      if Assigned(FUnitOfWork) and FUnitOfWork.InTransaction then
        FUnitOfWork.Rollback;
      raise;
    end;
  end;
end;

end.
