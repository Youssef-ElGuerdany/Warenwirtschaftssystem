unit Warenfluss.Domain.SalesOrder;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections, Warenfluss.Types;

type
  TSalesOrderLine = class
  private
    FID: TEntityID;
    FSalesOrderID: TEntityID;
    FProductID: TEntityID;
    FQuantity: Double;
    FUnitPrice: Currency;
    FDiscountPercent: Double;
    FLineTotal: Currency;
  public
    constructor Create;
    procedure Recalculate;
    property ID: TEntityID read FID write FID;
    property SalesOrderID: TEntityID read FSalesOrderID write FSalesOrderID;
    property ProductID: TEntityID read FProductID write FProductID;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property DiscountPercent: Double read FDiscountPercent write FDiscountPercent;
    property LineTotal: Currency read FLineTotal write FLineTotal;
  end;

  TSalesOrder = class
  private
    FID: TEntityID;
    FOrderNumber: string;
    FCustomerID: TEntityID;
    FWarehouseID: TEntityID;
    FOrderDate: TDateTime;
    FRequiredDate: TDateTime;
    FStatus: TSalesOrderStatus;
    FSubTotal: Currency;
    FTaxRate: Double;
    FTaxAmount: Currency;
    FTotalAmount: Currency;
    FNotes: string;
    FCreatedByUserID: TEntityID;
    FLines: TObjectList<TSalesOrderLine>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RecalculateTotals;
    property ID: TEntityID read FID write FID;
    property OrderNumber: string read FOrderNumber write FOrderNumber;
    property CustomerID: TEntityID read FCustomerID write FCustomerID;
    property WarehouseID: TEntityID read FWarehouseID write FWarehouseID;
    property OrderDate: TDateTime read FOrderDate write FOrderDate;
    property RequiredDate: TDateTime read FRequiredDate write FRequiredDate;
    property Status: TSalesOrderStatus read FStatus write FStatus;
    property SubTotal: Currency read FSubTotal write FSubTotal;
    property TaxRate: Double read FTaxRate write FTaxRate;
    property TaxAmount: Currency read FTaxAmount write FTaxAmount;
    property TotalAmount: Currency read FTotalAmount write FTotalAmount;
    property Notes: string read FNotes write FNotes;
    property CreatedByUserID: TEntityID read FCreatedByUserID write FCreatedByUserID;
    property Lines: TObjectList<TSalesOrderLine> read FLines;
  end;

implementation

{ TSalesOrderLine }

constructor TSalesOrderLine.Create;
begin
  inherited Create;
  FID := 0;
  FSalesOrderID := 0;
  FProductID := 0;
  FQuantity := 1;
  FUnitPrice := 0;
  FDiscountPercent := 0;
  FLineTotal := 0;
end;

procedure TSalesOrderLine.Recalculate;
var
  Gross: Currency;
  Disc: Currency;
begin
  Gross := FQuantity * FUnitPrice;
  Disc := Gross * (FDiscountPercent / 100.0);
  FLineTotal := Gross - Disc;
end;

{ TSalesOrder }

constructor TSalesOrder.Create;
begin
  inherited Create;
  FID := 0;
  FCustomerID := 0;
  FWarehouseID := 0;
  FOrderDate := Now;
  FRequiredDate := Now + 3;
  FStatus := sosDraft;
  FSubTotal := 0;
  FTaxRate := 19.0; // 19% MwSt
  FTaxAmount := 0;
  FTotalAmount := 0;
  FCreatedByUserID := 0;
  FLines := TObjectList<TSalesOrderLine>.Create(True);
end;

destructor TSalesOrder.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TSalesOrder.RecalculateTotals;
var
  I: Integer;
  Sub: Currency;
begin
  Sub := 0;
  for I := 0 to FLines.Count - 1 do
  begin
    FLines[I].Recalculate;
    Sub := Sub + FLines[I].LineTotal;
  end;
  FSubTotal := Sub;
  FTaxAmount := FSubTotal * (FTaxRate / 100.0);
  FTotalAmount := FSubTotal + FTaxAmount;
end;

end.
