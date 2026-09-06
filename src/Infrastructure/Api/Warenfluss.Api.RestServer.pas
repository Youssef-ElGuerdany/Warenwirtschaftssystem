unit Warenfluss.Api.RestServer;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes,
  mormot.core.base,
  mormot.core.unicode,
  mormot.core.text,
  mormot.core.json,
  mormot.core.variants,
  mormot.core.os,
  mormot.net.http,
  mormot.net.server,
  mormot.orm.core,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.DTOs.Auth,
  Warenfluss.DTOs.Product,
  Warenfluss.DTOs.Inventory,
  Warenfluss.DTOs.Order,
  Warenfluss.DTOs.Report,
  Warenfluss.Interfaces.Services,
  Warenfluss.Api.ErrorMapper;

type
  TWarenflussRestServer = class
  private
    FPort: string;
    FHttpServer: THttpServer;
    FAuthService: IAuthenticationService;
    FProductService: IProductService;
    FInventoryService: IInventoryService;
    FStockTransferService: IStockTransferService;
    FSalesOrderService: ISalesOrderService;
    FPurchaseOrderService: IPurchaseOrderService;
    FReportService: IReportService;

    function HandleRequest(Ctxt: THttpServerRequestAbstract): Cardinal;
    function ProcessAuthLogin(const ABody: RawUtf8): RawUtf8;
    function ProcessProductsList: RawUtf8;
    function ProcessStockList: RawUtf8;
    function ProcessDashboard: RawUtf8;
  public
    constructor Create(
      const APort: string;
      AAuth: IAuthenticationService;
      AProduct: IProductService;
      AInventory: IInventoryService;
      ATransfer: IStockTransferService;
      ASales: ISalesOrderService;
      APurchase: IPurchaseOrderService;
      AReport: IReportService
    );
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
  end;

implementation

constructor TWarenflussRestServer.Create(
  const APort: string;
  AAuth: IAuthenticationService;
  AProduct: IProductService;
  AInventory: IInventoryService;
  ATransfer: IStockTransferService;
  ASales: ISalesOrderService;
  APurchase: IPurchaseOrderService;
  AReport: IReportService);
begin
  inherited Create;
  FPort := APort;
  FAuthService := AAuth;
  FProductService := AProduct;
  FInventoryService := AInventory;
  FStockTransferService := ATransfer;
  FSalesOrderService := ASales;
  FPurchaseOrderService := APurchase;
  FReportService := AReport;
end;

destructor TWarenflussRestServer.Destroy;
begin
  Stop;
  inherited Destroy;
end;

procedure TWarenflussRestServer.Start;
begin
  if FHttpServer = nil then
  begin
    FHttpServer := THttpServer.Create(
      StringToUtf8(FPort),
      nil,
      nil,
      'WarenflussServer'
    );
    FHttpServer.OnRequest := HandleRequest;
  end;
end;

procedure TWarenflussRestServer.Stop;
begin
  FreeAndNil(FHttpServer);
end;

function TWarenflussRestServer.ProcessAuthLogin(const ABody: RawUtf8): RawUtf8;
var
  Req: TLoginRequestDTO;
  Resp: TLoginResponseDTO;
  V: variant;
begin
  V := _Json(ABody);
  Req.Username := Utf8ToString(RawUtf8(V.username));
  Req.Password := Utf8ToString(RawUtf8(V.password));
  Req.ClientIP := '127.0.0.1';

  Resp := FAuthService.Login(Req);
  if Resp.Success then
    Result := FormatUtf8(
      '{"success":true,"userId":%,"username":"%","fullName":"%","role":"%","token":"%"}',
      [Resp.UserID, StringToUtf8(Resp.Username), StringToUtf8(Resp.FullName),
       StringToUtf8(Resp.RoleName), StringToUtf8(Resp.Token)]
    )
  else
    Result := FormatUtf8(
      '{"success":false,"message":"%"}',
      [StringToUtf8(Resp.ErrorMessage)]
    );
end;

function TWarenflussRestServer.ProcessProductsList: RawUtf8;
var
  Prods: TArray<TProductDTO>;
  I: Integer;
  Buf: RawUtf8;
