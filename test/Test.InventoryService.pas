unit Test.InventoryService;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Domain.Product,
  Warenfluss.Domain.Warehouse,
  Warenfluss.DTOs.Inventory,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services,
  Warenfluss.Services.Inventory,
  Warenfluss.Services.Audit,
  Warenfluss.Repositories.Mock,
  Warenfluss.TestRunner;

type
  TTestInventoryService = class(TTestCase)
  private
    FStockRepo: IStockRepository;
    FProductRepo: IProductRepository;
    FWarehouseRepo: IWarehouseRepository;
    FUnitOfWork: IUnitOfWork;
    FAuditRepo: IAuditRepository;
    FAuditService: IAuditService;
    FInventoryService: IInventoryService;
    FTestProductID: TEntityID;
    FTestWarehouseID: TEntityID;
  public
    procedure SetUp; override;
    procedure TestPositiveAdjustment;
    procedure TestNegativeAdjustment;
    procedure TestPreventNegativeStock;
    procedure TestStockMovementRecorded;
  end;

implementation

procedure TTestInventoryService.SetUp;
var
  Prod: TProduct;
  WH: TWarehouse;
  StockItem: TStockItem;
begin
  FStockRepo := TMockStockRepository.Create;
  FProductRepo := TMockProductRepository.Create;
  FWarehouseRepo := TMockWarehouseRepository.Create;
  FUnitOfWork := TMockUnitOfWork.Create;
  FAuditRepo := TMockAuditRepository.Create;
  FAuditService := TAuditService.Create(FAuditRepo);
  FInventoryService := TInventoryService.Create(FStockRepo, FProductRepo, FWarehouseRepo, FUnitOfWork, FAuditService);

  WH := TWarehouse.Create;
  WH.Code := 'WH-TEST';
  WH.Name := 'Test Warehouse';
  FTestWarehouseID := FWarehouseRepo.Save(WH);

  Prod := TProduct.Create;
  Prod.SKU := 'TEST-SKU-001';
  Prod.Name := 'Test Product';
  Prod.CostPrice := 50.00;
  Prod.UnitPrice := 100.00;
  Prod.CurrentStockTotal := 20;
  FTestProductID := FProductRepo.Save(Prod);

  StockItem := TStockItem.Create;
  StockItem.ProductID := FTestProductID;
  StockItem.WarehouseID := FTestWarehouseID;
  StockItem.Quantity := 20;
  FStockRepo.SaveStockItem(StockItem);
end;

procedure TTestInventoryService.TestPositiveAdjustment;
var
  DTO: TStockAdjustmentDTO;
  Res: TOperationResult;
  Avail: Double;
  Prod: TProduct;
begin
  DTO.ProductID := FTestProductID;
  DTO.WarehouseID := FTestWarehouseID;
  DTO.AdjustmentQuantity := 15;
  DTO.Reason := 'Found inventory in storage';

  Res := FInventoryService.AdjustStock(DTO, 1);
  AssertTrue(Res.Success, 'Adjustment should succeed');

  Avail := FInventoryService.GetAvailableStock(FTestProductID, FTestWarehouseID);
  AssertEquals(35.0, Avail, 0.001, 'Stock should increase from 20 to 35');

  Prod := FProductRepo.GetByID(FTestProductID);
  AssertEquals(35.0, Prod.CurrentStockTotal, 0.001, 'Product total stock should be updated to 35');
end;

procedure TTestInventoryService.TestNegativeAdjustment;
var
  DTO: TStockAdjustmentDTO;
  Res: TOperationResult;
  Avail: Double;
begin
  DTO.ProductID := FTestProductID;
  DTO.WarehouseID := FTestWarehouseID;
  DTO.AdjustmentQuantity := -5;
  DTO.Reason := 'Damaged items written off';

  Res := FInventoryService.AdjustStock(DTO, 1);
  AssertTrue(Res.Success, 'Negative adjustment within stock should succeed');

  Avail := FInventoryService.GetAvailableStock(FTestProductID, FTestWarehouseID);
  AssertEquals(15.0, Avail, 0.001, 'Stock should decrease from 20 to 15');
end;

procedure TTestInventoryService.TestPreventNegativeStock;
var
  DTO: TStockAdjustmentDTO;
  FailedAsExpected: Boolean;
begin
  DTO.ProductID := FTestProductID;
  DTO.WarehouseID := FTestWarehouseID;
  DTO.AdjustmentQuantity := -50; // Greater than available 20
  DTO.Reason := 'Illegal reduction';

  FailedAsExpected := False;
  try
    FInventoryService.AdjustStock(DTO, 1);
  except
    on E: EInsufficientStockException do
      FailedAsExpected := True;
  end;

  AssertTrue(FailedAsExpected, 'Adjusting below zero must raise EInsufficientStockException');
end;

procedure TTestInventoryService.TestStockMovementRecorded;
var
  DTO: TStockAdjustmentDTO;
  History: TArray<TStockMovementDTO>;
begin
  DTO.ProductID := FTestProductID;
  DTO.WarehouseID := FTestWarehouseID;
  DTO.AdjustmentQuantity := 10;
  DTO.Reason := 'Audit stock count adjustment';

  FInventoryService.AdjustStock(DTO, 1);
  History := FInventoryService.GetMovementHistory(FTestProductID);

  AssertTrue(Length(History) > 0, 'Movement history must contain recorded movement');
  AssertEquals(10.0, History[0].Quantity, 0.001, 'Movement quantity should be 10');
end;

initialization
  TTestRunner.RegisterTest(TTestInventoryService);

end.
