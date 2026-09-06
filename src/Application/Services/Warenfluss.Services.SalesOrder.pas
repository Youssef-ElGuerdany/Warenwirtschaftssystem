unit Warenfluss.Services.SalesOrder;

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
  Warenfluss.Domain.Customer,
  Warenfluss.Domain.Warehouse,
  Warenfluss.Domain.SalesOrder,
  Warenfluss.Domain.StockMovement,
  Warenfluss.Domain.OrderValidator,
  Warenfluss.DTOs.Order,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TSalesOrderService = class(TInterfacedObject, ISalesOrderService)
  private
    FOrderRepo: ISalesOrderRepository;
    FProductRepo: IProductRepository;
    FCustomerRepo: ICustomerRepository;
    FWarehouseRepo: IWarehouseRepository;
    FStockRepo: IStockRepository;
    FUnitOfWork: IUnitOfWork;
    FAuditService: IAuditService;
    function EntityToDTO(AOrder: TSalesOrder): TSalesOrderDTO;
  public
    constructor Create(AOrderRepo: ISalesOrderRepository; AProductRepo: IProductRepository;
      ACustomerRepo: ICustomerRepository; AWarehouseRepo: IWarehouseRepository;
      AStockRepo: IStockRepository; AUnitOfWork: IUnitOfWork; AAuditService: IAuditService);

    function GetAllOrders: TArray<TSalesOrderDTO>;
    function GetOrderByID(AID: TEntityID): TSalesOrderDTO;
    function CreateOrder(const ADTO: TSalesOrderCreateDTO; AUserID: TEntityID): TOperationResult;
    function ConfirmOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
    function CompleteOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
    function CancelOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
  end;

implementation

constructor TSalesOrderService.Create(AOrderRepo: ISalesOrderRepository; AProductRepo: IProductRepository;
  ACustomerRepo: ICustomerRepository; AWarehouseRepo: IWarehouseRepository;
  AStockRepo: IStockRepository; AUnitOfWork: IUnitOfWork; AAuditService: IAuditService);
begin
  inherited Create;
  FOrderRepo := AOrderRepo;
  FProductRepo := AProductRepo;
  FCustomerRepo := ACustomerRepo;
  FWarehouseRepo := AWarehouseRepo;
  FStockRepo := AStockRepo;
  FUnitOfWork := AUnitOfWork;
  FAuditService := AAuditService;
end;

function TSalesOrderService.EntityToDTO(AOrder: TSalesOrder): TSalesOrderDTO;
var
  I: Integer;
  Cust: TCustomer;
  WH: TWarehouse;
  Prod: TProduct;
begin
  if AOrder = nil then Exit;
  Result.ID := AOrder.ID;
  Result.OrderNumber := AOrder.OrderNumber;
  Result.CustomerID := AOrder.CustomerID;
  Result.CustomerName := '';
  Result.WarehouseID := AOrder.WarehouseID;
  Result.WarehouseName := '';
  Result.OrderDate := AOrder.OrderDate;
  Result.RequiredDate := AOrder.RequiredDate;
  Result.Status := AOrder.Status;
  Result.StatusName := SalesStatusToString(AOrder.Status);
  Result.SubTotal := AOrder.SubTotal;
  Result.TaxRate := AOrder.TaxRate;
  Result.TaxAmount := AOrder.TaxAmount;
  Result.TotalAmount := AOrder.TotalAmount;
  Result.Notes := AOrder.Notes;
  Result.CreatedByUserID := AOrder.CreatedByUserID;
  Result.CreatedByUsername := 'User #' + IntToStr(AOrder.CreatedByUserID);

  if (AOrder.CustomerID > 0) and Assigned(FCustomerRepo) then
  begin
    Cust := FCustomerRepo.GetByID(AOrder.CustomerID);
    if Cust <> nil then Result.CustomerName := Cust.CompanyName;
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
    Result.Lines[I].SalesOrderID := AOrder.Lines[I].SalesOrderID;
    Result.Lines[I].ProductID := AOrder.Lines[I].ProductID;
    Result.Lines[I].Quantity := AOrder.Lines[I].Quantity;
    Result.Lines[I].UnitPrice := AOrder.Lines[I].UnitPrice;
    Result.Lines[I].DiscountPercent := AOrder.Lines[I].DiscountPercent;
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

