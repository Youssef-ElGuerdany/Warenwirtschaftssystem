unit Warenfluss.Domain.PurchaseOrder;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections, Warenfluss.Types;

type
  TPurchaseOrderLine = class
  private
    FID: TEntityID;
    FPurchaseOrderID: TEntityID;
    FProductID: TEntityID;
    FOrderedQuantity: Double;
    FReceivedQuantity: Double;
    FUnitCost: Currency;
    FLineTotal: Currency;
  public
    constructor Create;
    procedure Recalculate;
    property ID: TEntityID read FID write FID;
    property PurchaseOrderID: TEntityID read FPurchaseOrderID write FPurchaseOrderID;
    property ProductID: TEntityID read FProductID write FProductID;
    property OrderedQuantity: Double read FOrderedQuantity write FOrderedQuantity;
    property ReceivedQuantity: Double read FReceivedQuantity write FReceivedQuantity;
    property UnitCost: Currency read FUnitCost write FUnitCost;
    property LineTotal: Currency read FLineTotal write FLineTotal;
  end;

  TPurchaseOrder = class
  private
    FID: TEntityID;
    FOrderNumber: string;
    FSupplierID: TEntityID;
    FWarehouseID: TEntityID;
    FOrderDate: TDateTime;
    FExpectedDeliveryDate: TDateTime;
    FStatus: TPurchaseOrderStatus;
    FTotalAmount: Currency;
    FNotes: string;
    FCreatedByUserID: TEntityID;
    FLines: TObjectList<TPurchaseOrderLine>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RecalculateTotal;
    property ID: TEntityID read FID write FID;
    property OrderNumber: string read FOrderNumber write FOrderNumber;
    property SupplierID: TEntityID read FSupplierID write FSupplierID;
    property WarehouseID: TEntityID read FWarehouseID write FWarehouseID;
    property OrderDate: TDateTime read FOrderDate write FOrderDate;
    property ExpectedDeliveryDate: TDateTime read FExpectedDeliveryDate write FExpectedDeliveryDate;
    property Status: TPurchaseOrderStatus read FStatus write FStatus;
    property TotalAmount: Currency read FTotalAmount write FTotalAmount;
    property Notes: string read FNotes write FNotes;
    property CreatedByUserID: TEntityID read FCreatedByUserID write FCreatedByUserID;
    property Lines: TObjectList<TPurchaseOrderLine> read FLines;
  end;

implementation

{ TPurchaseOrderLine }

constructor TPurchaseOrderLine.Create;
begin
  inherited Create;
  FID := 0;
  FPurchaseOrderID := 0;
  FProductID := 0;
  FOrderedQuantity := 1;
  FReceivedQuantity := 0;
  FUnitCost := 0;
  FLineTotal := 0;
end;

procedure TPurchaseOrderLine.Recalculate;
begin
  FLineTotal := FOrderedQuantity * FUnitCost;
end;

{ TPurchaseOrder }

constructor TPurchaseOrder.Create;
begin
  inherited Create;
  FID := 0;
  FSupplierID := 0;
  FWarehouseID := 0;
  FOrderDate := Now;
  FExpectedDeliveryDate := Now + 7;
  FStatus := posDraft;
  FTotalAmount := 0;
  FCreatedByUserID := 0;
  FLines := TObjectList<TPurchaseOrderLine>.Create(True);
end;

destructor TPurchaseOrder.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TPurchaseOrder.RecalculateTotal;
var
  I: Integer;
  Sum: Currency;
begin
  Sum := 0;
  for I := 0 to FLines.Count - 1 do
  begin
    FLines[I].Recalculate;
    Sum := Sum + FLines[I].LineTotal;
  end;
  FTotalAmount := Sum;
end;

end.
