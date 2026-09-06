unit Warenfluss.Domain.Product;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TProduct = class
  private
    FID: TEntityID;
    FSKU: string;
    FBarcode: string;
    FName: string;
    FDescription: string;
    FCategoryID: TEntityID;
    FCostPrice: Currency;
    FUnitPrice: Currency;
    FCurrentStockTotal: Double;
    FMinStockLevel: Double;
    FMaxStockLevel: Double;
    FUnit: TProductUnit;
    FIsActive: Boolean;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
  public
    constructor Create;
    function IsLowStock: Boolean;
    property ID: TEntityID read FID write FID;
    property SKU: string read FSKU write FSKU;
    property Barcode: string read FBarcode write FBarcode;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property CategoryID: TEntityID read FCategoryID write FCategoryID;
    property CostPrice: Currency read FCostPrice write FCostPrice;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property CurrentStockTotal: Double read FCurrentStockTotal write FCurrentStockTotal;
    property MinStockLevel: Double read FMinStockLevel write FMinStockLevel;
    property MaxStockLevel: Double read FMaxStockLevel write FMaxStockLevel;
    property UnitType: TProductUnit read FUnit write FUnit;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  end;

implementation

constructor TProduct.Create;
begin
  inherited Create;
  FID := 0;
  FCategoryID := 0;
  FCostPrice := 0;
  FUnitPrice := 0;
  FCurrentStockTotal := 0;
  FMinStockLevel := 5;
  FMaxStockLevel := 1000;
  FUnit := puPiece;
  FIsActive := True;
  FCreatedAt := Now;
  FUpdatedAt := Now;
end;

function TProduct.IsLowStock: Boolean;
begin
  Result := (FCurrentStockTotal <= FMinStockLevel);
end;

end.