function TSalesOrderService.GetAllOrders: TArray<TSalesOrderDTO>;
var
  List: TObjectList<TSalesOrder>;
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

function TSalesOrderService.GetOrderByID(AID: TEntityID): TSalesOrderDTO;
var
  Order: TSalesOrder;
begin
  Order := FOrderRepo.GetByID(AID);
  if Order = nil then
    raise EEntityNotFoundException.Create('SalesOrder', IntToStr(AID));
  Result := EntityToDTO(Order);
end;

function TSalesOrderService.CreateOrder(const ADTO: TSalesOrderCreateDTO; AUserID: TEntityID): TOperationResult;
var
  Order: TSalesOrder;
  Line: TSalesOrderLine;
  I: Integer;
  NewID: TEntityID;
begin
  Order := TSalesOrder.Create;
  try
    Order.OrderNumber := FOrderRepo.GenerateNextOrderNumber;
    Order.CustomerID := ADTO.CustomerID;
    Order.WarehouseID := ADTO.WarehouseID;
    Order.RequiredDate := ADTO.RequiredDate;
    Order.Notes := ADTO.Notes;
    Order.CreatedByUserID := AUserID;
    Order.Status := sosDraft;

    for I := 0 to Length(ADTO.Lines) - 1 do
    begin
      Line := TSalesOrderLine.Create;
      Line.ProductID := ADTO.Lines[I].ProductID;
      Line.Quantity := ADTO.Lines[I].Quantity;
      Line.UnitPrice := ADTO.Lines[I].UnitPrice;
      Line.DiscountPercent := ADTO.Lines[I].DiscountPercent;
      Line.Recalculate;
      Order.Lines.Add(Line);
    end;

    Order.RecalculateTotals;
    TOrderValidator.ValidateSalesOrder(Order);

    NewID := FOrderRepo.Save(Order);

    if Assigned(FAuditService) then
      FAuditService.LogAction(AUserID, 'User', 'SALES_ORDER_CREATED', 'SalesOrder', NewID,
        'Created sales order ' + Order.OrderNumber, '127.0.0.1');

    Result := TOperationResult.Ok('Sales order created successfully.', NewID);
  except
    Order.Free;
    raise;
  end;
end;

function TSalesOrderService.ConfirmOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
var
  Order: TSalesOrder;
  Line: TSalesOrderLine;
  StockItem: TStockItem;
  I: Integer;
begin
  Order := FOrderRepo.GetByID(AID);
  if Order = nil then
    raise EEntityNotFoundException.Create('SalesOrder', IntToStr(AID));

  if Order.Status <> sosDraft then
    raise EInvalidOrderStatusException.Create('Only draft sales orders can be confirmed.');

  // Pre-validate stock availability in warehouse
  for I := 0 to Order.Lines.Count - 1 do
  begin
    Line := Order.Lines[I];
    StockItem := FStockRepo.GetStockItem(Line.ProductID, Order.WarehouseID);
    if (StockItem = nil) or (StockItem.AvailableQuantity < Line.Quantity) then
    begin
      raise EInsufficientStockException.Create(Line.ProductID, Order.WarehouseID,
        Line.Quantity, 0,
        Format('Insufficient stock for line %d. Available: %.2f, Requested: %.2f',
          [I + 1, 0.0, Line.Quantity]));
    end;
  end;

  Order.Status := sosConfirmed;
  FOrderRepo.Save(Order);

  if Assigned(FAuditService) then
    FAuditService.LogAction(AUserID, 'User', 'SALES_ORDER_CONFIRMED', 'SalesOrder', AID,
      'Confirmed sales order ' + Order.OrderNumber, '127.0.0.1');

  Result := TOperationResult.Ok('Sales order confirmed.', AID);
end;

function TSalesOrderService.CompleteOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
var
  Order: TSalesOrder;
  Line: TSalesOrderLine;
  Prod: TProduct;
  StockItem: TStockItem;
  Movement: TStockMovement;
  I: Integer;
