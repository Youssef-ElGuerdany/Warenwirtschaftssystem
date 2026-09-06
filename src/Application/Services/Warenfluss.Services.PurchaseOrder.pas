unit Warenfluss.Services.PurchaseOrder;

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
  Warenfluss.Domain.Supplier,
  Warenfluss.Domain.Warehouse,
  Warenfluss.Domain.PurchaseOrder,
  Warenfluss.Domain.StockMovement,
  Warenfluss.Domain.OrderValidatoR,
  Warenfluss.DTOs.Order,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TPurchaseOrderService = class(TInterfacedObject, IPurchaseOrderService)
  private
    FOrderRepo: IPurchaseOrderRepository;
    FProductRepo: IProductRepository;
    FSupplierRepo: ISupplierRepository;
    FWarehouseRepo: IWarehouseRepository;
    FStockRepo: IStockRepository;
    FUnitOfWork: IUnitOfWork;
    FAuditService: IAuditService;
    function EntityToDTO(AOrder: TPurchaseOrder): TPurchaseOrderDTO;
  public
    constructor Create(AOrderRepo: IPurchaseOrderRepository; AProductRepo: IProductRepository;
      ASupplierRepo: ISupplierRepository; AWarehouseRepo: IWarehouseRepository;
      AStockRepo: IStockRepository; AUnitOfWork: IUnitOfWork; AAuditService: IAuditService);

    function GetAllOrders: TArray<TPurchaseOrderDTO>;
    function GetOrderByID(AID: TEntityID): TPurchaseOrderDTO;
    function CreateOrder(const ADTO: TPurchaseOrderCreateDTO; AUserID: TEntityID): TOperationResult;
    function ApproveOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
    function ReceiveGoods(AID: TEntityID; AUserID: TEntityID): TOperationResult;
    function CancelOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
  end;

implementation

constructor TPurchaseOrderService.Create(AOrderRepo: IPurchaseOrderRepository; AProductRepo: IProductRepository;
  ASupplierRepo: ISupplierRepository; AWarehouseRepo: IWarehouseRepository;
  AStockRepo: IStockRepository; AUnitOfWork: IUnitOfWork; AAuditService: IAuditService);
begin
  inherited Create;
  FOrderRepo := AOrderRepo;
  FProductRepo := AProductRepo;
  FSupplierRepo := ASupplierRepo;
  FWarehouseRepo := AWarehouseRepo;
  FStockRepo := AStockRepo;
  FUnitOfWork := AUnitOfWork;
  FAuditService := AAuditService;
end;

function TPurchaseOrderService.EntityToDTO(AOrder: TPurchaseOrder): TPurchaseOrderDTO;
var
  I: Integer;
  Supp: TSupplier;
  WH: TWarehouse;
  Prod: TProduct;
begin
  if AOrder = nil then Exit;
  Result.ID := AOrder.ID;
  Result.OrderNumber := AOrder.OrderNumber;
  Result.SupplierID := AOrder.SupplierID;
  Result.SupplierName := '';
  Result.WarehouseID := AOrder.WarehouseID;
  Result.WarehouseName := '';
  Result.OrderDate := AOrder.OrderDate;
  Result.ExpectedDeliveryDate := AOrder.ExpectedDeliveryDate;
  Result.Status := AOrder.Status;
  Result.StatusName := PurchaseStatusToString(AOrder.Status);
  Result.TotalAmount := AOrder.TotalAmount;
  Result.Notes := AOrder.Notes;
  Result.CreatedByUserID := AOrder.CreatedByUserID;
  Result.CreatedByUsername := 'User #' + IntToStr(AOrder.CreatedByUserID);

  if (AOrder.SupplierID > 0) and Assigned(FSupplierRepo) then
  begin
    Supp := FSupplierRepo.GetByID(AOrder.SupplierID);
    if Supp <> nil then Result.SupplierName := Supp.CompanyName;
  end;

  if (AOrder.WarehouseID > 0) and Assigned(FWarehouseRepo) then
  begin
    WH := FWarehouseRepo.GetByID(AOrder.WarehouseID);
    if WH <> nil then Result.WarehouseName := WH.Name;
  end;

  SetLength(Result.Lines, AOrder.Lines.Count);
  for I := 0 to AOrder.Lines.Count - 1 do
  begin
    Result.Lines[I].ID := AOrder.Lines[I].ID;
    Result.Lines[I].PurchaseOrderID := AOrder.Lines[I].PurchaseOrderID;
    Result.Lines[I].ProductID := AOrder.Lines[I].ProductID;
    Result.Lines[I].OrderedQuantity := AOrder.Lines[I].OrderedQuantity;
    Result.Lines[I].ReceivedQuantity := AOrder.Lines[I].ReceivedQuantity;
    Result.Lines[I].UnitCost := AOrder.Lines[I].UnitCost;
    Result.Lines[I].LineTotal := AOrder.Lines[I].LineTotal;
    Result.Lines[I].ProductSKU := '';
    Result.Lines[I].ProductName := '';

    if Assigned(FProductRepo) and (AOrder.Lines[I].ProductID > 0) then
    begin
      Prod := FProductRepo.GetByID(AOrder.Lines[I].ProductID);
      if Prod <> nil then
      begin
        Result.Lines[I].ProductSKU := Prod.SKU;
        Result.Lines[I].ProductName := Prod.Name;
      end;
    end;
  end;
