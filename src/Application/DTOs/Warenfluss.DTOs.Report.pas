unit Warenfluss.DTOs.Report;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TInventoryValuationItemDTO = record
    ProductID: TEntityID;
    SKU: string;
    ProductName: string;
    CategoryName: string;
    WarehouseName: string;
    Quantity: Double;
    UnitCost: Currency;
    UnitPrice: Currency;
    TotalCostValue: Currency;
    TotalRetailValue: Currency;
  end;

  TInventoryValuationSummaryDTO = record
    TotalSKUs: Integer;
    TotalQuantity: Double;
    TotalCostValue: Currency;
    TotalRetailValue: Currency;
    EstimatedGrossProfit: Currency;
    Items: array of TInventoryValuationItemDTO;
  end;

  TDashboardSummaryDTO = record
    TotalProductsCount: Integer;
    LowStockAlertCount: Integer;
    PendingSalesOrdersCount: Integer;
    PendingPurchaseOrdersCount: Integer;
    TotalStockValuation: Currency;
    MonthlySalesVolume: Currency;
  end;

  TAuditLogDTO = record
    ID: TEntityID;
    Timestamp: TDateTime;
    UserID: TEntityID;
    Username: string;
    Action: string;
    EntityName: string;
    EntityID: TEntityID;
    Details: string;
    ClientIP: string;
  end;

implementation

end.
