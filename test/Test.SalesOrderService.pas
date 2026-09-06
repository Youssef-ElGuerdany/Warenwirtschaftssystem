unit Test.SalesOrderService;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Domain.Product,
  Warenfluss.Domain.Customer,
  Warenfluss.Domain.Warehouse,
  Warenfluss.Domain.SalesOrder,
  Warenfluss.DTOs.Order,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services,
  Warenfluss.Services.SalesOrder,
  Warenfluss.Services.Audit,
  Warenfluss.Repositories.Mock,
  Warenfluss.TestRunner;

type
  TTestSalesOrderService = class(TTestCase)
  private
    FOrderRepo: ISalesOrderRepository;
    FProductRepo: IProductRepository;
    FCustomerRepo: ICustomerRepository;
    FWarehouseRepo: IWarehouseRepository;
    FStockRepo: IStockRepository;
    FUnitOfWork: IUnitOfWork;
    FAuditRepo: IAuditRepository;
    FAuditService: IAuditService;
    FSalesService: ISalesOrderService;
    FCustomerID: TEntityID;
    FWarehouseID: TEntityID;
    FProductID: TEntityID;
  public
    procedure SetUp; override;
    procedure TestCreateSalesOrderCalculations;
    procedure TestConfirmAndCompleteOrderWorkflow;
    procedure TestCompleteOrderInsufficientStockFails;
  end;

implementation

procedure TTestSalesOrderService.SetUp;
var
  Cust: TCustomer;
  WH: TWarehouse;
  Prod: TProduct;
  StockItem: TStockItem;
begin
  FOrderRepo := TMockSalesOrderRepository.Create;
  FProductRepo := TMockProductRepository.Create;
  FCustomerRepo := TMockCustomerRepository.Create;
  FWarehouseRepo := TMockWarehouseRepository.Create;
  FStockRepo := TMockStockRepository.Create;
  FUnitOfWork := TMockUnitOfWork.Create;
  FAuditRepo := TMockAuditRepository.Create;
  FAuditService := TAuditService.Create(FAuditRepo);

  FSalesService := TSalesOrderService.Create(FOrderRepo, FProductRepo, FCustomerRepo, FWarehouseRepo,
    FStockRepo, FUnitOfWork, FAuditService);

  Cust := TCustomer.Create;
  Cust.CompanyName := 'Test Customer AG';
  Cust.CreditLimit := 50000;
  FCustomerID := FCustomerRepo.Save(Cust);

  WH := TWarehouse.Create;
  WH.Code := 'WH-SALES';
  WH.Name := 'Sales Warehouse';
  FWarehouseID := FWarehouseRepo.Save(WH);

  Prod := TProduct.Create;
  Prod.SKU := 'SALES-ITEM-1';
  Prod.Name := 'Enterprise Server Rack';
  Prod.CostPrice := 1000.00;
  Prod.UnitPrice := 2000.00;
  Prod.CurrentStockTotal := 10;
  FProductID := FProductRepo.Save(Prod);

  StockItem := TStockItem.Create;
  StockItem.ProductID := FProductID;
  StockItem.WarehouseID := FWarehouseID;
  StockItem.Quantity := 10;
  FStockRepo.SaveStockItem(StockItem);
end;

procedure TTestSalesOrderService.TestCreateSalesOrderCalculations;
var
  DTO: TSalesOrderCreateDTO;
  Res: TOperationResult;
  Order: TSalesOrderDTO;
begin
  DTO.CustomerID := FCustomerID;
  DTO.WarehouseID := FWarehouseID;
  DTO.RequiredDate := Now + 5;
  DTO.Notes := 'Test order';
  SetLength(DTO.Lines, 1);
  DTO.Lines[0].ProductID := FProductID;
  DTO.Lines[0].Quantity := 2;
  DTO.Lines[0].UnitPrice := 2000.00;
  DTO.Lines[0].DiscountPercent := 10.0; // 10% discount -> 3600.00 net

  Res := FSalesService.CreateOrder(DTO, 1);
  AssertTrue(Res.Success, 'Order creation should succeed');

  Order := FSalesService.GetOrderByID(Res.AffectedID);
  AssertEquals(3600.00, Order.SubTotal, 0.01, 'Subtotal should reflect discount (3600)');
  AssertEquals(684.00, Order.TaxAmount, 0.01, '19% MwSt should be 684.00');
  AssertEquals(4284.00, Order.TotalAmount, 0.01, 'Total amount should be 4284.00');
  AssertTrue(Order.Status = sosDraft, 'Initial status must be Draft');
end;

procedure TTestSalesOrderService.TestConfirmAndCompleteOrderWorkflow;
var
  DTO: TSalesOrderCreateDTO;
  Res: TOperationResult;
  OrderID: TEntityID;
  Order: TSalesOrderDTO;
  StockItem: TStockItem;
  Prod: TProduct;
begin
  DTO.CustomerID := FCustomerID;
  DTO.WarehouseID := FWarehouseID;
  DTO.RequiredDate := Now + 3;
  DTO.Notes := 'Workflow order';
  SetLength(DTO.Lines, 1);
  DTO.Lines[0].ProductID := FProductID;
  DTO.Lines[0].Quantity := 4;
  DTO.Lines[0].UnitPrice := 2000.00;
  DTO.Lines[0].DiscountPercent := 0;

  Res := FSalesService.CreateOrder(DTO, 1);
  OrderID := Res.AffectedID;

  // Confirm
  Res := FSalesService.ConfirmOrder(OrderID, 1);
  AssertTrue(Res.Success, 'Confirmation should succeed');

  Order := FSalesService.GetOrderByID(OrderID);
  AssertTrue(Order.Status = sosConfirmed, 'Status should be Confirmed');

  // Complete & Dispatch
  Res := FSalesService.CompleteOrder(OrderID, 1);
  AssertTrue(Res.Success, 'CompleteOrder should succeed');

  Order := FSalesService.GetOrderByID(OrderID);
  AssertTrue(Order.Status = sosCompleted, 'Status should be Completed');

  // Verify Stock Deduction
  StockItem := FStockRepo.GetStockItem(FProductID, FWarehouseID);
  AssertEquals(6.0, StockItem.Quantity, 0.001, 'Warehouse stock should be reduced from 10 to 6');

  Prod := FProductRepo.GetByID(FProductID);
  AssertEquals(6.0, Prod.CurrentStockTotal, 0.001, 'Product total stock should be reduced to 6');
end;

procedure TTestSalesOrderService.TestCompleteOrderInsufficientStockFails;
var
  DTO: TSalesOrderCreateDTO;
  Res: TOperationResult;
  OrderID: TEntityID;
  FailedAsExpected: Boolean;
begin
  DTO.CustomerID := FCustomerID;
  DTO.WarehouseID := FWarehouseID;
  DTO.RequiredDate := Now + 3;
  DTO.Notes := 'Excessive order';
  SetLength(DTO.Lines, 1);
  DTO.Lines[0].ProductID := FProductID;
  DTO.Lines[0].Quantity := 50; // Available is only 10
  DTO.Lines[0].UnitPrice := 2000.00;
  DTO.Lines[0].DiscountPercent := 0;

  Res := FSalesService.CreateOrder(DTO, 1);
  OrderID := Res.AffectedID;

  FailedAsExpected := False;
  try
    FSalesService.ConfirmOrder(OrderID, 1);
  except
    on E: EInsufficientStockException do
      FailedAsExpected := True;
  end;

  AssertTrue(FailedAsExpected, 'Confirming order with insufficient stock must raise EInsufficientStockException');
end;

initialization
  TTestRunner.RegisterTest(TTestSalesOrderService);

end.