end;

function TPurchaseOrderService.GetAllOrders: TArray<TPurchaseOrderDTO>;
var
  List: TObjectList<TPurchaseOrder>;
  I: Integer;
begin
  List := FOrderRepo.GetAll;
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
      Result[I] := EntityToDTO(List[I]);
  finally
    List.Free;
  end;
end;

function TPurchaseOrderService.GetOrderByID(AID: TEntityID): TPurchaseOrderDTO;
var
  Order: TPurchaseOrder;
begin
  Order := FOrderRepo.GetByID(AID);
  if Order = nil then
    raise EEntityNotFoundException.Create('PurchaseOrder', IntToStr(AID));
  Result := EntityToDTO(Order);
end;

function TPurchaseOrderService.CreateOrder(const ADTO: TPurchaseOrderCreateDTO; AUserID: TEntityID): TOperationResult;
var
  Order: TPurchaseOrder;
  Line: TPurchaseOrderLine;
  I: Integer;
  NewID: TEntityID;
begin
  Order := TPurchaseOrder.Create;
  try
    Order.OrderNumber := FOrderRepo.GenerateNextOrderNumber;
    Order.SupplierID := ADTO.SupplierID;
    Order.WarehouseID := ADTO.WarehouseID;
    Order.ExpectedDeliveryDate := ADTO.ExpectedDeliveryDate;
    Order.Notes := ADTO.Notes;
    Order.CreatedByUserID := AUserID;
    Order.Status := posDraft;

    for I := 0 to Length(ADTO.Lines) - 1 do
    begin
      Line := TPurchaseOrderLine.Create;
      Line.ProductID := ADTO.Lines[I].ProductID;
      Line.OrderedQuantity := ADTO.Lines[I].OrderedQuantity;
      Line.UnitCost := ADTO.Lines[I].UnitCost;
      Line.Recalculate;
      Order.Lines.Add(Line);
    end;

    Order.RecalculateTotal;
    TOrderValidator.ValidatePurchaseOrder(Order);

    NewID := FOrderRepo.Save(Order);

    if Assigned(FAuditService) then
      FAuditService.LogAction(AUserID, 'User', 'PURCHASE_ORDER_CREATED', 'PurchaseOrder', NewID,
        'Created purchase order ' + Order.OrderNumber, '127.0.0.1');

    Result := TOperationResult.Ok('Purchase order created successfully.', NewID);
  except
    Order.Free;
    raise;
  end;
end;

function TPurchaseOrderService.ApproveOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
var
  Order: TPurchaseOrder;
begin
  Order := FOrderRepo.GetByID(AID);
  if Order = nil then
    raise EEntityNotFoundException.Create('PurchaseOrder', IntToStr(AID));

  if Order.Status <> posDraft then
    raise EInvalidOrderStatusException.Create('Only draft purchase orders can be approved.');

  Order.Status := posApproved;
  FOrderRepo.Save(Order);

  if Assigned(FAuditService) then
    FAuditService.LogAction(AUserID, 'User', 'PURCHASE_ORDER_APPROVED', 'PurchaseOrder', AID,
      'Approved purchase order ' + Order.OrderNumber, '127.0.0.1');

  Result := TOperationResult.Ok('Purchase order approved.', AID);
end;

