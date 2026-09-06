unit Warenfluss.Domain.OrderValidator;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Exceptions, Warenfluss.Domain.SalesOrder, Warenfluss.Domain.PurchaseOrder;

type
  TOrderValidator = class
  public
    class procedure ValidateSalesOrder(AOrder: TSalesOrder);
    class procedure ValidatePurchaseOrder(AOrder: TPurchaseOrder);
  end;

implementation

class procedure TOrderValidator.ValidateSalesOrder(AOrder: TSalesOrder);
var
  I: Integer;
begin
  if AOrder = nil then
    raise EValidationException.Create('Sales order instance cannot be nil.');

  if AOrder.CustomerID <= 0 then
    raise EValidationException.Create('A valid customer must be selected for the sales order.');

  if AOrder.WarehouseID <= 0 then
    raise EValidationException.Create('A valid warehouse must be selected for the sales order.');

  if AOrder.Lines.Count = 0 then
    raise EValidationException.Create('Sales order must contain at least one line item.');

  for I := 0 to AOrder.Lines.Count - 1 do
  begin
    if AOrder.Lines[I].ProductID <= 0 then
      raise EValidationException.Create(Format('Line %d has an invalid product.', [I + 1]));

    if AOrder.Lines[I].Quantity <= 0 then
      raise EValidationException.Create(Format('Line %d: quantity must be greater than zero.', [I + 1]));

    if AOrder.Lines[I].UnitPrice < 0 then
      raise EValidationException.Create(Format('Line %d: unit price cannot be negative.', [I + 1]));

    if (AOrder.Lines[I].DiscountPercent < 0) or (AOrder.Lines[I].DiscountPercent > 100) then
      raise EValidationException.Create(Format('Line %d: discount percentage must be between 0 and 100.', [I + 1]));
  end;
end;

class procedure TOrderValidator.ValidatePurchaseOrder(AOrder: TPurchaseOrder);
var
  I: Integer;
begin
  if AOrder = nil then
    raise EValidationException.Create('Purchase order instance cannot be nil.');

  if AOrder.SupplierID <= 0 then
    raise EValidationException.Create('A valid supplier must be selected.');

  if AOrder.WarehouseID <= 0 then
    raise EValidationException.Create('A valid target warehouse must be selected.');

  if AOrder.Lines.Count = 0 then
    raise EValidationException.Create('Purchase order must contain at least one line item.');

  for I := 0 to AOrder.Lines.Count - 1 do
  begin
    if AOrder.Lines[I].ProductID <= 0 then
      raise EValidationException.Create(Format('Line %d has an invalid product.', [I + 1]));

    if AOrder.Lines[I].OrderedQuantity <= 0 then
      raise EValidationException.Create(Format('Line %d: ordered quantity must be greater than zero.', [I + 1]));

    if AOrder.Lines[I].UnitCost < 0 then
      raise EValidationException.Create(Format('Line %d: unit cost cannot be negative.', [I + 1]));
  end;
end;

end.
