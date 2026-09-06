unit Warenfluss.Localization;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Warenfluss.Types;

type
  { Localization Manager }
  TLocalizationManager = class
  private
    FCurrentLanguage: TLanguage;
    FDictGerman: TDictionary<string, string>;
    FDictEnglish: TDictionary<string, string>;
    class var FInstance: TLocalizationManager;
    procedure InitializeDictionaries;
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance: TLocalizationManager;
    class procedure FreeInstance;

    function Translate(const AKey: string; const ADefault: string = ''): string;
    function FormatCurrency(AValue: Currency): string;
    function FormatQuantity(AValue: Double; const AUnit: string = ''): string;
    function FormatDate(ADate: TDateTime): string;

    property CurrentLanguage: TLanguage read FCurrentLanguage write FCurrentLanguage;
  end;

{ Global shortcut functions }
function _(const AKey: string; const ADefault: string = ''): string;
function FormatMoney(AAmount: Currency): string;
function FormatQty(AQty: Double; const AUnit: string = ''): string;

implementation

{ TLocalizationManager }

constructor TLocalizationManager.Create;
begin
  inherited Create;
  FCurrentLanguage := langGerman; // Default to German
  FDictGerman := TDictionary<string, string>.Create;
  FDictEnglish := TDictionary<string, string>.Create;
  InitializeDictionaries;
end;

destructor TLocalizationManager.Destroy;
begin
  FDictGerman.Free;
  FDictEnglish.Free;
  inherited Destroy;
end;

class function TLocalizationManager.Instance: TLocalizationManager;
begin
  if FInstance = nil then
    FInstance := TLocalizationManager.Create;
  Result := FInstance;
end;

class procedure TLocalizationManager.FreeInstance;
begin
  FreeAndNil(FInstance);
end;

