unit Warenfluss.Services.Report;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.Domain.Product,
  Warenfluss.Domain.Category,
  Warenfluss.Domain.Warehouse,
  Warenfluss.Domain.SalesOrder,
  Warenfluss.Domain.PurchaseOrder,
  Warenfluss.DTOs.Report,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TReportService = class(TInterfacedObject, IReportService)
  private
    FProductRepo: IProductRepository;
    FCategoryRepo: ICategoryRepository;
    FWarehouseRepo: IWarehouseRepository;
    FStockRepo: IStockRepository;
    FSalesRepo: ISalesOrderRepository;
    FPurchaseRepo: IPurchaseOrderRepository;
  public
    constructor Create(AProductRepo: IProductRepository; ACategoryRepo: ICategoryRepository;
      AWarehouseRepo: IWarehouseRepository; AStockRepo: IStockRepository;
      ASalesRepo: ISalesOrderRepository; APurchaseRepo: IPurchaseOrderRepository);

    function GetDashboardSummary: TDashboardSummaryDTO;
    function GetInventoryValuation(AWarehouseID: TEntityID = 0): TInventoryValuationSummaryDTO;
  end;

implementation

constructor TReportService.Create(AProductRepo: IProductRepository; ACategoryRepo: ICategoryRepository;
  AWarehouseRepo: IWarehouseRepository; AStockRepo: IStockRepository;
  ASalesRepo: ISalesOrderRepository; APurchaseRepo: IPurchaseOrderRepository);
begin
  inherited Create;
  FProductRepo := AProductRepo;
  FCategoryRepo := ACategoryRepo;
  FWarehouseRepo := AWarehouseRepo;
  FStockRepo := AStockRepo;
  FSalesRepo := ASalesRepo;
  FPurchaseRepo := APurchaseRepo;
end;

function TReportService.GetDashboardSummary: TDashboardSummaryDTO;
var
  Products: TObjectList<TProduct>;
  SalesList: TObjectList<TSalesOrder>;
  PurchaseList: TObjectList<TPurchaseOrder>;
  StockItems: TObjectList<TStockItem>;
  I: Integer;
  Prod: TProduct;
begin
  Result.TotalProductsCount := 0;
  Result.LowStockAlertCount := 0;
  Result.PendingSalesOrdersCount := 0;
  Result.PendingPurchaseOrdersCount := 0;
  Result.TotalStockValuation := 0;
  Result.MonthlySalesVolume := 0;

  if Assigned(FProductRepo) then
  begin
    Products := FProductRepo.GetAll;
    try
      Result.TotalProductsCount := Products.Count;
      for I := 0 to Products.Count - 1 do
        if Products[I].IsLowStock then
          Inc(Result.LowStockAlertCount);
    finally
      Products.Free;
    end;
  end;

  if Assigned(FSalesRepo) then
  begin
    SalesList := FSalesRepo.GetAll;
    try
      for I := 0 to SalesList.Count - 1 do
      begin
        if SalesList[I].Status in [sosDraft, sosConfirmed] then
          Inc(Result.PendingSalesOrdersCount);
        if SalesList[I].Status = sosCompleted then
          Result.MonthlySalesVolume := Result.MonthlySalesVolume + SalesList[I].TotalAmount;
      end;
    finally
      SalesList.Free;
    end;
  end;

  if Assigned(FPurchaseRepo) then
  begin
    PurchaseList := FPurchaseRepo.GetAll;
    try
      for I := 0 to PurchaseList.Count - 1 do
        if PurchaseList[I].Status in [posDraft, posApproved, posPartiallyReceived] then
          Inc(Result.PendingPurchaseOrdersCount);
    finally
      PurchaseList.Free;
    end;
  end;

  if Assigned(FStockRepo) and Assigned(FProductRepo) then
  begin
    StockItems := FStockRepo.GetAllStockItems;
    try
      for I := 0 to StockItems.Count - 1 do
      begin
        Prod := FProductRepo.GetByID(StockItems[I].ProductID);
        if Prod <> nil then
          Result.TotalStockValuation := Result.TotalStockValuation + (StockItems[I].Quantity * Prod.CostPrice);
      end;
    finally
      StockItems.Free;
    end;
  end;
end;

function TReportService.GetInventoryValuation(AWarehouseID: TEntityID): TInventoryValuationSummaryDTO;
var
  StockItems: TObjectList<TStockItem>;
  I: Integer;
  Prod: TProduct;
  Cat: TCategory;
  WH: TWarehouse;
begin
  Result.TotalSKUs := 0;
  Result.TotalQuantity := 0;
  Result.TotalCostValue := 0;
  Result.TotalRetailValue := 0;
  Result.EstimatedGrossProfit := 0;

  if AWarehouseID > 0 then
    StockItems := FStockRepo.GetStockByWarehouse(AWarehouseID)
  else
    StockItems := FStockRepo.GetAllStockItems;

  try
    SetLength(Result.Items, StockItems.Count);
    for I := 0 to StockItems.Count - 1 do
    begin
      Result.Items[I].ProductID := StockItems[I].ProductID;
      Result.Items[I].Quantity := StockItems[I].Quantity;
      Result.Items[I].SKU := '';
      Result.Items[I].ProductName := '';
      Result.Items[I].CategoryName := '';
      Result.Items[I].WarehouseName := '';
      Result.Items[I].UnitCost := 0;
      Result.Items[I].UnitPrice := 0;
      Result.Items[I].TotalCostValue := 0;
      Result.Items[I].TotalRetailValue := 0;

      if Assigned(FProductRepo) then
      begin
        Prod := FProductRepo.GetByID(StockItems[I].ProductID);
        if Prod <> nil then
        begin
          Result.Items[I].SKU := Prod.SKU;
          Result.Items[I].ProductName := Prod.Name;
          Result.Items[I].UnitCost := Prod.CostPrice;
          Result.Items[I].UnitPrice := Prod.UnitPrice;
          Result.Items[I].TotalCostValue := StockItems[I].Quantity * Prod.CostPrice;
          Result.Items[I].TotalRetailValue := StockItems[I].Quantity * Prod.UnitPrice;

          if Assigned(FCategoryRepo) and (Prod.CategoryID > 0) then
          begin
            Cat := FCategoryRepo.GetByID(Prod.CategoryID);
            if Cat <> nil then Result.Items[I].CategoryName := Cat.Name;
          end;
        end;
      end;

      if Assigned(FWarehouseRepo) and (StockItems[I].WarehouseID > 0) then
      begin
        WH := FWarehouseRepo.GetByID(StockItems[I].WarehouseID);
        if WH <> nil then Result.Items[I].WarehouseName := WH.Name;
      end;

      Result.TotalQuantity := Result.TotalQuantity + StockItems[I].Quantity;
      Result.TotalCostValue := Result.TotalCostValue + Result.Items[I].TotalCostValue;
      Result.TotalRetailValue := Result.TotalRetailValue + Result.Items[I].TotalRetailValue;
    end;

    Result.TotalSKUs := StockItems.Count;
    Result.EstimatedGrossProfit := Result.TotalRetailValue - Result.TotalCostValue;
  finally
    StockItems.Free;
  end;
end;

end.
