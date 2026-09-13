unit Warenfluss.View.Main;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Graphics,
  Warenfluss.Types,
  Warenfluss.Localization,
  Warenfluss.DTOs.Auth,
  Warenfluss.Interfaces.Services,
  Warenfluss.ViewModel.Main,
  Warenfluss.ViewModel.Product,
  Warenfluss.ViewModel.Inventory,
  Warenfluss.ViewModel.SalesOrder,
  Warenfluss.View.Products,
  Warenfluss.View.Inventory,
  Warenfluss.View.SalesOrders;

type
  TfrmMain = class(TForm)
    pnlSidebar: TPanel;
    pnlHeader: TPanel;
    pnlContent: TPanel;
    lblBrand: TLabel;
    lblTagline: TLabel;
    btnNavDashboard: TButton;
    btnNavProducts: TButton;
    btnNavInventory: TButton;
    btnNavSalesOrders: TButton;
    btnNavPurchaseOrders: TButton;
    btnNavReports: TButton;
    btnNavAudit: TButton;
    lblUserStatus: TLabel;
    btnLanguageToggle: TButton;
    pnlDashboardView: TPanel;
    lblDashTitle: TLabel;
    pnlKpiProducts: TPanel;
    lblKpiProdVal: TLabel;
    lblKpiProdLbl: TLabel;
    pnlKpiLowStock: TPanel;
    lblKpiLowStockVal: TLabel;
    lblKpiLowStockLbl: TLabel;
    pnlKpiSales: TPanel;
    lblKpiSalesVal: TLabel;
    lblKpiSalesLbl: TLabel;
    pnlKpiValuation: TPanel;
    lblKpiValuationVal: TLabel;
    lblKpiValuationLbl: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnNavDashboardClick(Sender: TObject);
    procedure btnNavProductsClick(Sender: TObject);
    procedure btnNavInventoryClick(Sender: TObject);
    procedure btnNavSalesOrdersClick(Sender: TObject);
    procedure btnNavPurchaseOrdersClick(Sender: TObject);
    procedure btnNavReportsClick(Sender: TObject);
    procedure btnNavAuditClick(Sender: TObject);
    procedure btnLanguageToggleClick(Sender: TObject);
  private
    FViewModel:        TMainViewModel;
    FProductVM:        TProductViewModel;
    FInventoryVM:      TInventoryViewModel;
    FSalesOrderVM:     TSalesOrderViewModel;  { Lazily created on first navigation }
    FProductSvc:       IProductService;
    FCategorySvc:      ICategoryService;
    FInventorySvc:     IInventoryService;
    FStockTransferSvc: IStockTransferService;
    FWarehouseSvc:     IWarehouseService;
    FSalesSvc:         ISalesOrderService;   { Sales-order service (CRUD + lifecycle) }
    FCustSvc:          ICustomerService;     { Customer master for orders dropdown }
    procedure UpdateLocalization;
    procedure OnViewModelChanged;
  public
    /// <summary>
    ///   Primary constructor – injects the main ViewModel and all service
    ///   dependencies needed by the child views.
    /// </summary>
    constructor CreateWithViewModel(AOwner: TComponent; AViewModel: TMainViewModel;
      AProductSvc: IProductService; ACategorySvc: ICategoryService;
      AInventorySvc: IInventoryService = nil; AStockTransferSvc: IStockTransferService = nil;
      AWarehouseSvc: IWarehouseService = nil;
      ASalesSvc: ISalesOrderService = nil;
      ACustSvc:  ICustomerService = nil); reintroduce;

    /// <summary>
    ///   Binds all service references after the form has been created via
    ///   Application.CreateForm (which bypasses the constructor).
    ///   Called from Warenfluss.dpr immediately after form creation.
    /// </summary>
    procedure InitServices(AViewModel: TMainViewModel;
      AProductSvc: IProductService; ACategorySvc: ICategoryService;
      AInventorySvc: IInventoryService; AStockTransferSvc: IStockTransferService;
      AWarehouseSvc: IWarehouseService;
      ASalesSvc: ISalesOrderService = nil;
      ACustSvc:  ICustomerService = nil);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

