unit Warenfluss.Domain.ProductValidator;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Exceptions, Warenfluss.Domain.Product;

type
  TProductValidator = class
  public
    class procedure Validate(AProduct: TProduct);
  end;

implementation

class procedure TProductValidator.Validate(AProduct: TProduct);
begin
  if AProduct = nil then
    raise EValidationException.Create('Product instance cannot be nil.');

  if Trim(AProduct.SKU) = '' then
    raise EValidationException.Create('Product SKU cannot be empty.');

  if Length(Trim(AProduct.SKU)) < 3 then
    raise EValidationException.Create('Product SKU must be at least 3 characters.');

  if Trim(AProduct.Name) = '' then
    raise EValidationException.Create('Product name cannot be empty.');

  if AProduct.UnitPrice < 0 then
    raise EValidationException.Create('Unit price cannot be negative.');

  if AProduct.CostPrice < 0 then
    raise EValidationException.Create('Cost price cannot be negative.');

  if AProduct.MinStockLevel < 0 then
    raise EValidationException.Create('Minimum stock level cannot be negative.');
end;

end.
