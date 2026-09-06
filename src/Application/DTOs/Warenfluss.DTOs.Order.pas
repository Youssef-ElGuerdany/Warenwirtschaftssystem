unit Warenfluss.DTOs.Order;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  { Sales Order DTOs }
  TSalesOrderLineDTO = record
    ID: TEntityID;
    SalesOrderID: TEntityID;
    ProductID: TEntityID;
    ProductSKU: string;
    ProductName: string;
    Quantity: Double;
    UnitPrice: Currency;
    DiscountPercent: Double;
    LineTotal: Currency;
  end;

  TSalesOrderLineArray = array of TSalesOrderLineDTO;

  TSalesOrderDTO = record
    ID: TEntityID;
    OrderNumber: string;
    CustomerID: TEntityID;
    CustomerName: string;
    WarehouseID: TEntityID;
    WarehouseName: string;
    OrderDate: TDateTime;
    RequiredDate: TDateTime;
    Status: TSalesOrderStatus;
    StatusName: string;
    SubTotal: Currency;
    TaxRate: Double;
    TaxAmount: Currency;
    TotalAmount: Currency;
    Notes: string;
    CreatedByUserID: TEntityID;
    CreatedByUsername: string;
    Lines: TSalesOrderLineArray;
  end;

  TSalesOrderCreateDTO = record
    CustomerID: TEntityID;
    WarehouseID: TEntityID;
    RequiredDate: TDateTime;
    Notes: string;
    Lines: TSalesOrderLineArray;
  end;

  { Purchase Order DTOs }
  TPurchaseOrderLineDTO = record
    ID: TEntityID;
    PurchaseOrderID: TEntityID;
    ProductID: TEntityID;
    ProductSKU: string;
    ProductName: string;
    OrderedQuantity: Double;
    ReceivedQuantity: Double;
    UnitCost: Currency;
    LineTotal: Currency;
  end;

  TPurchaseOrderLineArray = array of TPurchaseOrderLineDTO;

  TPurchaseOrderDTO = record
    ID: TEntityID;
    OrderNumber: string;
    SupplierID: TEntityID;
    SupplierName: string;
    WarehouseID: TEntityID;
    WarehouseName: string;
    OrderDate: TDateTime;
    ExpectedDeliveryDate: TDateTime;
    Status: TPurchaseOrderStatus;
    StatusName: string;
    TotalAmount: Currency;
    Notes: string;
    CreatedByUserID: TEntityID;
    CreatedByUsername: string;
    Lines: TPurchaseOrderLineArray;
  end;

  TPurchaseOrderCreateDTO = record
    SupplierID: TEntityID;
    WarehouseID: TEntityID;
    ExpectedDeliveryDate: TDateTime;
    Notes: string;
    Lines: TPurchaseOrderLineArray;
  end;

implementation

end.