{ ============================================================
  Constructor
  Purpose: Wire services through to InitServices so the form
           works identically whether constructed directly or via
           Application.CreateForm + InitServices.
  ============================================================ }

constructor TfrmMain.CreateWithViewModel(AOwner: TComponent; AViewModel: TMainViewModel;
  AProductSvc: IProductService; ACategorySvc: ICategoryService;
  AInventorySvc: IInventoryService; AStockTransferSvc: IStockTransferService;
  AWarehouseSvc: IWarehouseService;
  ASalesSvc: ISalesOrderService; ACustSvc: ICustomerService);
begin
  inherited Create(AOwner);
  InitServices(AViewModel, AProductSvc, ACategorySvc, AInventorySvc,
               AStockTransferSvc, AWarehouseSvc, ASalesSvc, ACustSvc);
end;

{ ============================================================
  InitServices
  Purpose: Store all injected service references and subscribe
           the form to the ViewModel's OnChanged notification.
           Child ViewModels are created lazily on first navigation
           to keep startup time low.
  ============================================================ }

procedure TfrmMain.InitServices(AViewModel: TMainViewModel;
  AProductSvc: IProductService; ACategorySvc: ICategoryService;
  AInventorySvc: IInventoryService; AStockTransferSvc: IStockTransferService;
  AWarehouseSvc: IWarehouseService;
  ASalesSvc: ISalesOrderService; ACustSvc: ICustomerService);
begin
  FViewModel        := AViewModel;
  FProductSvc       := AProductSvc;
  FCategorySvc      := ACategorySvc;
  FInventorySvc     := AInventorySvc;
  FStockTransferSvc := AStockTransferSvc;
  FWarehouseSvc     := AWarehouseSvc;
  FSalesSvc         := ASalesSvc;  { Sales-order service for the orders view }
  FCustSvc          := ACustSvc;   { Customer service shared with orders view }

  if Assigned(FViewModel) then
  begin
    FViewModel.OnChanged := OnViewModelChanged;
    FViewModel.RefreshDashboard;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  UpdateLocalization;
  if Assigned(FViewModel) then
    FViewModel.RefreshDashboard;
end;

procedure TfrmMain.UpdateLocalization;
begin
  Caption := _('APP_TITLE', 'Warenfluss – Lager- und Auftragsverwaltung');
  lblBrand.Caption := 'WARENFLUSS';
  lblTagline.Caption := 'Enterprise Architecture';
  btnNavDashboard.Caption := _('NAV_DASHBOARD', 'Dashboard');
  btnNavProducts.Caption := _('NAV_PRODUCTS', 'Artikelstamm');
  btnNavInventory.Caption := _('NAV_INVENTORY', 'Lagerbestand');
  btnNavSalesOrders.Caption := _('NAV_SALES_ORDERS', 'Verkaufsaufträge');
  btnNavPurchaseOrders.Caption := _('NAV_PURCHASE_ORDERS', 'Einkaufsbestellungen');
  btnNavReports.Caption := _('NAV_REPORTS', 'Berichte & Auswertung');
  btnNavAudit.Caption := _('NAV_AUDIT', 'Audit-Log');

  lblDashTitle.Caption := _('NAV_DASHBOARD', 'Dashboard') + ' – Übersicht';
  lblKpiProdLbl.Caption := 'Artikel gesamt';
  lblKpiLowStockLbl.Caption := 'Meldebestand unterschritten';
  lblKpiSalesLbl.Caption := 'Offene Verkaufsaufträge';
  lblKpiValuationLbl.Caption := 'Lagergesamtwert (EK)';

  if TLocalizationManager.Instance.CurrentLanguage = langGerman then
    btnLanguageToggle.Caption := 'Sprache: Deutsch (DE)'
  else
    btnLanguageToggle.Caption := 'Language: English (EN)';
end;