procedure TLocalizationManager.InitializeDictionaries;
begin
  // --- GERMAN (Deutsch) ---
  FDictGerman.Add('APP_TITLE', 'Warenfluss – Lager- und Auftragsverwaltung');
  FDictGerman.Add('NAV_DASHBOARD', 'Dashboard');
  FDictGerman.Add('NAV_PRODUCTS', 'Artikelstamm');
  FDictGerman.Add('NAV_INVENTORY', 'Lagerbestand');
  FDictGerman.Add('NAV_STOCK_TRANSFER', 'Umlagerung');
  FDictGerman.Add('NAV_SALES_ORDERS', 'Verkaufsaufträge');
  FDictGerman.Add('NAV_PURCHASE_ORDERS', 'Einkaufsbestellungen');
  FDictGerman.Add('NAV_SUPPLIERS', 'Lieferanten');
  FDictGerman.Add('NAV_CUSTOMERS', 'Kunden');
  FDictGerman.Add('NAV_REPORTS', 'Berichte & Auswertungen');
  FDictGerman.Add('NAV_AUDIT', 'Audit-Protokoll');
  FDictGerman.Add('NAV_USERS', 'Benutzerverwaltung');

  // Actions
  FDictGerman.Add('BTN_SAVE', 'Speichern');
  FDictGerman.Add('BTN_CANCEL', 'Abbrechen');
  FDictGerman.Add('BTN_NEW', 'Neu');
  FDictGerman.Add('BTN_EDIT', 'Bearbeiten');
  FDictGerman.Add('BTN_DELETE', 'Löschen');
  FDictGerman.Add('BTN_REFRESH', 'Aktualisieren');
  FDictGerman.Add('BTN_CLOSE', 'Schließen');
  FDictGerman.Add('BTN_SEARCH', 'Suchen');
  FDictGerman.Add('BTN_LOGIN', 'Anmelden');
  FDictGerman.Add('BTN_LOGOUT', 'Abmelden');
  FDictGerman.Add('BTN_CONFIRM_ORDER', 'Auftrag bestätigen');
  FDictGerman.Add('BTN_COMPLETE_ORDER', 'Auftrag ausführen / Warenausgang buchen');
  FDictGerman.Add('BTN_CANCEL_ORDER', 'Auftrag stornieren');
  FDictGerman.Add('BTN_RECEIVE_GOODS', 'Wareneingang buchen');
  FDictGerman.Add('BTN_ADJUST_STOCK', 'Bestandskorrektur');
  FDictGerman.Add('BTN_TRANSFER_STOCK', 'Umlagern');

  // Fields
  FDictGerman.Add('FIELD_SKU', 'Artikelnummer (SKU)');
  FDictGerman.Add('FIELD_BARCODE', 'Barcode / EAN');
  FDictGerman.Add('FIELD_NAME', 'Bezeichnung');
  FDictGerman.Add('FIELD_CATEGORY', 'Kategorie');
  FDictGerman.Add('FIELD_UNIT_PRICE', 'Verkaufspreis');
  FDictGerman.Add('FIELD_COST_PRICE', 'Einkaufspreis');
  FDictGerman.Add('FIELD_CURRENT_STOCK', 'Aktueller Bestand');
  FDictGerman.Add('FIELD_MIN_STOCK', 'Mindestbestand');
  FDictGerman.Add('FIELD_WAREHOUSE', 'Lager / Standort');
  FDictGerman.Add('FIELD_QUANTITY', 'Menge');
  FDictGerman.Add('FIELD_CUSTOMER', 'Kunde');
  FDictGerman.Add('FIELD_SUPPLIER', 'Lieferant');
  FDictGerman.Add('FIELD_ORDER_DATE', 'Auftragsdatum');
  FDictGerman.Add('FIELD_STATUS', 'Status');
  FDictGerman.Add('FIELD_TOTAL', 'Gesamtsumme');
  FDictGerman.Add('FIELD_USERNAME', 'Benutzername');
  FDictGerman.Add('FIELD_PASSWORD', 'Passwort');
  FDictGerman.Add('FIELD_REASON', 'Grund / Bemerkung');

  // Domain Exceptions & Messages
  FDictGerman.Add('ERR_INSUFFICIENT_STOCK', 'Der verfügbare Lagerbestand reicht nicht aus.');
  FDictGerman.Add('ERR_PRODUCT_NOT_FOUND', 'Artikel nicht gefunden.');
  FDictGerman.Add('ERR_INVALID_STATUS', 'Ungültiger Auftragsstatus für diese Operation.');
  FDictGerman.Add('ERR_UNAUTHORIZED', 'Zugriff verweigert oder ungültige Anmeldedaten.');
  FDictGerman.Add('ERR_SKU_EXISTS', 'Ein Artikel mit dieser Artikelnummer existiert bereits.');
  FDictGerman.Add('ERR_SAME_WAREHOUSE', 'Quell- und Ziellager dürfen nicht identisch sein.');
  FDictGerman.Add('MSG_ORDER_COMPLETED', 'Verkaufsauftrag erfolgreich ausgeführt und Warenausgang gebucht.');
  FDictGerman.Add('MSG_GOODS_RECEIVED', 'Wareneingang erfolgreich verbucht und Lagerbestand aktualisiert.');
  FDictGerman.Add('MSG_TRANSFER_SUCCESS', 'Umlagerung zwischen Lagern erfolgreich durchgeführt.');
  FDictGerman.Add('MSG_STOCK_ADJUSTED', 'Lagerbestand erfolgreich korrigiert.');

  // --- ENGLISH ---
  FDictEnglish.Add('APP_TITLE', 'Warenfluss – Inventory & Order Management');
  FDictEnglish.Add('NAV_DASHBOARD', 'Dashboard');
  FDictEnglish.Add('NAV_PRODUCTS', 'Products');
  FDictEnglish.Add('NAV_INVENTORY', 'Inventory');
  FDictEnglish.Add('NAV_STOCK_TRANSFER', 'Stock Transfer');
  FDictEnglish.Add('NAV_SALES_ORDERS', 'Sales Orders');
  FDictEnglish.Add('NAV_PURCHASE_ORDERS', 'Purchase Orders');
  FDictEnglish.Add('NAV_SUPPLIERS', 'Suppliers');
  FDictEnglish.Add('NAV_CUSTOMERS', 'Customers');
  FDictEnglish.Add('NAV_REPORTS', 'Reports & Analytics');
  FDictEnglish.Add('NAV_AUDIT', 'Audit Log');
  FDictEnglish.Add('NAV_USERS', 'User Management');

  // Actions
  FDictEnglish.Add('BTN_SAVE', 'Save');
  FDictEnglish.Add('BTN_CANCEL', 'Cancel');
  FDictEnglish.Add('BTN_NEW', 'New');
  FDictEnglish.Add('BTN_EDIT', 'Edit');
  FDictEnglish.Add('BTN_DELETE', 'Delete');
  FDictEnglish.Add('BTN_REFRESH', 'Refresh');
  FDictEnglish.Add('BTN_CLOSE', 'Close');
  FDictEnglish.Add('BTN_SEARCH', 'Search');
  FDictEnglish.Add('BTN_LOGIN', 'Log In');
  FDictEnglish.Add('BTN_LOGOUT', 'Log Out');
  FDictEnglish.Add('BTN_CONFIRM_ORDER', 'Confirm Order');
  FDictEnglish.Add('BTN_COMPLETE_ORDER', 'Complete Order / Dispatch Stock');
  FDictEnglish.Add('BTN_CANCEL_ORDER', 'Cancel Order');
  FDictEnglish.Add('BTN_RECEIVE_GOODS', 'Receive Goods');
  FDictEnglish.Add('BTN_ADJUST_STOCK', 'Stock Adjustment');
  FDictEnglish.Add('BTN_TRANSFER_STOCK', 'Transfer Stock');

  // Fields
  FDictEnglish.Add('FIELD_SKU', 'SKU');
  FDictEnglish.Add('FIELD_BARCODE', 'Barcode / EAN');
  FDictEnglish.Add('FIELD_NAME', 'Name / Description');
  FDictEnglish.Add('FIELD_CATEGORY', 'Category');
  FDictEnglish.Add('FIELD_UNIT_PRICE', 'Unit Price');
  FDictEnglish.Add('FIELD_COST_PRICE', 'Cost Price');
  FDictEnglish.Add('FIELD_CURRENT_STOCK', 'Current Stock');
  FDictEnglish.Add('FIELD_MIN_STOCK', 'Min Stock');
  FDictEnglish.Add('FIELD_WAREHOUSE', 'Warehouse');
  FDictEnglish.Add('FIELD_QUANTITY', 'Quantity');
  FDictEnglish.Add('FIELD_CUSTOMER', 'Customer');
  FDictEnglish.Add('FIELD_SUPPLIER', 'Supplier');
  FDictEnglish.Add('FIELD_ORDER_DATE', 'Order Date');
  FDictEnglish.Add('FIELD_STATUS', 'Status');
  FDictEnglish.Add('FIELD_TOTAL', 'Total');
  FDictEnglish.Add('FIELD_USERNAME', 'Username');
  FDictEnglish.Add('FIELD_PASSWORD', 'Password');
  FDictEnglish.Add('FIELD_REASON', 'Reason / Notes');

  // Domain Exceptions & Messages
  FDictEnglish.Add('ERR_INSUFFICIENT_STOCK', 'There is not enough stock available.');
  FDictEnglish.Add('ERR_PRODUCT_NOT_FOUND', 'Product not found.');
  FDictEnglish.Add('ERR_INVALID_STATUS', 'Invalid order status for this operation.');
  FDictEnglish.Add('ERR_UNAUTHORIZED', 'Access denied or invalid credentials.');
  FDictEnglish.Add('ERR_SKU_EXISTS', 'A product with this SKU already exists.');
  FDictEnglish.Add('ERR_SAME_WAREHOUSE', 'Source and destination warehouses cannot be the same.');
  FDictEnglish.Add('MSG_ORDER_COMPLETED', 'Sales order completed and stock dispatched successfully.');
  FDictEnglish.Add('MSG_GOODS_RECEIVED', 'Goods receipt booked and warehouse stock updated.');
  FDictEnglish.Add('MSG_TRANSFER_SUCCESS', 'Stock transfer completed successfully.');
  FDictEnglish.Add('MSG_STOCK_ADJUSTED', 'Stock level adjusted successfully.');
