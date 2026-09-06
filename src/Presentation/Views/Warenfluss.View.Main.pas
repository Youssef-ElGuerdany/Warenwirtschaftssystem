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
  Warenfluss.View.Products;

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
    FViewModel:   TMainViewModel;
    FProductVM:   TProductViewModel;
    FProductSvc:  IProductService;
    FCategorySvc: ICategoryService;
    procedure UpdateLocalization;
    procedure OnViewModelChanged;
  public
    constructor CreateWithViewModel(AOwner: TComponent; AViewModel: TMainViewModel;
      AProductSvc: IProductService; ACategorySvc: ICategoryService); reintroduce;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

constructor TfrmMain.CreateWithViewModel(AOwner: TComponent; AViewModel: TMainViewModel;
  AProductSvc: IProductService; ACategorySvc: ICategoryService);
begin
  inherited Create(AOwner);
  FViewModel    := AViewModel;
  FProductSvc   := AProductSvc;
  FCategorySvc  := ACategorySvc;
  if Assigned(FViewModel) then
    FViewModel.OnChanged := OnViewModelChanged;
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
end;

procedure TfrmMain.btnNavInventoryClick(Sender: TObject);
begin
  // Inventory warehouse view
end;

procedure TfrmMain.btnNavSalesOrdersClick(Sender: TObject);
begin
  // Sales orders workflow view
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
