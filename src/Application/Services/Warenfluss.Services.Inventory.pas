unit Warenfluss.Services.Inventory;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
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
  TInventoryService = class(TInterfacedObject, IInventoryService)
  private
    FStockRepo: IStockRepository;
    FProductRepo: IProductRepository;
    FWarehouseRepo: IWarehouseRepository;
    FUnitOfWork: IUnitOfWork;
    FAuditService: IAuditService;
    function ItemToDTO(AItem: TStockItem): TStockItemDTO;
  public
    constructor Create(AStockRepo: IStockRepository; AProductRepo: IProductRepository;
      AWarehouseRepo: IWarehouseRepository; AUnitOfWork: IUnitOfWork; AAuditService: IAuditService);

    function GetStockByWarehouse(AWarehouseID: TEntityID): TArray<TStockItemDTO>;
    function GetStockByProduct(AProductID: TEntityID): TArray<TStockItemDTO>;
    function GetAllStockItems: TArray<TStockItemDTO>;
    function GetAvailableStock(AProductID, AWarehouseID: TEntityID): Double;
    function AdjustStock(const ADTO: TStockAdjustmentDTO; AUserID: TEntityID): TOperationResult;
    function GetMovementHistory(AProductID: TEntityID = 0; ALimit: Integer = 200): TArray<TStockMovementDTO>;
  end;

implementation

constructor TInventoryService.Create(AStockRepo: IStockRepository; AProductRepo: IProductRepository;
  AWarehouseRepo: IWarehouseRepository; AUnitOfWork: IUnitOfWork; AAuditService: IAuditService);
begin
  inherited Create;
  FStockRepo := AStockRepo;
  FProductRepo := AProductRepo;
  FWarehouseRepo := AWarehouseRepo;
  FUnitOfWork := AUnitOfWork;
  FAuditService := AAuditService;
end;

function TInventoryService.ItemToDTO(AItem: TStockItem): TStockItemDTO;
var
  Prod: TProduct;
  WH: TWarehouse;
begin
  if AItem = nil then Exit;
  Result.ID := AItem.ID;
  Result.ProductID := AItem.ProductID;
  Result.WarehouseID := AItem.WarehouseID;
  Result.Quantity := AItem.Quantity;
  Result.ReservedQuantity := AItem.ReservedQuantity;
  Result.AvailableQuantity := AItem.AvailableQuantity;
  Result.ProductSKU := '';
  Result.ProductName := '';
  Result.WarehouseCode := '';
  Result.WarehouseName := '';
  Result.UnitCost := 0;
  Result.TotalValue := 0;

  if (AItem.ProductID > 0) and Assigned(FProductRepo) then
  begin
    Prod := FProductRepo.GetByID(AItem.ProductID);
    if Prod <> nil then
    begin
      Result.ProductSKU := Prod.SKU;
      Result.ProductName := Prod.Name;
      Result.UnitCost := Prod.CostPrice;
      Result.TotalValue := AItem.Quantity * Prod.CostPrice;
    end;
  end;

  if (AItem.WarehouseID > 0) and Assigned(FWarehouseRepo) then
  begin
    WH := FWarehouseRepo.GetByID(AItem.WarehouseID);
    if WH <> nil then
    begin
      Result.WarehouseCode := WH.Code;
      Result.WarehouseName := WH.Name;
    end;
  end;
end;

function TInventoryService.GetStockByWarehouse(AWarehouseID: TEntityID): TArray<TStockItemDTO>;
var
  List: TObjectList<TStockItem>;
  I: Integer;
begin
  List := FStockRepo.GetStockByWarehouse(AWarehouseID);
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
      Result[I] := ItemToDTO(List[I]);
  finally
    List.Free;
  end;
end;

function TInventoryService.GetStockByProduct(AProductID: TEntityID): TArray<TStockItemDTO>;
var
  List: TObjectList<TStockItem>;
  I: Integer;
begin
  List := FStockRepo.GetStockByProduct(AProductID);
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
      Result[I] := ItemToDTO(List[I]);
  finally
    List.Free;
  end;
end;

function TInventoryService.GetAllStockItems: TArray<TStockItemDTO>;
var
  List: TObjectList<TStockItem>;
  I: Integer;
begin
  List := FStockRepo.GetAllStockItems;
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
      Result[I] := ItemToDTO(List[I]);
  finally
    List.Free;
  end;
end;

function TInventoryService.GetAvailableStock(AProductID, AWarehouseID: TEntityID): Double;
var
  Item: TStockItem;
begin
  Item := FStockRepo.GetStockItem(AProductID, AWarehouseID);
  if Item <> nil then
    Result := Item.AvailableQuantity
  else
    Result := 0;
end;

function TInventoryService.AdjustStock(const ADTO: TStockAdjustmentDTO; AUserID: TEntityID): TOperationResult;
var
  Prod: TProduct;
  StockItem: TStockItem;
  Movement: TStockMovement;
  PrevQty, NewQty: Double;
  MoveType: TMovementType;