begin
  Order := FOrderRepo.GetByID(AID);
  if Order = nil then
    raise EEntityNotFoundException.Create('SalesOrder', IntToStr(AID));

  if Order.Status <> sosConfirmed then
    raise EInvalidOrderStatusException.Create('Only confirmed sales orders can be executed / completed.');

  if Assigned(FUnitOfWork) then FUnitOfWork.BeginTransaction;
  try
    // 1. Verify stock availability and deduct
    for I := 0 to Order.Lines.Count - 1 do
    begin
      Line := Order.Lines[I];
      Prod := FProductRepo.GetByID(Line.ProductID);
      if Prod = nil then
        raise EEntityNotFoundException.Create('Product', IntToStr(Line.ProductID));

      StockItem := FStockRepo.GetStockItem(Line.ProductID, Order.WarehouseID);
      if (StockItem = nil) or (StockItem.AvailableQuantity < Line.Quantity) then
      begin
        raise EInsufficientStockException.Create(Line.ProductID, Order.WarehouseID,
          Line.Quantity, 0,
          Format('Cannot dispatch: insufficient stock for item %s in warehouse.', [Prod.SKU]));
      end;

      // Deduct stock in warehouse
      StockItem.Quantity := StockItem.Quantity - Line.Quantity;
      FStockRepo.SaveStockItem(StockItem);

      // Deduct total product stock
      Prod.CurrentStockTotal := Prod.CurrentStockTotal - Line.Quantity;
      if Prod.CurrentStockTotal < 0 then Prod.CurrentStockTotal := 0;
      Prod.UpdatedAt := Now;
      FProductRepo.Save(Prod);

      // Create Outgoing Stock Movement
      Movement := TStockMovement.Create;
      try
        Movement.MovementType := smtSalesDispatch;
        Movement.ProductID := Line.ProductID;
        Movement.WarehouseID := Order.WarehouseID;
        Movement.Quantity := Line.Quantity;
        Movement.ReferenceType := 'SALES_ORDER';
        Movement.ReferenceID := Order.ID;
        Movement.UnitCost := Prod.CostPrice;
        Movement.Reason := 'Sales dispatch for ' + Order.OrderNumber;
        Movement.UserID := AUserID;
        Movement.Timestamp := Now;
        FStockRepo.AddStockMovement(Movement);
      finally
        Movement.Free;
      end;
    end;

    // 2. Mark order as completed
    Order.Status := sosCompleted;
    FOrderRepo.Save(Order);

    if Assigned(FUnitOfWork) then FUnitOfWork.Commit;

    // 3. Audit and Domain Event
    if Assigned(FAuditService) then
      FAuditService.LogAction(AUserID, 'User', 'SALES_ORDER_COMPLETED', 'SalesOrder', Order.ID,
        'Completed sales order and dispatched goods ' + Order.OrderNumber, '127.0.0.1');

    TDomainEventBus.Instance.Publish(TSalesOrderCompletedEvent.Create(Order.ID, Order.OrderNumber,
      Order.CustomerID, Order.WarehouseID, Order.TotalAmount, AUserID));

    Result := TOperationResult.Ok('Sales order completed and goods dispatched.', Order.ID);
  except
    on E: Exception do
    begin
      if Assigned(FUnitOfWork) and FUnitOfWork.InTransaction then
        FUnitOfWork.Rollback;
      raise;
    end;
  end;
end;

function TSalesOrderService.CancelOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
var
  Order: TSalesOrder;
begin
  Order := FOrderRepo.GetByID(AID);
  if Order = nil then
    raise EEntityNotFoundException.Create('SalesOrder', IntToStr(AID));

  if Order.Status = sosCompleted then
    raise EInvalidOrderStatusException.Create('Completed sales orders cannot be cancelled.');

  Order.Status := sosCancelled;
  FOrderRepo.Save(Order);

  if Assigned(FAuditService) then
    FAuditService.LogAction(AUserID, 'User', 'SALES_ORDER_CANCELLED', 'SalesOrder', AID,
      'Cancelled sales order ' + Order.OrderNumber, '127.0.0.1');

  Result := TOperationResult.Ok('Sales order cancelled.', AID);
end;

end.
