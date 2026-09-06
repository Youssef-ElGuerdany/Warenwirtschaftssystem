unit Warenfluss.Domain.StockMovement;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TStockMovement = class
  private
    FID: TEntityID;
    FMovementType: TMovementType;
    FProductID: TEntityID;
    FWarehouseID: TEntityID;
    FTargetWarehouseID: TEntityID;
    FQuantity: Double;
    FReferenceType: string;
    FReferenceID: TEntityID;
    FUnitCost: Currency;
    FReason: string;
    FUserID: TEntityID;
    FTimestamp: TDateTime;
  public
    constructor Create;
    property ID: TEntityID read FID write FID;
    property MovementType: TMovementType read FMovementType write FMovementType;
    property ProductID: TEntityID read FProductID write FProductID;
    property WarehouseID: TEntityID read FWarehouseID write FWarehouseID;
    property TargetWarehouseID: TEntityID read FTargetWarehouseID write FTargetWarehouseID;
    property Quantity: Double read FQuantity write FQuantity;
    property ReferenceType: string read FReferenceType write FReferenceType;
    property ReferenceID: TEntityID read FReferenceID write FReferenceID;
    property UnitCost: Currency read FUnitCost write FUnitCost;
    property Reason: string read FReason write FReason;
    property UserID: TEntityID read FUserID write FUserID;
    property Timestamp: TDateTime read FTimestamp write FTimestamp;
  end;

implementation

constructor TStockMovement.Create;
begin
  inherited Create;
  FID := 0;
  FMovementType := smtAdjustmentPlus;
  FProductID := 0;
  FWarehouseID := 0;
  FTargetWarehouseID := 0;
  FQuantity := 0;
  FReferenceID := 0;
  FUnitCost := 0;
  FUserID := 0;
  FTimestamp := Now;
end;

end.