begin
  TStockValidator.ValidateAdjustment(ADTO.ProductID, ADTO.WarehouseID, ADTO.AdjustmentQuantity, ADTO.Reason);

  Prod := FProductRepo.GetByID(ADTO.ProductID);
  if Prod = nil then
    raise EEntityNotFoundException.Create('Product', IntToStr(ADTO.ProductID));

  if Assigned(FUnitOfWork) then FUnitOfWork.BeginTransaction;
  try
    StockItem := FStockRepo.GetStockItem(ADTO.ProductID, ADTO.WarehouseID);
    if StockItem = nil then
    begin
      StockItem := TStockItem.Create;
      StockItem.ProductID := ADTO.ProductID;
      StockItem.WarehouseID := ADTO.WarehouseID;
      StockItem.Quantity := 0;
      StockItem.ReservedQuantity := 0;
    end;

    PrevQty := StockItem.Quantity;
    NewQty := PrevQty + ADTO.AdjustmentQuantity;

    if NewQty < 0 then
      raise EInsufficientStockException.Create(ADTO.ProductID, ADTO.WarehouseID,
        Abs(ADTO.AdjustmentQuantity), PrevQty,
        Format('Stock adjustment would result in negative inventory (%.2f).', [NewQty]));

    StockItem.Quantity := NewQty;
    FStockRepo.SaveStockItem(StockItem);

    // Update Product Total Stock
    Prod.CurrentStockTotal := Prod.CurrentStockTotal + ADTO.AdjustmentQuantity;
    if Prod.CurrentStockTotal < 0 then Prod.CurrentStockTotal := 0;
    Prod.UpdatedAt := Now;
    FProductRepo.Save(Prod);

    // Create Stock Movement record
    if ADTO.AdjustmentQuantity >= 0 then
      MoveType := smtAdjustmentPlus
    else
      MoveType := smtAdjustmentMinus;

    Movement := TStockMovement.Create;
    try
      Movement.MovementType := MoveType;
      Movement.ProductID := ADTO.ProductID;
      Movement.WarehouseID := ADTO.WarehouseID;
      Movement.Quantity := Abs(ADTO.AdjustmentQuantity);
      Movement.ReferenceType := 'ADJUSTMENT';
      Movement.ReferenceID := 0;
      Movement.UnitCost := Prod.CostPrice;
      Movement.Reason := ADTO.Reason;
      Movement.UserID := AUserID;
      Movement.Timestamp := Now;
      FStockRepo.AddStockMovement(Movement);
    finally
      Movement.Free;
    end;

    if Assigned(FUnitOfWork) then FUnitOfWork.Commit;

    // Audit and Domain Event
    if Assigned(FAuditService) then
      FAuditService.LogAction(AUserID, 'User', 'STOCK_ADJUSTED', 'Product', ADTO.ProductID,
        Format('Adjusted stock in WH %d by %.2f: %s', [ADTO.WarehouseID, ADTO.AdjustmentQuantity, ADTO.Reason]), '127.0.0.1');

    TDomainEventBus.Instance.Publish(TStockAdjustedEvent.Create(ADTO.ProductID, ADTO.WarehouseID,
      PrevQty, NewQty, ADTO.AdjustmentQuantity, ADTO.Reason, AUserID));

    Result := TOperationResult.Ok('Stock adjusted successfully.', ADTO.ProductID);
  except
    on E: Exception do
    begin
      if Assigned(FUnitOfWork) and FUnitOfWork.InTransaction then
        FUnitOfWork.Rollback;
      raise;
    end;
  end;
end;

function TInventoryService.GetMovementHistory(AProductID: TEntityID; ALimit: Integer): TArray<TStockMovementDTO>;
var
  List: TObjectList<TStockMovement>;
  I: Integer;
  Prod: TProduct;
  WH, TgtWH: TWarehouse;
begin
  if AProductID > 0 then
    List := FStockRepo.GetMovementsByProduct(AProductID, ALimit)
  else
    List := FStockRepo.GetAllMovements(ALimit);

  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
    begin
      Result[I].ID := List[I].ID;
      Result[I].MovementType := List[I].MovementType;
      Result[I].MovementTypeName := MovementTypeToString(List[I].MovementType);
      Result[I].ProductID := List[I].ProductID;
      Result[I].WarehouseID := List[I].WarehouseID;
      Result[I].TargetWarehouseID := List[I].TargetWarehouseID;
      Result[I].Quantity := List[I].Quantity;
      Result[I].ReferenceType := List[I].ReferenceType;
      Result[I].ReferenceID := List[I].ReferenceID;
      Result[I].UnitCost := List[I].UnitCost;
      Result[I].Reason := List[I].Reason;
      Result[I].UserID := List[I].UserID;
      Result[I].Timestamp := List[I].Timestamp;

      Result[I].ProductSKU := '';
      Result[I].ProductName := '';
      Result[I].WarehouseName := '';
      Result[I].TargetWarehouseName := '';
      Result[I].Username := 'User #' + IntToStr(List[I].UserID);

      if Assigned(FProductRepo) and (List[I].ProductID > 0) then
      begin
        Prod := FProductRepo.GetByID(List[I].ProductID);
        if Prod <> nil then
        begin
          Result[I].ProductSKU := Prod.SKU;
          Result[I].ProductName := Prod.Name;
        end;
      end;

      if Assigned(FWarehouseRepo) then
      begin
        if List[I].WarehouseID > 0 then
        begin
          WH := FWarehouseRepo.GetByID(List[I].WarehouseID);
          if WH <> nil then Result[I].WarehouseName := WH.Name;
        end;
        if List[I].TargetWarehouseID > 0 then
        begin
          TgtWH := FWarehouseRepo.GetByID(List[I].TargetWarehouseID);
          if TgtWH <> nil then Result[I].TargetWarehouseName := TgtWH.Name;
        end;
      end;
    end;
  finally
    List.Free;
  end;
end;

end.
