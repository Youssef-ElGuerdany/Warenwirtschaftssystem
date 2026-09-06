unit Warenfluss.ORM.Models;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes,
  mormot.core.base,
  mormot.orm.base,
  mormot.orm.core,
  Warenfluss.Types;

type
  { mORMot 2 ORM Entities (TSQLRecord) }

  TSQLUser = class(TSQLRecord)
  private
    FUsername: RawUtf8;
    FPasswordHash: RawUtf8;
    FPasswordSalt: RawUtf8;
    FFullName: RawUtf8;
    FEmail: RawUtf8;
    FRole: Integer;
    FIsActive: Boolean;
    FCreatedAt: TCreateTime;
    FLastLoginAt: TModTime;
  published
    property Username: RawUtf8 read FUsername write FUsername;
    property PasswordHash: RawUtf8 read FPasswordHash write FPasswordHash;
    property PasswordSalt: RawUtf8 read FPasswordSalt write FPasswordSalt;
    property FullName: RawUtf8 read FFullName write FFullName;
    property Email: RawUtf8 read FEmail write FEmail;
    property Role: Integer read FRole write FRole;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TCreateTime read FCreatedAt write FCreatedAt;
    property LastLoginAt: TModTime read FLastLoginAt write FLastLoginAt;
  end;

  TSQLCategory = class(TSQLRecord)
  private
    FCode: RawUtf8;
    FName: RawUtf8;
    FDescription: RawUtf8;
    FIsActive: Boolean;
  published
    property Code: RawUtf8 read FCode write FCode;
    property Name: RawUtf8 read FName write FName;
    property Description: RawUtf8 read FDescription write FDescription;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

  TSQLSupplier = class(TSQLRecord)
  private
    FCode: RawUtf8;
    FCompanyName: RawUtf8;
    FContactPerson: RawUtf8;
    FEmail: RawUtf8;
    FPhone: RawUtf8;
    FAddress: RawUtf8;
    FCity: RawUtf8;
    FPostalCode: RawUtf8;
    FCountry: RawUtf8;
    FIsActive: Boolean;
  published
    property Code: RawUtf8 read FCode write FCode;
    property CompanyName: RawUtf8 read FCompanyName write FCompanyName;
    property ContactPerson: RawUtf8 read FContactPerson write FContactPerson;
    property Email: RawUtf8 read FEmail write FEmail;
    property Phone: RawUtf8 read FPhone write FPhone;
    property Address: RawUtf8 read FAddress write FAddress;
    property City: RawUtf8 read FCity write FCity;
    property PostalCode: RawUtf8 read FPostalCode write FPostalCode;
    property Country: RawUtf8 read FCountry write FCountry;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

  TSQLCustomer = class(TSQLRecord)
  private
    FCode: RawUtf8;
    FCompanyName: RawUtf8;
    FContactPerson: RawUtf8;
    FEmail: RawUtf8;
    FPhone: RawUtf8;
    FAddress: RawUtf8;
    FCity: RawUtf8;
    FPostalCode: RawUtf8;
    FCountry: RawUtf8;
    FCreditLimit: Currency;
    FOutstandingBalance: Currency;
    FIsActive: Boolean;
  published
    property Code: RawUtf8 read FCode write FCode;
    property CompanyName: RawUtf8 read FCompanyName write FCompanyName;
    property ContactPerson: RawUtf8 read FContactPerson write FContactPerson;
    property Email: RawUtf8 read FEmail write FEmail;
    property Phone: RawUtf8 read FPhone write FPhone;
    property Address: RawUtf8 read FAddress write FAddress;
    property City: RawUtf8 read FCity write FCity;
    property PostalCode: RawUtf8 read FPostalCode write FPostalCode;
    property Country: RawUtf8 read FCountry write FCountry;
    property CreditLimit: Currency read FCreditLimit write FCreditLimit;
    property OutstandingBalance: Currency read FOutstandingBalance write FOutstandingBalance;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

  TSQLWarehouse = class(TSQLRecord)
  private
    FCode: RawUtf8;
    FName: RawUtf8;
    FLocation: RawUtf8;
    FIsActive: Boolean;
  published
    property Code: RawUtf8 read FCode write FCode;
    property Name: RawUtf8 read FName write FName;
    property Location: RawUtf8 read FLocation write FLocation;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

  TSQLProduct = class(TSQLRecord)
  private
    FSKU: RawUtf8;
    FBarcode: RawUtf8;
    FName: RawUtf8;
    FDescription: RawUtf8;
    FCategoryID: TID;
    FCostPrice: Currency;
    FUnitPrice: Currency;
    FCurrentStockTotal: Double;
    FMinStockLevel: Double;
    FMaxStockLevel: Double;
    FUnitType: Integer;
    FIsActive: Boolean;
    FCreatedAt: TCreateTime;
    FUpdatedAt: TModTime;
  published
    property SKU: RawUtf8 read FSKU write FSKU;
    property Barcode: RawUtf8 read FBarcode write FBarcode;
    property Name: RawUtf8 read FName write FName;
    property Description: RawUtf8 read FDescription write FDescription;
    property CategoryID: TID read FCategoryID write FCategoryID;
    property CostPrice: Currency read FCostPrice write FCostPrice;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property CurrentStockTotal: Double read FCurrentStockTotal write FCurrentStockTotal;
    property MinStockLevel: Double read FMinStockLevel write FMinStockLevel;
    property MaxStockLevel: Double read FMaxStockLevel write FMaxStockLevel;
    property UnitType: Integer read FUnitType write FUnitType;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TCreateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TModTime read FUpdatedAt write FUpdatedAt;
  end;

  TSQLStockItem = class(TSQLRecord)
  private
    FProductID: TID;
    FWarehouseID: TID;
    FQuantity: Double;
    FReservedQuantity: Double;
  published
    property ProductID: TID read FProductID write FProductID;
    property WarehouseID: TID read FWarehouseID write FWarehouseID;
    property Quantity: Double read FQuantity write FQuantity;
    property ReservedQuantity: Double read FReservedQuantity write FReservedQuantity;
  end;

  TSQLStockMovement = class(TSQLRecord)
  private
    FMovementType: Integer;
    FProductID: TID;
    FWarehouseID: TID;
    FTargetWarehouseID: TID;
    FQuantity: Double;
    FReferenceType: RawUtf8;
    FReferenceID: TID;
    FUnitCost: Currency;
    FReason: RawUtf8;
    FUserID: TID;
    FTimestamp: TCreateTime;
  published
    property MovementType: Integer read FMovementType write FMovementType;
    property ProductID: TID read FProductID write FProductID;
    property WarehouseID: TID read FWarehouseID write FWarehouseID;
    property TargetWarehouseID: TID read FTargetWarehouseID write FTargetWarehouseID;
    property Quantity: Double read FQuantity write FQuantity;
    property ReferenceType: RawUtf8 read FReferenceType write FReferenceType;
    property ReferenceID: TID read FReferenceID write FReferenceID;
    property UnitCost: Currency read FUnitCost write FUnitCost;
    property Reason: RawUtf8 read FReason write FReason;
    property UserID: TID read FUserID write FUserID;
    property Timestamp: TCreateTime read FTimestamp write FTimestamp;
  end;

  TSQLPurchaseOrder = class(TSQLRecord)
  private
    FOrderNumber: RawUtf8;
    FSupplierID: TID;
    FWarehouseID: TID;
    FOrderDate: TTimeLog;
    FExpectedDeliveryDate: TTimeLog;
    FStatus: Integer;
    FTotalAmount: Currency;
    FNotes: RawUtf8;
    FCreatedByUserID: TID;
  published
    property OrderNumber: RawUtf8 read FOrderNumber write FOrderNumber;
    property SupplierID: TID read FSupplierID write FSupplierID;
    property WarehouseID: TID read FWarehouseID write FWarehouseID;
    property OrderDate: TTimeLog read FOrderDate write FOrderDate;
    property ExpectedDeliveryDate: TTimeLog read FExpectedDeliveryDate write FExpectedDeliveryDate;
    property Status: Integer read FStatus write FStatus;
    property TotalAmount: Currency read FTotalAmount write FTotalAmount;
    property Notes: RawUtf8 read FNotes write FNotes;
    property CreatedByUserID: TID read FCreatedByUserID write FCreatedByUserID;
  end;

  TSQLPurchaseOrderLine = class(TSQLRecord)
  private
    FPurchaseOrderID: TID;
    FProductID: TID;
    FOrderedQuantity: Double;
    FReceivedQuantity: Double;
    FUnitCost: Currency;
    FLineTotal: Currency;
  published
    property PurchaseOrderID: TID read FPurchaseOrderID write FPurchaseOrderID;
    property ProductID: TID read FProductID write FProductID;
    property OrderedQuantity: Double read FOrderedQuantity write FOrderedQuantity;
    property ReceivedQuantity: Double read FReceivedQuantity write FReceivedQuantity;
    property UnitCost: Currency read FUnitCost write FUnitCost;
    property LineTotal: Currency read FLineTotal write FLineTotal;
  end;

  TSQLSalesOrder = class(TSQLRecord)
  private
    FOrderNumber: RawUtf8;
    FCustomerID: TID;
    FWarehouseID: TID;
    FOrderDate: TTimeLog;
    FRequiredDate: TTimeLog;
    FStatus: Integer;
    FSubTotal: Currency;
    FTaxRate: Double;
    FTaxAmount: Currency;
    FTotalAmount: Currency;
    FNotes: RawUtf8;
    FCreatedByUserID: TID;
  published
    property OrderNumber: RawUtf8 read FOrderNumber write FOrderNumber;
    property CustomerID: TID read FCustomerID write FCustomerID;
    property WarehouseID: TID read FWarehouseID write FWarehouseID;
    property OrderDate: TTimeLog read FOrderDate write FOrderDate;
    property RequiredDate: TTimeLog read FRequiredDate write FRequiredDate;
    property Status: Integer read FStatus write FStatus;
    property SubTotal: Currency read FSubTotal write FSubTotal;
    property TaxRate: Double read FTaxRate write FTaxRate;
    property TaxAmount: Currency read FTaxAmount write FTaxAmount;
    property TotalAmount: Currency read FTotalAmount write FTotalAmount;
    property Notes: RawUtf8 read FNotes write FNotes;
    property CreatedByUserID: TID read FCreatedByUserID write FCreatedByUserID;
  end;

  TSQLSalesOrderLine = class(TSQLRecord)
  private
    FSalesOrderID: TID;
    FProductID: TID;
    FQuantity: Double;
    FUnitPrice: Currency;
    FDiscountPercent: Double;
    FLineTotal: Currency;
  published
    property SalesOrderID: TID read FSalesOrderID write FSalesOrderID;
    property ProductID: TID read FProductID write FProductID;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property DiscountPercent: Double read FDiscountPercent write FDiscountPercent;
    property LineTotal: Currency read FLineTotal write FLineTotal;
  end;

  TSQLAuditLog = class(TSQLRecord)
  private
    FTimestamp: TCreateTime;
    FUserID: TID;
    FUsername: RawUtf8;
    FAction: RawUtf8;
    FEntityName: RawUtf8;
    FEntityID: TID;
    FDetails: RawUtf8;
    FClientIP: RawUtf8;
  published
    property Timestamp: TCreateTime read FTimestamp write FTimestamp;
    property UserID: TID read FUserID write FUserID;
    property Username: RawUtf8 read FUsername write FUsername;
    property Action: RawUtf8 read FAction write FAction;
    property EntityName: RawUtf8 read FEntityName write FEntityName;
    property EntityID: TID read FEntityID write FEntityID;
    property Details: RawUtf8 read FDetails write FDetails;
    property ClientIP: RawUtf8 read FClientIP write FClientIP;
  end;

function CreateWarenflussModel: TOrmModel;

implementation

function CreateWarenflussModel: TOrmModel;
begin
  Result := TOrmModel.Create([
    TSQLUser,
    TSQLCategory,
    TSQLSupplier,
    TSQLCustomer,
    TSQLWarehouse,
    TSQLProduct,
    TSQLStockItem,
    TSQLStockMovement,
    TSQLPurchaseOrder,
    TSQLPurchaseOrderLine,
    TSQLSalesOrder,
    TSQLSalesOrderLine,
    TSQLAuditLog
  ], 'api');
end;

end.