end;

function TLocalizationManager.Translate(const AKey, ADefault: string): string;
var
  Dict: TDictionary<string, string>;
begin
  if FCurrentLanguage = langGerman then
    Dict := FDictGerman
  else
    Dict := FDictEnglish;

  if not Dict.TryGetValue(AKey, Result) then
  begin
    if ADefault <> '' then
      Result := ADefault
    else
      Result := AKey;
  end;
end;

function TLocalizationManager.FormatCurrency(AValue: Currency): string;
begin
  if FCurrentLanguage = langGerman then
    Result := System.SysUtils.Format('%.2f €', [AValue])
  else
    Result := System.SysUtils.Format('$%.2f', [AValue]);
end;

function TLocalizationManager.FormatQuantity(AValue: Double; const AUnit: string): string;
begin
  if AUnit <> '' then
    Result := System.SysUtils.Format('%.2f %s', [AValue, AUnit])
  else
    Result := System.SysUtils.Format('%.2f', [AValue]);
end;

function TLocalizationManager.FormatDate(ADate: TDateTime): string;
begin
  if FCurrentLanguage = langGerman then
    DateTimeToString(Result, 'dd.mm.yyyy hh:nn', ADate)
  else
    DateTimeToString(Result, 'yyyy-mm-dd hh:nn', ADate);
end;

function _(const AKey: string; const ADefault: string = ''): string;
begin
  Result := TLocalizationManager.Instance.Translate(AKey, ADefault);
end;

function FormatMoney(AAmount: Currency): string;
begin
  Result := TLocalizationManager.Instance.FormatCurrency(AAmount);
end;

function FormatQty(AQty: Double; const AUnit: string = ''): string;
begin
  Result := TLocalizationManager.Instance.FormatQuantity(AQty, AUnit);
end;

initialization

finalization
  TLocalizationManager.FreeInstance;

end.
