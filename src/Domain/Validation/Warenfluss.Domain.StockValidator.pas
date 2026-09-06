unit Warenfluss.Domain.StockValidator;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Exceptions, Warenfluss.Types;

type
  TStockValidator = class
  public
    class procedure ValidateAdjustment(AProductID, AWarehouseID: TEntityID; AQuantity: Double; const AReason: string);
    class procedure ValidateTransfer(AProductID, ASrcWarehouseID, ATgtWarehouseID: TEntityID; AQuantity: Double; AAvailStock: Double);
  end;

implementation

class procedure TStockValidator.ValidateAdjustment(AProductID, AWarehouseID: TEntityID; AQuantity: Double;
  const AReason: string);
begin
  if AProductID <= 0 then
    raise EValidationException.Create('Invalid product ID for stock adjustment.');

  if AWarehouseID <= 0 then
    raise EValidationException.Create('Invalid warehouse ID for stock adjustment.');

  if Abs(AQuantity) < 0.0001 then
    raise EValidationException.Create('Adjustment quantity cannot be zero.');

  if Trim(AReason) = '' then
    raise EValidationException.Create('A reason must be provided for stock adjustment.');
end;

class procedure TStockValidator.ValidateTransfer(AProductID, ASrcWarehouseID, ATgtWarehouseID: TEntityID;
  AQuantity: Double; AAvailStock: Double);
begin
  if AProductID <= 0 then
    raise EValidationException.Create('Invalid product ID for transfer.');

  if ASrcWarehouseID <= 0 then
    raise EValidationException.Create('Invalid source warehouse.');

  if ATgtWarehouseID <= 0 then
    raise EValidationException.Create('Invalid destination warehouse.');

  if ASrcWarehouseID = ATgtWarehouseID then
    raise EValidationException.Create('Source and destination warehouse cannot be the same.');

  if AQuantity <= 0 then
    raise EValidationException.Create('Transfer quantity must be strictly positive.');

  if AAvailStock < AQuantity then
    raise EInsufficientStockException.Create(AProductID, ASrcWarehouseID, AQuantity, AAvailStock,
      Format('Cannot transfer %.2f: available stock at source warehouse is only %.2f.', [AQuantity, AAvailStock]));
end;

end.
