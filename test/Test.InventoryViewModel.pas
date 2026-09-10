unit Test.InventoryViewModel;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  Warenfluss.Types,
  Warenfluss.Domain.Product,
  Warenfluss.Domain.Warehouse,
  Warenfluss.DTOs.Inventory,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services,
  Warenfluss.Services.Inventory,
  Warenfluss.Services.StockTransfer,
  Warenfluss.Services.Warehouse,
  Warenfluss.Services.Audit,
  Warenfluss.Repositories.Mock,
  Warenfluss.ViewModel.Inventory,
  Warenfluss.TestRunner;

type
  TTestInventoryViewModel = class(TTestCase)
  private
    FStockRepo:        IStockRepository;
    FProductRepo:      IProductRepository;
    FWarehouseRepo:    IWarehouseRepository;
    FUnitOfWork:       IUnitOfWork;
    FAuditRepo:        IAuditRepository;
    FAuditService:     IAuditService;
    FInventoryService: IInventoryService;
    FTransferService:  IStockTransferService;
    FWarehouseService: IWarehouseService;
    FViewModel:        TInventoryViewModel;

    FProdID1, FProdID2: TEntityID;
    FWHID1, FWHID2:     TEntityID;
  public
    procedure SetUp; override;
    procedure TearDown; override;

    procedure TestLoadStockPopulatesItems;
    procedure TestSearchFiltering;
    procedure TestWarehouseFiltering;
    procedure TestCalculations;
    procedure TestAdjustStockThroughViewModel;
    procedure TestTransferStockThroughViewModel;
  end;

implementation

procedure TTestInventoryViewModel.SetUp;
var
  Prod1, Prod2: TProduct;
  WH1, WH2: TWarehouse;
  Stock1, Stock2: TStockItem;
begin
  FStockRepo        := TMockStockRepository.Create;
  FProductRepo      := TMockProductRepository.Create;
  FWarehouseRepo    := TMockWarehouseRepository.Create;
  FUnitOfWork       := TMockUnitOfWork.Create;
  FAuditRepo        := TMockAuditRepository.Create;
  FAuditService     := TAuditService.Create(FAuditRepo);
  FInventoryService := TInventoryService.Create(FStockRepo, FProductRepo, FWarehouseRepo, FUnitOfWork, FAuditService);
  FTransferService  := TStockTransferService.Create(FStockRepo, FProductRepo, FWarehouseRepo, FUnitOfWork, FAuditService);
  FWarehouseService := TWarehouseService.Create(FWarehouseRepo);

  WH1 := TWarehouse.Create;
  WH1.Code := 'WH-MAIN';
  WH1.Name := 'Zentrallager';
  FWHID1 := FWarehouseRepo.Save(WH1);

  WH2 := TWarehouse.Create;
  WH2.Code := 'WH-SEC';
  WH2.Name := 'Aussenlager';
  FWHID2 := FWarehouseRepo.Save(WH2);

  Prod1 := TProduct.Create;
  Prod1.SKU := 'PROD-001';
  Prod1.Name := 'Bohrmaschine Pro';
  Prod1.CostPrice := 50.00;
  Prod1.UnitPrice := 100.00;
  Prod1.CurrentStockTotal := 10;
  FProdID1 := FProductRepo.Save(Prod1);

  Prod2 := TProduct.Create;
  Prod2.SKU := 'PROD-002';
  Prod2.Name := 'Akkuschrauber Plus';
  Prod2.CostPrice := 30.00;
  Prod2.UnitPrice := 60.00;
  Prod2.CurrentStockTotal := 20;
  FProdID2 := FProductRepo.Save(Prod2);

  Stock1 := TStockItem.Create;
  Stock1.ProductID := FProdID1;
  Stock1.WarehouseID := FWHID1;
  Stock1.Quantity := 10;
  FStockRepo.SaveStockItem(Stock1);

  Stock2 := TStockItem.Create;
  Stock2.ProductID := FProdID2;
  Stock2.WarehouseID := FWHID2;
  Stock2.Quantity := 20;
  FStockRepo.SaveStockItem(Stock2);

  FViewModel := TInventoryViewModel.Create(FInventoryService, FTransferService, FWarehouseService);
  FViewModel.LoadStock;
end;

procedure TTestInventoryViewModel.TearDown;
begin
  FViewModel.Free;
end;

procedure TTestInventoryViewModel.TestLoadStockPopulatesItems;
begin
  AssertEquals(2, Length(FViewModel.StockItems), 'Should load 2 stock items');
  AssertEquals(2, Length(FViewModel.Warehouses), 'Should load 2 warehouses');
end;

procedure TTestInventoryViewModel.TestSearchFiltering;
begin
  FViewModel.Search('Bohrmaschine');
  AssertEquals(1, Length(FViewModel.StockItems), 'Should filter to 1 item matching Bohrmaschine');
  AssertEquals('PROD-001', FViewModel.StockItems[0].ProductSKU, 'Matched item SKU should be PROD-001');

  FViewModel.Search('Akkuschrauber');
  AssertEquals(1, Length(FViewModel.StockItems), 'Should filter to 1 item matching Akkuschrauber');

  FViewModel.Search('NonExistent');
  AssertEquals(0, Length(FViewModel.StockItems), 'Should find 0 items for non-existent query');

  FViewModel.Search('');
  AssertEquals(2, Length(FViewModel.StockItems), 'Empty query should reset to all items');
end;

procedure TTestInventoryViewModel.TestWarehouseFiltering;
begin
  FViewModel.FilterByWarehouse(FWHID1);
  AssertEquals(1, Length(FViewModel.StockItems), 'Warehouse 1 should have 1 item');
  AssertEquals('PROD-001', FViewModel.StockItems[0].ProductSKU);

  FViewModel.FilterByWarehouse(0);
  AssertEquals(2, Length(FViewModel.StockItems), 'Warehouse 0 should show all items');
end;

procedure TTestInventoryViewModel.TestCalculations;
begin
  AssertEquals(30.0, FViewModel.GetTotalQuantity, 0.001, 'Total stock quantity should be 10 + 20 = 30');
  // 10 * 50 = 500; 20 * 30 = 600; Total = 1100
  AssertEquals(1100.0, Double(FViewModel.GetTotalValuation), 0.001, 'Total valuation should be 1100');
  AssertEquals(2, FViewModel.GetTotalPositionCount, 'Total position count should be 2');
end;

procedure TTestInventoryViewModel.TestAdjustStockThroughViewModel;
var
  Res: TOperationResult;
begin
  Res := FViewModel.AdjustStock(FProdID1, FWHID1, 5, 'Inventurzugang', 1);
  AssertTrue(Res.Success, 'Adjustment should succeed');
  AssertEquals(35.0, FViewModel.GetTotalQuantity, 0.001, 'Quantity should increase to 35');
end;

procedure TTestInventoryViewModel.TestTransferStockThroughViewModel;
var
  Res: TOperationResult;
begin
  Res := FViewModel.TransferStock(FProdID1, FWHID1, FWHID2, 4, 'Filialversand', 1);
  AssertTrue(Res.Success, 'Transfer should succeed');
  AssertEquals(30.0, FViewModel.GetTotalQuantity, 0.001, 'Total quantity remains 30 after transfer');
end;

end.