procedure TfrmMain.OnViewModelChanged;
begin
  if not Assigned(FViewModel) then Exit;
  lblKpiProdVal.Caption := IntToStr(FViewModel.Dashboard.TotalProductsCount);
  lblKpiLowStockVal.Caption := IntToStr(FViewModel.Dashboard.LowStockAlertCount);
  lblKpiSalesVal.Caption := IntToStr(FViewModel.Dashboard.PendingSalesOrdersCount);
  lblKpiValuationVal.Caption := FormatMoney(FViewModel.Dashboard.TotalStockValuation);

  if FViewModel.CurrentUser.ID > 0 then
    lblUserStatus.Caption := Format('Angemeldet: %s (%s)', [FViewModel.CurrentUser.FullName, FViewModel.CurrentUser.RoleName])
  else
    lblUserStatus.Caption := 'Angemeldet: Administrator';
end;

procedure TfrmMain.btnNavDashboardClick(Sender: TObject);
begin
  if Assigned(FViewModel) then FViewModel.RefreshDashboard;
end;

procedure TfrmMain.btnNavProductsClick(Sender: TObject);
var
  ProductsDlg: TfrmProducts;
begin
  { Build ViewModel lazily (once), reuse across navigations }
  if not Assigned(FProductVM) then
    FProductVM := TProductViewModel.Create(FProductSvc, FCategorySvc);

  ProductsDlg := TfrmProducts.CreateWithViewModel(Self, FProductVM);
  try
    ProductsDlg.ShowModal;
  finally
    ProductsDlg.Free;
  end;

  if Assigned(FViewModel) then
    FViewModel.RefreshDashboard;
end;

procedure TfrmMain.btnNavInventoryClick(Sender: TObject);
var
  InventoryDlg: TfrmInventory;
begin
  if not Assigned(FInventoryVM) then
    FInventoryVM := TInventoryViewModel.Create(FInventorySvc, FStockTransferSvc, FWarehouseSvc);

  InventoryDlg := TfrmInventory.CreateWithViewModel(Self, FInventoryVM);
  try
    InventoryDlg.ShowModal;
  finally
    InventoryDlg.Free;
  end;

  if Assigned(FViewModel) then
    FViewModel.RefreshDashboard;
end;

{ ============================================================
  btnNavSalesOrdersClick
  Purpose: Open the Sales Orders view as a modal dialog.
           The ViewModel is created lazily the first time the
           user navigates here and reused on subsequent visits
           so cached master data (customers, products) is kept.
  ============================================================ }

procedure TfrmMain.btnNavSalesOrdersClick(Sender: TObject);
var
  SalesDlg: TfrmSalesOrders;
begin
  { Create the SalesOrder ViewModel once and reuse it across
    repeated navigations to the orders screen }
  if not Assigned(FSalesOrderVM) then
    FSalesOrderVM := TSalesOrderViewModel.Create(
      FSalesSvc,      { ISalesOrderService – CRUD + lifecycle operations }
      FCustSvc,       { ICustomerService   – customer master dropdown }
      FWarehouseSvc,  { IWarehouseService  – dispatch warehouse dropdown }
      FProductSvc);   { IProductService    – article picker in order lines }

  SalesDlg := TfrmSalesOrders.CreateWithViewModel(Self, FSalesOrderVM);
  try
    SalesDlg.ShowModal;
  finally
    SalesDlg.Free;
  end;

  { Refresh the dashboard so the "Offene Verkaufsauftraege" KPI
    reflects any changes made in the orders view }
  if Assigned(FViewModel) then
    FViewModel.RefreshDashboard;
end;

procedure TfrmMain.btnNavPurchaseOrdersClick(Sender: TObject);
begin
  // Purchase orders view
end;

procedure TfrmMain.btnNavReportsClick(Sender: TObject);
begin
  // Reports view
end;

procedure TfrmMain.btnNavAuditClick(Sender: TObject);
begin
  // Audit trail view
end;

procedure TfrmMain.btnLanguageToggleClick(Sender: TObject);
begin
  if TLocalizationManager.Instance.CurrentLanguage = langGerman then
    TLocalizationManager.Instance.CurrentLanguage := langEnglish
  else
    TLocalizationManager.Instance.CurrentLanguage := langGerman;

  UpdateLocalization;
  if Assigned(FViewModel) then FViewModel.RefreshDashboard;
end;

end.