function TPurchaseOrderService.ReceiveGoods(AID: TEntityID; AUserID: TEntityID): TOperationResult;
var
  Order: TPurchaseOrder;
  Line: TPurchaseOrderLine;
  Prod: TProduct;
  StockItem: TStockItem;
  Movement: TStockMovement;
  I: Integer;
begin
  Order := FOrderRepo.GetByID(AID);
  if Order = nil then
    raise EEntityNotFoundException.Create('PurchaseOrder', IntToStr(AID));

  if (Order.Status <> posApproved) and (Order.Status <> posPartiallyReceived) then
    raise EInvalidOrderStatusException.Create('Only approved or partially received purchase orders can receive goods.');

  if Assigned(FUnitOfWork) then FUnitOfWork.BeginTransaction;
  try
    for I := 0 to Order.Lines.Count - 1 do
    begin
      Line := Order.Lines[I];
      Prod := FProductRepo.GetByID(Line.ProductID);
      if Prod = nil then
        raise EEntityNotFoundException.Create('Product', IntToStr(Line.ProductID));

      // Increase stock in warehouse
      StockItem := FStockRepo.GetStockItem(Line.ProductID, Order.WarehouseID);
      if StockItem = nil then
      begin
        StockItem := TStockItem.Create;
        StockItem.ProductID := Line.ProductID;
        StockItem.WarehouseID := Order.WarehouseID;
        StockItem.Quantity := 0;
        StockItem.ReservedQuantity := 0;
      end;
      StockItem.Quantity := StockItem.Quantity + Line.OrderedQuantity;
      FStockRepo.SaveStockItem(StockItem);

      // Update product total stock & cost price
      Prod.CurrentStockTotal := Prod.CurrentStockTotal + Line.OrderedQuantity;
      if Line.UnitCost > 0 then Prod.CostPrice := Line.UnitCost;
      Prod.UpdatedAt := Now;
      FProductRepo.Save(Prod);

      // Create Stock Movement record
      Movement := TStockMovement.Create;
      try
        Movement.MovementType := smtPurchaseReceive;
        Movement.ProductID := Line.ProductID;
        Movement.WarehouseID := Order.WarehouseID;
        Movement.Quantity := Line.OrderedQuantity;
        Movement.ReferenceType := 'PURCHASE_ORDER';
        Movement.ReferenceID := Order.ID;
        Movement.UnitCost := Line.UnitCost;
        Movement.Reason := 'Goods receipt for ' + Order.OrderNumber;
        Movement.UserID := AUserID;
        Movement.Timestamp := Now;
        FStockRepo.AddStockMovement(Movement);
      finally
        Movement.Free;
      end;

      Line.ReceivedQuantity := Line.OrderedQuantity;
    end;

    Order.Status := posCompleted;
    FOrderRepo.Save(Order);

    if Assigned(FUnitOfWork) then FUnitOfWork.Commit;

    // Audit and Domain Event
    if Assigned(FAuditService) then
      FAuditService.LogAction(AUserID, 'User', 'GOODS_RECEIVED', 'PurchaseOrder', Order.ID,
        'Received goods for PO ' + Order.OrderNumber, '127.0.0.1');

    TDomainEventBus.Instance.Publish(TPurchaseReceivedEvent.Create(Order.ID, Order.OrderNumber,
      Order.SupplierID, Order.WarehouseID, AUserID));

    Result := TOperationResult.Ok('Goods received and warehouse stock updated.', Order.ID);
  except
    on E: Exception do
    begin
      if Assigned(FUnitOfWork) and FUnitOfWork.InTransaction then
        FUnitOfWork.Rollback;
      raise;
    end;
  end;
end;

function TPurchaseOrderService.CancelOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
var
  Order: TPurchaseOrder;
begin
  Order := FOrderRepo.GetByID(AID);
  if Order = nil then
    raise EEntityNotFoundException.Create('PurchaseOrder', IntToStr(AID));

  if Order.Status = posCompleted then
    raise EInvalidOrderStatusException.Create('Completed purchase orders cannot be cancelled.');

  Order.Status := posCancelled;
  FOrderRepo.Save(Order);

  if Assigned(FAuditService) then
    FAuditService.LogAction(AUserID, 'User', 'PURCHASE_ORDER_CANCELLED', 'PurchaseOrder', AID,
      'Cancelled purchase order ' + Order.OrderNumber, '127.0.0.1');

  Result := TOperationResult.Ok('Purchase order cancelled.', AID);
end;

end.