begin
  Prods := FProductService.GetAllProducts(True);
  Buf := '{"success":true,"count":' + RawUtf8(IntToStr(Length(Prods))) + ',"products":[';
  for I := 0 to High(Prods) do
  begin
    if I > 0 then Buf := Buf + ',';
    Buf := Buf + FormatUtf8('{"id":%,"sku":"%","name":"%","costPrice":%,"unitPrice":%,"currentStock":%,"minStock":%}',
      [Prods[I].ID, StringToUtf8(Prods[I].SKU), StringToUtf8(Prods[I].Name),
       Double(Prods[I].CostPrice), Double(Prods[I].UnitPrice), Prods[I].CurrentStockTotal, Prods[I].MinStockLevel]);
  end;
  Buf := Buf + ']}';
  Result := Buf;
end;

function TWarenflussRestServer.ProcessStockList: RawUtf8;
var
  Items: TArray<TStockItemDTO>;
  I: Integer;
  Buf: RawUtf8;
begin
  Items := FInventoryService.GetAllStockItems;
  Buf := '{"success":true,"count":' + RawUtf8(IntToStr(Length(Items))) + ',"stock":[';
  for I := 0 to High(Items) do
  begin
    if I > 0 then Buf := Buf + ',';
    Buf := Buf + FormatUtf8('{"id":%,"productId":%,"sku":"%","warehouseId":%,"warehouse":"%","qty":%,"availQty":%}',
      [Items[I].ID, Items[I].ProductID, StringToUtf8(Items[I].ProductSKU),
       Items[I].WarehouseID, StringToUtf8(Items[I].WarehouseName), Items[I].Quantity, Items[I].AvailableQuantity]);
  end;
  Buf := Buf + ']}';
  Result := Buf;
end;

function TWarenflussRestServer.ProcessDashboard: RawUtf8;
var
  Dash: TDashboardSummaryDTO;
begin
  Dash := FReportService.GetDashboardSummary;
  Result := FormatUtf8(
    '{"success":true,"totalProducts":%,"lowStockAlerts":%,"pendingSalesOrders":%,"pendingPurchaseOrders":%,"totalValuation":%,"monthlySales":%}',
    [Dash.TotalProductsCount, Dash.LowStockAlertCount, Dash.PendingSalesOrdersCount,
     Dash.PendingPurchaseOrdersCount, Double(Dash.TotalStockValuation), Double(Dash.MonthlySalesVolume)]
  );
end;

function TWarenflussRestServer.HandleRequest(Ctxt: THttpServerRequestAbstract): Cardinal;
var
  Url: RawUtf8;
  Method: RawUtf8;
  RespJson: RawUtf8;
begin
  Url := Ctxt.Url;
  Method := Ctxt.Method;
  Ctxt.OutContentType := JSON_CONTENT_TYPE;

  try
    if (Url = '/api/auth/login') and (Method = 'POST') then
    begin
      RespJson := ProcessAuthLogin(Ctxt.InContent);
      Ctxt.OutContent := RespJson;
      Result := 200;
    end
    else if (Url = '/api/products') and (Method = 'GET') then
    begin
      RespJson := ProcessProductsList;
      Ctxt.OutContent := RespJson;
      Result := 200;
    end
    else if (Url = '/api/inventory/stock') and (Method = 'GET') then
    begin
      RespJson := ProcessStockList;
      Ctxt.OutContent := RespJson;
      Result := 200;
    end
    else if (Url = '/api/reports/dashboard') and (Method = 'GET') then
    begin
      RespJson := ProcessDashboard;
      Ctxt.OutContent := RespJson;
      Result := 200;
    end
    else
    begin
      Ctxt.OutContent := '{"success":false,"error":"ENDPOINT_NOT_FOUND"}';
      Result := 404;
    end;
  except
    on E: Exception do
    begin
      Ctxt.OutContent := TApiErrorMapper.MapException(E).ToJson;
      Result := TApiErrorMapper.MapException(E).StatusCode;
    end;
  end;
end;

end.
