unit Warenfluss.Domain.Warehouse;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TWarehouse = class
  private
    FID: TEntityID;
    FCode: string;
    FName: string;
    FLocation: string;
    FIsActive: Boolean;
  public
    constructor Create;
    property ID: TEntityID read FID write FID;
    property Code: string read FCode write FCode;
    property Name: string read FName write FName;
    property Location: string read FLocation write FLocation;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

  TStockItem = class
  private
    FID: TEntityID;
    FProductID: TEntityID;
    FWarehouseID: TEntityID;
    FQuantity: Double;
    FReservedQuantity: Double;
  public
    constructor Create;
    function AvailableQuantity: Double;
    property ID: TEntityID read FID write FID;
    property ProductID: TEntityID read FProductID write FProductID;
    property WarehouseID: TEntityID read FWarehouseID write FWarehouseID;
    property Quantity: Double read FQuantity write FQuantity;
    property ReservedQuantity: Double read FReservedQuantity write FReservedQuantity;
  end;

implementation

{ TWarehouse }

constructor TWarehouse.Create;
begin
  inherited Create;
  FID := 0;
  FIsActive := True;
end;

{ TStockItem }

constructor TStockItem.Create;
begin
  inherited Create;
  FID := 0;
  FProductID := 0;
  FWarehouseID := 0;
  FQuantity := 0;
  FReservedQuantity := 0;
end;

function TStockItem.AvailableQuantity: Double;
begin
  Result := FQuantity - FReservedQuantity;
  if Result < 0 then Result := 0;
end;

end.
