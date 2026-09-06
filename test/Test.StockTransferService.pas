unit Test.StockTransferService;

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
  Warenfluss.Services.StockTransfer,
  Warenfluss.Services.Audit,
  Warenfluss.Repositories.Mock,
  Warenfluss.TestRunner;

type
  TTestStockTransferService = class(TTestCase)
  private
    FStockRepo: IStockRepository;
    FProductRepo: IProductRepository;
    FWarehouseRepo: IWarehouseRepository;
    FUnitOfWork: IUnitOfWork;
    FAuditRepo: IAuditRepository;
    FAuditService: IAuditService;
    FTransferService: IStockTransferService;
    FProductID: TEntityID;
    FSrcWH_ID: TEntityID;
    FTgtWH_ID: TEntityID;
  public
    procedure SetUp; override;
    procedure TestSuccessfulTransfer;
    procedure TestTransferInsufficientStock;
    procedure TestTransferSameWarehouseFails;
  end;

implementation

procedure TTestStockTransferService.SetUp;
var
  Prod: TProduct;
  SrcWH, TgtWH: TWarehouse;
  StockItem: TStockItem;
begin
  FStockRepo := TMockStockRepository.Create;
  FProductRepo := TMockProductRepository.Create;
  FWarehouseRepo := TMockWarehouseRepository.Create;
  FUnitOfWork := TMockUnitOfWork.Create;
  FAuditRepo := TMockAuditRepository.Create;
  FAuditService := TAuditService.Create(FAuditRepo);
  FTransferService := TStockTransferService.Create(FStockRepo, FProductRepo, FWarehouseRepo, FUnitOfWork, FAuditService);

  SrcWH := TWarehouse.Create;
  SrcWH.Code := 'WH-SRC';
  SrcWH.Name := 'Source Warehouse';
  FSrcWH_ID := FWarehouseRepo.Save(SrcWH);

  TgtWH := TWarehouse.Create;
  TgtWH.Code := 'WH-TGT';
  TgtWH.Name := 'Target Warehouse';
  FTgtWH_ID := FWarehouseRepo.Save(TgtWH);

  Prod := TProduct.Create;
  Prod.SKU := 'XFER-PROD-01';
  Prod.Name := 'Transfer Test Product';
  Prod.CostPrice := 30.00;
  Prod.UnitPrice := 60.00;
  Prod.CurrentStockTotal := 100;
  FProductID := FProductRepo.Save(Prod);

  // Set initial 100 pcs in source warehouse
  StockItem := TStockItem.Create;
  StockItem.ProductID := FProductID;
  StockItem.WarehouseID := FSrcWH_ID;
  StockItem.Quantity := 100;
  FStockRepo.SaveStockItem(StockItem);
end;

procedure TTestStockTransferService.TestSuccessfulTransfer;
var
  DTO: TStockTransferDTO;
  Res: TOperationResult;
  SrcItem, TgtItem: TStockItem;
begin
  DTO.ProductID := FProductID;
  DTO.SourceWarehouseID := FSrcWH_ID;
  DTO.TargetWarehouseID := FTgtWH_ID;
  DTO.Quantity := 40;
  DTO.Reason := 'Replenish regional warehouse';

  Res := FTransferService.TransferStock(DTO, 1);
  AssertTrue(Res.Success, 'Transfer should succeed');

  SrcItem := FStockRepo.GetStockItem(FProductID, FSrcWH_ID);
  TgtItem := FStockRepo.GetStockItem(FProductID, FTgtWH_ID);

  AssertEquals(60.0, SrcItem.Quantity, 0.001, 'Source stock should decrease to 60');
  AssertEquals(40.0, TgtItem.Quantity, 0.001, 'Target stock should increase to 40');
end;

procedure TTestStockTransferService.TestTransferInsufficientStock;
var
  DTO: TStockTransferDTO;
  FailedAsExpected: Boolean;
begin
  DTO.ProductID := FProductID;
  DTO.SourceWarehouseID := FSrcWH_ID;
  DTO.TargetWarehouseID := FTgtWH_ID;
  DTO.Quantity := 150; // Exceeds 100
  DTO.Reason := 'Excessive transfer';

  FailedAsExpected := False;
  try
    FTransferService.TransferStock(DTO, 1);
  except
    on E: EInsufficientStockException do
      FailedAsExpected := True;
  end;

  AssertTrue(FailedAsExpected, 'Transferring more than available must raise EInsufficientStockException');
end;

procedure TTestStockTransferService.TestTransferSameWarehouseFails;
var
  DTO: TStockTransferDTO;
  FailedAsExpected: Boolean;
begin
  DTO.ProductID := FProductID;
  DTO.SourceWarehouseID := FSrcWH_ID;
  DTO.TargetWarehouseID := FSrcWH_ID; // Same!
  DTO.Quantity := 10;
  DTO.Reason := 'Same warehouse';

  FailedAsExpected := False;
  try
    FTransferService.TransferStock(DTO, 1);
  except
    on E: EValidationException do
      FailedAsExpected := True;
  end;

  AssertTrue(FailedAsExpected, 'Transferring to same warehouse must raise EValidationException');
end;

initialization
  TTestRunner.RegisterTest(TTestStockTransferService);

end.
