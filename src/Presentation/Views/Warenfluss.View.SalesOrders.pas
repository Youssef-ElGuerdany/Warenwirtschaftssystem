unit Warenfluss.View.SalesOrders;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

/// <summary>
///   View unit for the Verkaufsaufträge (Sales Orders) screen.
///
///   This form provides the complete workflow for managing customer sales orders:
///
///   LIST VIEW:
///     A report-style TListView displays all orders with columns for order
///     number, customer, warehouse, dates, status, position count and totals.
///     The user can search orders by number or customer name.
///
///   EDITOR PANEL (right-side slide-in, "New order" mode only):
///     When the user clicks "Neu", a side panel opens allowing them to:
///       - Select a customer from the master combo-box
///       - Select a dispatch warehouse
///       - Set the required delivery date
///       - Add/remove order lines (article, quantity, unit price, discount)
///       - View a live-calculated sub-total / tax / grand total
///       - Save (creates a Draft order) or Cancel
///
///   LIFECYCLE TOOLBAR ACTIONS:
///     - Bestätigen  (Confirm)   : sosDraft     → sosConfirmed
///     - Abschließen (Complete)  : sosConfirmed  → sosCompleted
///     - Stornieren  (Cancel)    : sosDraft/Confirmed → sosCancelled
///
///   FOOTER / KPI BAR:
///     Displays the count of loaded orders, total open order value and a
///     status/feedback message updated after every ViewModel operation.
///
///   ARCHITECTURE:
///     The form follows the existing Warenfluss MVVM pattern:
///       TfrmSalesOrders ──(uses)──► TSalesOrderViewModel
///                                          │
///                                          ▼
///                               ISalesOrderService  (domain operations)
///                               ICustomerService    (customer master data)
///                               IWarehouseService   (warehouse master data)
///                               IProductService     (article picker)
///
///   COMMENTS CONVENTION:
///     - Section dividers  : { ======… } blocks above each logical group
///     - XML-doc comments  : /// <summary> … </summary> on public members
///     - Inline comments   : { … }  explaining the "why", not just the "what"
/// </summary>
interface

uses
  System.SysUtils, System.Classes,
  System.UITypes,           // Required for MessageDlg overload resolution (H2443)
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Graphics, Vcl.Dialogs,
  Warenfluss.Types,
  Warenfluss.Localization,
  Warenfluss.DTOs.Order,
  Warenfluss.DTOs.Product,
  Warenfluss.ViewModel.SalesOrder;

type
  /// <summary>
  ///   Tracks which mode the editor side-panel is currently in.
  ///   <c>eamNone</c> means the panel is hidden.
  /// </summary>
  TSalesOrderEditorMode = (eamNone, eamNew);

  /// <summary>
  ///   Main Sales-Orders view form.
  ///   Always create via <c>CreateWithViewModel</c> – never use the default
  ///   Delphi constructor, as the form requires an injected ViewModel to
  ///   function correctly.
  /// </summary>
  TfrmSalesOrders = class(TForm)

    { ════════════════════════════════════════════════════════════════════
      Main layout panels
      ════════════════════════════════════════════════════════════════════ }
    pnlToolbar: TPanel;    // Fixed top bar: title + action buttons
    pnlFooter:  TPanel;    // Fixed bottom bar: KPI summary
    splEditor:  TSplitter; // Drag-handle between list and editor panel
    pnlEditor:  TPanel;    // Right-side slide-in editor for new orders
    pnlList:    TPanel;    // Central area hosting the orders list-view

    { ════════════════════════════════════════════════════════════════════
      Toolbar controls
      ════════════════════════════════════════════════════════════════════ }
    lblViewTitle:  TLabel;   // "Verkaufsaufträge" heading
    edtSearch:     TEdit;    // Free-text filter (order nr, customer)
    btnSearch:     TButton;  // Trigger search
    btnNew:        TButton;  // Open editor in "New order" mode
    btnConfirm:    TButton;  // Confirm selected Draft order
    btnComplete:   TButton;  // Complete selected Confirmed order
    btnCancelOrder:TButton;  // Cancel selected Draft / Confirmed order
    btnRefresh:    TButton;  // Reload orders from service

    { ════════════════════════════════════════════════════════════════════
      Orders list-view (central panel)
      ════════════════════════════════════════════════════════════════════ }
    lvOrders: TListView;   // Multi-column report list of all orders

    { ════════════════════════════════════════════════════════════════════
      Footer / KPI summary bar
      ════════════════════════════════════════════════════════════════════ }
    lblSummaryCount:      TLabel;  // "Aufträge: N"
    lblSummaryOpenValue:  TLabel;  // "Offener Wert: €X"
    lblStatusMessage:     TLabel;  // Feedback line (success / error)

    { ════════════════════════════════════════════════════════════════════
      Editor panel – header section
      ════════════════════════════════════════════════════════════════════ }
    pnlEditorHeader:    TPanel;
    lblEditorTitle:     TLabel;   // "Neuen Auftrag anlegen"

    { ════════════════════════════════════════════════════════════════════
      Editor panel – master data section (customer / warehouse / dates)
      ════════════════════════════════════════════════════════════════════ }
    pnlEditorMaster:       TPanel;
    lblEditorCustomer:     TLabel;
    cmbCustomer:           TComboBox;   // Customer picker
    lblEditorWarehouse:    TLabel;
    cmbWarehouse:          TComboBox;   // Dispatch-warehouse picker
    lblEditorRequiredDate: TLabel;
    dtpRequiredDate:       TDateTimePicker;  // Required-delivery date
    lblEditorNotes:        TLabel;
    memNotes:              TMemo;       // Free-text order notes / remarks

    { ════════════════════════════════════════════════════════════════════
      Editor panel – order lines section
      ════════════════════════════════════════════════════════════════════ }
    pnlEditorLines:       TPanel;
    lblEditorLinesTitle:  TLabel;      // "Auftragspositionen"

    { Article picker row (add a new line) }
    lblLineProduct:       TLabel;
    cmbLineProduct:       TComboBox;   // Article / product selection
    lblLineQty:           TLabel;
    edtLineQty:           TEdit;       // Quantity input
    lblLinePrice:         TLabel;
    edtLinePrice:         TEdit;       // Unit price (VK) input
    lblLineDiscount:      TLabel;
    edtLineDiscount:      TEdit;       // Discount % input
    btnAddLine:           TButton;     // Add the row to lvLines
    btnRemoveLine:        TButton;     // Remove selected row from lvLines

    { Order lines list }
    lvLines:              TListView;   // Shows current order-line positions

    { Live totals }
    lblTotalsNetto:       TLabel;      // "Netto: €X"
    lblTotalsTax:         TLabel;      // "MwSt (19 %): €X"
    lblTotalsBrutto:      TLabel;      // "Brutto: €X"

    { ════════════════════════════════════════════════════════════════════
      Editor panel – action buttons (Save / Cancel edit)
      ════════════════════════════════════════════════════════════════════ }
    pnlEditorButtons:  TPanel;
    btnSaveOrder:      TButton;   // Persist the new order
    btnCancelEdit:     TButton;   // Discard changes and hide the panel
    lblEditorStatus:   TLabel;    // Inline validation / error message

    { ════════════════════════════════════════════════════════════════════
      Form event handlers
      ════════════════════════════════════════════════════════════════════ }
    procedure FormCreate(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnConfirmClick(Sender: TObject);
    procedure btnCompleteClick(Sender: TObject);
    procedure btnCancelOrderClick(Sender: TObject);
    procedure lvOrdersSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvOrdersDblClick(Sender: TObject);
    procedure btnAddLineClick(Sender: TObject);
    procedure btnRemoveLineClick(Sender: TObject);
    procedure cmbLineProductChange(Sender: TObject);
    procedure btnSaveOrderClick(Sender: TObject);
    procedure btnCancelEditClick(Sender: TObject);

  private
    { ── ViewModel reference (injected at construction time) ── }
    FViewModel:  TSalesOrderViewModel;

    { ── Current editor state ── }
    FEditorMode:       TSalesOrderEditorMode;  // eamNone or eamNew
    FSelectedOrderDTO: TSalesOrderDTO;         // last clicked row's DTO
    FHasSelection:     Boolean;                // whether a row is selected

    { ── Temporary in-memory list of order lines being built ── }
    FDraftLines: TSalesOrderLineArray;         // lines in the editor

    // ─────────────────────────────────────────────────────────────────
    // ViewModel callback
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Called by the ViewModel's <c>OnChanged</c> event after every
    ///   data-loading or mutation operation.
    ///   Repopulates the list view, footer KPIs and toolbar button states.
    /// </summary>
    procedure OnViewModelChanged;

    // ─────────────────────────────────────────────────────────────────
    // List population helpers
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Clears and rebuilds the <c>lvOrders</c> list from <c>FViewModel.Orders</c>.
    ///   Attempts to restore the previously selected row by ID after the rebuild.
    /// </summary>
    procedure PopulateOrderList;

    /// <summary>
    ///   Fills the <c>cmbCustomer</c> combo-box from <c>FViewModel.Customers</c>.
    ///   Stores the customer entity ID as the object reference for each item.
    /// </summary>
    procedure PopulateCustomerCombo;

    /// <summary>
    ///   Fills <c>cmbWarehouse</c> from <c>FViewModel.Warehouses</c>.
    ///   Stores the warehouse entity ID as the object reference.
    /// </summary>
    procedure PopulateWarehouseCombo;

    /// <summary>
    ///   Fills <c>cmbLineProduct</c> from <c>FViewModel.Products</c>.
    ///   Stores the product entity ID as the object reference.
    ///   Automatically seeds the unit-price field when the user picks a product.
    /// </summary>
    procedure PopulateProductCombo;

    /// <summary>
    ///   Rebuilds <c>lvLines</c> from the in-memory <c>FDraftLines</c> array
    ///   and recalculates the live-total labels (Netto / MwSt / Brutto).
    /// </summary>
    procedure PopulateLinesList;

    // ─────────────────────────────────────────────────────────────────
    // Editor panel show / hide
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Slides in the right-side editor panel, clears all inputs and
    ///   prepopulates combos and the required-date picker with sensible defaults.
    /// </summary>
    procedure ShowEditorPanel;

    /// <summary>
    ///   Hides the editor panel and splitter, clears <c>FDraftLines</c>
    ///   and resets <c>FEditorMode</c> to <c>eamNone</c>.
    /// </summary>
    procedure HideEditorPanel;

    /// <summary>
    ///   Clears all editor input fields back to their initial "blank" state.
    /// </summary>
    procedure ClearEditor;

    // ─────────────────────────────────────────────────────────────────
    // Totals calculation
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Iterates <c>FDraftLines</c>, calculates each line's total,
    ///   sums them into a Netto, adds 19 % MwSt and updates the label captions.
    ///   Called after every Add-line / Remove-line action.
    /// </summary>
    procedure RecalculateTotals;

    // ─────────────────────────────────────────────────────────────────
    // Validation
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Validates all inputs in the editor panel before the order is saved.
    /// </summary>
    /// <param name="AMsg">
    ///   On failure: a German-language error message describing the first
    ///   problem found.  On success: empty string.
    /// </param>
    /// <returns><c>True</c> when all inputs are valid; <c>False</c> otherwise.</returns>
    function ValidateNewOrder(out AMsg: string): Boolean;

    // ─────────────────────────────────────────────────────────────────
    // DTO assembly
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Reads all editor controls and assembles a <c>TSalesOrderCreateDTO</c>
    ///   ready to be passed to <c>FViewModel.CreateOrder</c>.
    ///   Assumes <c>ValidateNewOrder</c> has already returned <c>True</c>.
    /// </summary>
    function BuildCreateDTO: TSalesOrderCreateDTO;

    // ─────────────────────────────────────────────────────────────────
    // Toolbar & footer state
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Enables / disables toolbar action buttons based on whether a row is
    ///   selected and what status that order currently has.
    ///   Rules:
    ///     btnConfirm  – enabled only when selected order is sosDraft
    ///     btnComplete – enabled only when selected order is sosConfirmed
    ///     btnCancelOrder – enabled for sosDraft or sosConfirmed
    /// </summary>
    procedure UpdateToolbarState;

    /// <summary>
    ///   Updates the footer KPI labels (order count and total open value).
    ///   "Open value" is the sum of TotalAmount for all Draft + Confirmed orders.
    /// </summary>
    procedure UpdateSummaryBar;

    // ─────────────────────────────────────────────────────────────────
    // Selection helper
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Looks up the currently selected list-view row and finds the
    ///   matching <c>TSalesOrderDTO</c> in the ViewModel's Orders array.
    /// </summary>
    /// <param name="ADTO">
    ///   On success: the fully populated DTO of the selected order.
    ///   On failure: undefined – always test the return value first.
    /// </param>
    /// <returns><c>True</c> if a valid row is selected; <c>False</c> otherwise.</returns>
    function GetSelectedOrder(out ADTO: TSalesOrderDTO): Boolean;

    // ─────────────────────────────────────────────────────────────────
    // Display helpers
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Converts a <c>TSalesOrderStatus</c> enum value to a German display
    ///   string suitable for the list-view Status column.
    ///   Returns 'Entwurf', 'Bestätigt', 'Abgeschlossen' or 'Storniert'.
    /// </summary>
    function StatusToDisplayString(AStatus: TSalesOrderStatus): string;

    /// <summary>
    ///   Sets the caption of <c>lblStatusMessage</c> in the footer, using
    ///   green for success messages and red for error messages.
    /// </summary>
    /// <param name="AMsg">Message text to display.</param>
    /// <param name="AIsError"><c>True</c> = red font; <c>False</c> = green font.</param>
    procedure SetStatusMessage(const AMsg: string; AIsError: Boolean = False);

    /// <summary>
    ///   Applies German UI strings to all captions and text-hints.
    ///   Called once from <c>FormCreate</c>.
    /// </summary>
    procedure UpdateLocalization;

  public
    /// <summary>
    ///   The only valid way to instantiate this form.
    ///   Wires the ViewModel's <c>OnChanged</c> callback so the form
    ///   automatically refreshes whenever the data changes.
    /// </summary>
    /// <param name="AOwner">VCL owner component (typically <c>frmMain</c>).</param>
    /// <param name="AViewModel">
    ///   Fully constructed <c>TSalesOrderViewModel</c>.
    ///   Must not be <c>nil</c>.
    /// </param>
    constructor CreateWithViewModel(AOwner: TComponent;
                                    AViewModel: TSalesOrderViewModel); reintroduce;
  end;

var
  frmSalesOrders: TfrmSalesOrders;

implementation

{$R *.dfm}

{ ============================================================
  Constructor
  Purpose: Store the ViewModel reference and register the
           OnChanged callback before the form's VCL internals
           are fully initialised.
  ============================================================ }

constructor TfrmSalesOrders.CreateWithViewModel(AOwner: TComponent;
                                                AViewModel: TSalesOrderViewModel);
begin
  inherited Create(AOwner);
  FViewModel   := AViewModel;
  FEditorMode  := eamNone;
  FHasSelection := False;

  { Wire the ViewModel's change-notification so the view repaints
    whenever data is loaded or mutated }
  if Assigned(FViewModel) then
    FViewModel.OnChanged := OnViewModelChanged;
end;

{ ============================================================
  FormCreate
  Purpose: One-time setup performed after the DFM has been
           loaded and all controls exist on-screen:
           - Apply German captions
           - Configure the two list-views (columns, style)
           - Pre-fill the line-input fields with defaults
           - Trigger the first data-load from the ViewModel
  ============================================================ }

procedure TfrmSalesOrders.FormCreate(Sender: TObject);
begin
  UpdateLocalization;
  HideEditorPanel;

  { ── Configure the orders list-view ── }
  lvOrders.ViewStyle   := vsReport;
  lvOrders.RowSelect   := True;
  lvOrders.ReadOnly    := True;
  lvOrders.GridLines   := True;
  lvOrders.MultiSelect := False;

  lvOrders.Columns.Clear;
  with lvOrders.Columns.Add do begin Caption := 'Auftragsnr.';    Width := 110; end;
  with lvOrders.Columns.Add do begin Caption := 'Kunde';          Width := 180; end;
  with lvOrders.Columns.Add do begin Caption := 'Lager';          Width := 120; end;
  with lvOrders.Columns.Add do begin Caption := 'Auftragsdatum';  Width := 110; end;
  with lvOrders.Columns.Add do begin Caption := 'Lieferdatum';    Width := 110; end;
  with lvOrders.Columns.Add do begin Caption := 'Status';         Width :=  95; end;
  with lvOrders.Columns.Add do begin Caption := 'Positionen';     Width :=  75; Alignment := taRightJustify; end;
  with lvOrders.Columns.Add do begin Caption := 'Netto';          Width :=  95; Alignment := taRightJustify; end;
  with lvOrders.Columns.Add do begin Caption := 'MwSt';           Width :=  85; Alignment := taRightJustify; end;
  with lvOrders.Columns.Add do begin Caption := 'Brutto';         Width := 100; Alignment := taRightJustify; end;
  with lvOrders.Columns.Add do begin Caption := 'Erstellt von';   Width := 110; end;

  { ── Configure the order-lines list inside the editor ── }
  lvLines.ViewStyle   := vsReport;
  lvLines.RowSelect   := True;
  lvLines.ReadOnly    := True;
  lvLines.GridLines   := True;
  lvLines.MultiSelect := False;

  lvLines.Columns.Clear;
  with lvLines.Columns.Add do begin Caption := 'Artikel';    Width := 180; end;
  with lvLines.Columns.Add do begin Caption := 'Menge';      Width :=  65; Alignment := taRightJustify; end;
  with lvLines.Columns.Add do begin Caption := 'VK-Preis';   Width :=  85; Alignment := taRightJustify; end;
  with lvLines.Columns.Add do begin Caption := 'Rabatt %';   Width :=  65; Alignment := taRightJustify; end;
  with lvLines.Columns.Add do begin Caption := 'Zeile';      Width :=  90; Alignment := taRightJustify; end;

  { ── Sensible defaults for the line-input row ── }
  edtLineQty.Text      := '1';
  edtLineDiscount.Text := '0';

  { ── Set required-delivery date default to today + 3 days ── }
  dtpRequiredDate.Date := Now + 3;

  { ── Initialise draft-lines to an empty array ── }
  SetLength(FDraftLines, 0);

  UpdateToolbarState;

  { ── Load data from the service via the ViewModel ── }
  if Assigned(FViewModel) then
    FViewModel.LoadOrders;
end;

{ ============================================================
  UpdateLocalization
  Purpose: Apply all German UI string literals to form controls.
           Centralises string literals so they are easy to find
           and replace if a second language is added.
  ============================================================ }

procedure TfrmSalesOrders.UpdateLocalization;
begin
  Caption                   := _('NAV_SALES_ORDERS', 'Verkaufsaufträge');
  lblViewTitle.Caption      := _('NAV_SALES_ORDERS', 'Verkaufsaufträge');
  edtSearch.TextHint        := 'Suchen (Auftragsnr., Kundenname …)';
  btnSearch.Caption         := _('BTN_SEARCH', 'Suchen');
  btnNew.Caption            := _('BTN_NEW', 'Neu');
  btnConfirm.Caption        := 'Bestätigen';
  btnComplete.Caption       := 'Abschließen';
  btnCancelOrder.Caption    := 'Stornieren';
  btnRefresh.Caption        := _('BTN_REFRESH', 'Aktualisieren');

  { Editor panel labels }
  lblEditorTitle.Caption       := 'Neuen Auftrag anlegen';
  lblEditorCustomer.Caption    := 'Kunde *';
  lblEditorWarehouse.Caption   := 'Lager *';
  lblEditorRequiredDate.Caption:= 'Lieferdatum';
  lblEditorNotes.Caption       := 'Bemerkungen';
  lblEditorLinesTitle.Caption  := 'Auftragspositionen *';
  lblLineProduct.Caption       := 'Artikel';
  lblLineQty.Caption           := 'Menge';
  lblLinePrice.Caption         := 'VK-Preis (€)';
  lblLineDiscount.Caption      := 'Rabatt %';
  btnAddLine.Caption           := '+ Position';
  btnRemoveLine.Caption        := '− Entfernen';
  btnSaveOrder.Caption         := _('BTN_SAVE', 'Speichern');
  btnCancelEdit.Caption        := _('BTN_CANCEL', 'Abbrechen');
end;

{ ============================================================
  OnViewModelChanged
  Purpose: ViewModel fires this whenever data is reloaded.
           The view repopulates everything in a single call.
  ============================================================ }

procedure TfrmSalesOrders.OnViewModelChanged;
begin
  if not Assigned(FViewModel) then Exit;

  PopulateOrderList;
  PopulateCustomerCombo;
  PopulateWarehouseCombo;
  PopulateProductCombo;
  UpdateSummaryBar;
  UpdateToolbarState;

  { Echo any ViewModel-level status text to the footer bar }
  if FViewModel.StatusMessage <> '' then
    SetStatusMessage(FViewModel.StatusMessage);
end;

{ ============================================================
  PopulateOrderList
  Purpose: Rebuild lvOrders from the ViewModel's Orders array.
           The previous selection (by entity ID stored in Item.Data)
           is restored after the rebuild.
  ============================================================ }

procedure TfrmSalesOrders.PopulateOrderList;
var
  I:          Integer;
  O:          TSalesOrderDTO;
  Item:       TListItem;
  PrevSelID:  TEntityID;
  SearchText: string;
begin
  { Remember which order was previously selected }
  PrevSelID  := 0;
  if FHasSelection then
    PrevSelID := FSelectedOrderDTO.ID;

  SearchText := LowerCase(Trim(edtSearch.Text));

  lvOrders.Items.BeginUpdate;
  try
    lvOrders.Items.Clear;
    if not Assigned(FViewModel) then Exit;

    for I := 0 to High(FViewModel.Orders) do
    begin
      O := FViewModel.Orders[I];

      { Apply free-text filter (order number OR customer name) }
      if SearchText <> '' then
        if (Pos(SearchText, LowerCase(O.OrderNumber)) = 0) and
           (Pos(SearchText, LowerCase(O.CustomerName)) = 0) then
          Continue;

      Item         := lvOrders.Items.Add;
      Item.Caption := O.OrderNumber;
      Item.Data    := Pointer(O.ID);  // store ID for reverse lookup

      Item.SubItems.Add(O.CustomerName);
      Item.SubItems.Add(O.WarehouseName);

      { Format dates as DD.MM.YYYY – the German convention }
      if O.OrderDate > 0 then
        Item.SubItems.Add(FormatDateTime('dd.mm.yyyy', O.OrderDate))
      else
        Item.SubItems.Add('—');

      if O.RequiredDate > 0 then
        Item.SubItems.Add(FormatDateTime('dd.mm.yyyy', O.RequiredDate))
      else
        Item.SubItems.Add('—');

      Item.SubItems.Add(StatusToDisplayString(O.Status));
      Item.SubItems.Add(IntToStr(Length(O.Lines)));
      Item.SubItems.Add(FormatMoney(O.SubTotal));
      Item.SubItems.Add(FormatMoney(O.TaxAmount));
      Item.SubItems.Add(FormatMoney(O.TotalAmount));
      Item.SubItems.Add(O.CreatedByUsername);

      { Restore previous selection if the entity ID matches }
      if (PrevSelID > 0) and (O.ID = PrevSelID) then
      begin
        Item.Selected := True;
        Item.Focused  := True;
      end;
    end;
  finally
    lvOrders.Items.EndUpdate;
  end;

  UpdateToolbarState;
end;

{ ============================================================
  PopulateCustomerCombo
  Purpose: Rebuild the customer dropdown from master data.
           The entity ID is attached as the Items.Objects[] value
           so we can read it back without a name lookup.
  ============================================================ }

procedure TfrmSalesOrders.PopulateCustomerCombo;
var
  I: Integer;
begin
  cmbCustomer.Items.BeginUpdate;
  try
    cmbCustomer.Items.Clear;
    cmbCustomer.Items.AddObject('— Kunden auswählen —', TObject(0));

    if not Assigned(FViewModel) then Exit;

    for I := 0 to High(FViewModel.Customers) do
      with FViewModel.Customers[I] do
        cmbCustomer.Items.AddObject(
          Format('%s (%s)', [CompanyName, Code]),
          TObject(ID));
  finally
    cmbCustomer.Items.EndUpdate;
  end;

  cmbCustomer.ItemIndex := 0;
end;

{ ============================================================
  PopulateWarehouseCombo
  Purpose: Rebuild the warehouse dropdown from master data.
  ============================================================ }

procedure TfrmSalesOrders.PopulateWarehouseCombo;
var
  I: Integer;
begin
  cmbWarehouse.Items.BeginUpdate;
  try
    cmbWarehouse.Items.Clear;
    cmbWarehouse.Items.AddObject('— Lager auswählen —', TObject(0));

    if not Assigned(FViewModel) then Exit;

    for I := 0 to High(FViewModel.Warehouses) do
      with FViewModel.Warehouses[I] do
        cmbWarehouse.Items.AddObject(
          Format('%s (%s)', [Name, Code]),
          TObject(ID));
  finally
    cmbWarehouse.Items.EndUpdate;
  end;

  cmbWarehouse.ItemIndex := 0;
end;

{ ============================================================
  PopulateProductCombo
  Purpose: Rebuild the article picker for the order-line row.
           Only active products are supplied by the ViewModel.
           The unit price is pre-filled when the user changes
           the selection (see cmbLineProductChange).
  ============================================================ }

procedure TfrmSalesOrders.PopulateProductCombo;
var
  I: Integer;
begin
  cmbLineProduct.Items.BeginUpdate;
  try
    cmbLineProduct.Items.Clear;
    cmbLineProduct.Items.AddObject('— Artikel auswählen —', TObject(0));

    if not Assigned(FViewModel) then Exit;

    for I := 0 to High(FViewModel.Products) do
      with FViewModel.Products[I] do
        cmbLineProduct.Items.AddObject(
          Format('[%s] %s', [SKU, Name]),
          TObject(ID));
  finally
    cmbLineProduct.Items.EndUpdate;
  end;

  cmbLineProduct.ItemIndex := 0;
end;

{ ============================================================
  PopulateLinesList
  Purpose: Sync lvLines to the FDraftLines array and then
           immediately recalculate the live totals.
  ============================================================ }

procedure TfrmSalesOrders.PopulateLinesList;
var
  I:    Integer;
  L:    TSalesOrderLineDTO;
  Item: TListItem;
begin
  lvLines.Items.BeginUpdate;
  try
    lvLines.Items.Clear;

    for I := 0 to High(FDraftLines) do
    begin
      L    := FDraftLines[I];
      Item := lvLines.Items.Add;

      Item.Caption := L.ProductName;
      Item.Data    := Pointer(I);  // store array index for remove operations

      Item.SubItems.Add(FormatQty(L.Quantity));
      Item.SubItems.Add(FormatMoney(L.UnitPrice));

      if L.DiscountPercent > 0 then
        Item.SubItems.Add(Format('%.1f %%', [L.DiscountPercent]))
      else
        Item.SubItems.Add('—');

      Item.SubItems.Add(FormatMoney(L.LineTotal));
    end;
  finally
    lvLines.Items.EndUpdate;
  end;

  { Always recalculate after changing the lines }
  RecalculateTotals;
end;

{ ============================================================
  RecalculateTotals
  Purpose: Sum all line totals, apply the standard 19 % MwSt
           and update the three summary label captions.
           This runs on every add/remove to give the user
           immediate visual feedback on the order value.
  ============================================================ }

procedure TfrmSalesOrders.RecalculateTotals;
var
  I:        Integer;
  Netto:    Currency;
  MwSt:     Currency;
  Brutto:   Currency;
  Gross:    Currency;
  Disc:     Currency;
begin
  Netto := 0;

  for I := 0 to High(FDraftLines) do
  begin
    { Recalculate each line's total in case quantity or price was altered }
    with FDraftLines[I] do
    begin
      Gross := Quantity * UnitPrice;
      Disc  := Gross * (DiscountPercent / 100.0);
      LineTotal := Gross - Disc;
    end;
    Netto := Netto + FDraftLines[I].LineTotal;
  end;

  { 19 % MwSt – fixed rate; in a production system this would be
    configurable per product's tax class }
  MwSt   := Netto * 0.19;
  Brutto := Netto + MwSt;

  lblTotalsNetto.Caption  := Format('Netto: %s',       [FormatMoney(Netto)]);
  lblTotalsTax.Caption    := Format('MwSt (19 %%): %s',[FormatMoney(MwSt)]);
  lblTotalsBrutto.Caption := Format('Brutto: %s',      [FormatMoney(Brutto)]);
end;

{ ============================================================
  ShowEditorPanel
  Purpose: Make the right-side editor panel visible, reset all
           input controls to blank/default values and move focus
           to the customer combo-box so the user can start typing.
  ============================================================ }

procedure TfrmSalesOrders.ShowEditorPanel;
begin
  FEditorMode := eamNew;
  ClearEditor;

  pnlEditor.Visible := True;
  splEditor.Visible := True;

  { The required-date field defaults to today + 3 calendar days.
    This is the same default used by the domain entity constructor. }
  dtpRequiredDate.Date := Now + 3;

  cmbCustomer.SetFocus;
end;

{ ============================================================
  HideEditorPanel
  Purpose: Collapse the side panel, discard draft lines and
           reset the editor mode flag.
  ============================================================ }

procedure TfrmSalesOrders.HideEditorPanel;
begin
  pnlEditor.Visible := False;
  splEditor.Visible := False;
  FEditorMode       := eamNone;

  { Discard any order lines that were being built }
  SetLength(FDraftLines, 0);

  lblEditorStatus.Caption := '';
end;

{ ============================================================
  ClearEditor
  Purpose: Reset all editor input fields to their initial
           "ready for new input" state without hiding the panel.
  ============================================================ }

procedure TfrmSalesOrders.ClearEditor;
begin
  cmbCustomer.ItemIndex      := 0;
  cmbWarehouse.ItemIndex     := 0;
  dtpRequiredDate.Date       := Now + 3;
  memNotes.Clear;

  cmbLineProduct.ItemIndex   := 0;
  edtLineQty.Text            := '1';
  edtLinePrice.Text          := '0,00';
  edtLineDiscount.Text       := '0';

  { Start with an empty lines array }
  SetLength(FDraftLines, 0);
  PopulateLinesList;

  lblEditorStatus.Caption    := '';

  { Reset the live-total labels }
  lblTotalsNetto.Caption  := 'Netto: 0,00 €';
  lblTotalsTax.Caption    := 'MwSt (19 %): 0,00 €';
  lblTotalsBrutto.Caption := 'Brutto: 0,00 €';
end;

{ ============================================================
  ValidateNewOrder
  Purpose: Check all editor fields before the order is saved.
           Returns False and fills AMsg with the first error found.
           The sequence of checks follows the logical input flow
           (customer first, then warehouse, then order lines).
  ============================================================ }

function TfrmSalesOrders.ValidateNewOrder(out AMsg: string): Boolean;
begin
  Result := False;

  { 1 – A customer must be selected }
  if (cmbCustomer.ItemIndex <= 0) or
     (TEntityID(cmbCustomer.Items.Objects[cmbCustomer.ItemIndex]) = 0) then
  begin
    AMsg := 'Bitte einen Kunden auswählen.';
    cmbCustomer.SetFocus;
    Exit;
  end;

  { 2 – A warehouse must be selected }
  if (cmbWarehouse.ItemIndex <= 0) or
     (TEntityID(cmbWarehouse.Items.Objects[cmbWarehouse.ItemIndex]) = 0) then
  begin
    AMsg := 'Bitte ein Lager auswählen.';
    cmbWarehouse.SetFocus;
    Exit;
  end;

  { 3 – The required-delivery date must be today or in the future }
  if Trunc(dtpRequiredDate.Date) < Trunc(Now) then
  begin
    AMsg := 'Das Lieferdatum darf nicht in der Vergangenheit liegen.';
    dtpRequiredDate.SetFocus;
    Exit;
  end;

  { 4 – At least one order line must exist }
  if Length(FDraftLines) = 0 then
  begin
    AMsg := 'Der Auftrag muss mindestens eine Position enthalten.';
    cmbLineProduct.SetFocus;
    Exit;
  end;

  Result := True;
  AMsg   := '';
end;

{ ============================================================
  BuildCreateDTO
  Purpose: Assemble a TSalesOrderCreateDTO from the editor
           controls.  Called only after ValidateNewOrder = True.
  ============================================================ }

function TfrmSalesOrders.BuildCreateDTO: TSalesOrderCreateDTO;
begin
  FillChar(Result, SizeOf(Result), 0);

  Result.CustomerID   := TEntityID(cmbCustomer.Items.Objects[cmbCustomer.ItemIndex]);
  Result.WarehouseID  := TEntityID(cmbWarehouse.Items.Objects[cmbWarehouse.ItemIndex]);
  Result.RequiredDate := dtpRequiredDate.Date;
  Result.Notes        := Trim(memNotes.Text);
  Result.Lines        := FDraftLines;  // shallow copy of the array is sufficient here
end;

{ ============================================================
  UpdateToolbarState
  Purpose: Reflect the current selection state in the toolbar.
           Called after every list-view selection change and
           after every ViewModel data reload.
  ============================================================ }

procedure TfrmSalesOrders.UpdateToolbarState;
var
  HasSel: Boolean;
begin
  HasSel := GetSelectedOrder(FSelectedOrderDTO);
  FHasSelection := HasSel;

  { Action buttons only make sense when a row is selected }
  btnConfirm.Enabled    := HasSel and (FSelectedOrderDTO.Status = sosDraft);
  btnComplete.Enabled   := HasSel and (FSelectedOrderDTO.Status = sosConfirmed);
  btnCancelOrder.Enabled:= HasSel and
                           (FSelectedOrderDTO.Status in [sosDraft, sosConfirmed]);
end;

{ ============================================================
  UpdateSummaryBar
  Purpose: Recount orders and sum the open (Draft + Confirmed)
           order value for the footer KPI labels.
  ============================================================ }

procedure TfrmSalesOrders.UpdateSummaryBar;
var
  I:         Integer;
  OpenValue: Currency;
begin
  if not Assigned(FViewModel) then Exit;

  OpenValue := 0;
  for I := 0 to High(FViewModel.Orders) do
    if FViewModel.Orders[I].Status in [sosDraft, sosConfirmed] then
      OpenValue := OpenValue + FViewModel.Orders[I].TotalAmount;

  lblSummaryCount.Caption     :=
    Format('Aufträge: %d', [Length(FViewModel.Orders)]);
  lblSummaryOpenValue.Caption :=
    Format('Offener Wert: %s', [FormatMoney(OpenValue)]);
end;

{ ============================================================
  GetSelectedOrder
  Purpose: Translate the selected ListView item into the
           corresponding TSalesOrderDTO stored in the ViewModel.
           The entity ID is stored in Item.Data (set during
           PopulateOrderList) to avoid a name-string comparison.
  ============================================================ }

function TfrmSalesOrders.GetSelectedOrder(out ADTO: TSalesOrderDTO): Boolean;
var
  Item: TListItem;
  ID:   TEntityID;
  I:    Integer;
begin
  Result := False;
  FillChar(ADTO, SizeOf(ADTO), 0);

  Item := lvOrders.Selected;
  if (Item = nil) or not Assigned(FViewModel) then Exit;

  ID := TEntityID(Item.Data);

  for I := 0 to High(FViewModel.Orders) do
    if FViewModel.Orders[I].ID = ID then
    begin
      ADTO   := FViewModel.Orders[I];
      Result := True;
      Exit;
    end;
end;

{ ============================================================
  StatusToDisplayString
  Purpose: Convert the TSalesOrderStatus enum to a human-
           readable German label for the list-view column.
  ============================================================ }

function TfrmSalesOrders.StatusToDisplayString(AStatus: TSalesOrderStatus): string;
begin
  case AStatus of
    sosDraft:     Result := 'Entwurf';
    sosConfirmed: Result := 'Bestätigt';
    sosCompleted: Result := 'Abgeschlossen';
    sosCancelled: Result := 'Storniert';
  else
    Result := '—';
  end;
end;

{ ============================================================
  SetStatusMessage
  Purpose: Update the footer feedback label with an appropriate
           font colour so the user can tell success from error
           at a glance.
  ============================================================ }

procedure TfrmSalesOrders.SetStatusMessage(const AMsg: string; AIsError: Boolean);
begin
  lblStatusMessage.Caption := AMsg;

  if AIsError then
    lblStatusMessage.Font.Color := clRed
  else
    lblStatusMessage.Font.Color := clGreen;
end;

{ ============================================================
  Toolbar event handlers
  ============================================================ }

procedure TfrmSalesOrders.btnSearchClick(Sender: TObject);
begin
  { Re-render the list applying the current search text as a filter.
    No service round-trip is needed because we filter client-side. }
  PopulateOrderList;
end;

procedure TfrmSalesOrders.edtSearchKeyDown(Sender: TObject; var Key: Word;
                                            Shift: TShiftState);
begin
  { Allow pressing Enter as a shortcut for the Search button }
  if Key = 13 then
    btnSearchClick(Sender);
end;

procedure TfrmSalesOrders.btnRefreshClick(Sender: TObject);
begin
  { Clear the search box and reload everything from the service }
  edtSearch.Clear;
  lblStatusMessage.Caption := '';
  if Assigned(FViewModel) then
    FViewModel.LoadOrders;
end;

{ ── New Order ─────────────────────────────────────────────── }

procedure TfrmSalesOrders.btnNewClick(Sender: TObject);
begin
  ShowEditorPanel;
end;

{ ── Confirm ───────────────────────────────────────────────── }

procedure TfrmSalesOrders.btnConfirmClick(Sender: TObject);
var
  DTO: TSalesOrderDTO;
  Res: TOperationResult;
begin
  if not GetSelectedOrder(DTO) then Exit;

  { Require the user to acknowledge the action }
  if MessageDlg(
       Format('Auftrag "%s" an Kunde "%s" wirklich bestätigen?'#13#10 +
              'Die Lagerbestände werden reserviert.',
              [DTO.OrderNumber, DTO.CustomerName]),
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  if Assigned(FViewModel) then
  begin
    { Pass UserID = 0 here; in production this comes from the session.
      The service records the UserID in the audit log. }
    Res := FViewModel.ConfirmOrder(DTO.ID, 0);

    if Res.Success then
      SetStatusMessage(Format('Auftrag %s erfolgreich bestätigt.', [DTO.OrderNumber]))
    else
      SetStatusMessage('Fehler: ' + Res.Message, True);
  end;
end;

{ ── Complete ──────────────────────────────────────────────── }

procedure TfrmSalesOrders.btnCompleteClick(Sender: TObject);
var
  DTO: TSalesOrderDTO;
  Res: TOperationResult;
begin
  if not GetSelectedOrder(DTO) then Exit;

  if MessageDlg(
       Format('Auftrag "%s" als abgeschlossen markieren?'#13#10 +
              'Der Warenausgang wird im Lager gebucht.',
              [DTO.OrderNumber]),
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  if Assigned(FViewModel) then
  begin
    Res := FViewModel.CompleteOrder(DTO.ID, 0);

    if Res.Success then
      SetStatusMessage(Format('Auftrag %s abgeschlossen.', [DTO.OrderNumber]))
    else
      SetStatusMessage('Fehler: ' + Res.Message, True);
  end;
end;

{ ── Cancel Order ──────────────────────────────────────────── }

procedure TfrmSalesOrders.btnCancelOrderClick(Sender: TObject);
var
  DTO: TSalesOrderDTO;
  Res: TOperationResult;
begin
  if not GetSelectedOrder(DTO) then Exit;

  { Stornierung is irreversible – warn the user clearly }
  if MessageDlg(
       Format('Auftrag "%s" wirklich stornieren?'#13#10 +
              'Diese Aktion kann nicht rückgängig gemacht werden.',
              [DTO.OrderNumber]),
       mtWarning, [mbYes, mbNo], 0) <> mrYes then Exit;

  if Assigned(FViewModel) then
  begin
    Res := FViewModel.CancelOrder(DTO.ID, 0);

    if Res.Success then
      SetStatusMessage(Format('Auftrag %s storniert.', [DTO.OrderNumber]))
    else
      SetStatusMessage('Fehler: ' + Res.Message, True);
  end;
end;

{ ============================================================
  List-view selection handlers
  ============================================================ }

procedure TfrmSalesOrders.lvOrdersSelectItem(Sender: TObject;
                                              Item: TListItem; Selected: Boolean);
begin
  UpdateToolbarState;
end;

procedure TfrmSalesOrders.lvOrdersDblClick(Sender: TObject);
begin
  { Double-click on a Draft order is a shortcut for "Bestätigen" }
  if FHasSelection and (FSelectedOrderDTO.Status = sosDraft) then
    btnConfirmClick(Sender);
end;

{ ============================================================
  Order-line editor handlers
  ============================================================ }

procedure TfrmSalesOrders.cmbLineProductChange(Sender: TObject);
var
  ProductID: TEntityID;
  I:         Integer;
begin
  { When the user picks an article, pre-fill the unit-price field
    with the article's standard sales price (VK-Preis) so that the
    most common case requires no further input }
  if cmbLineProduct.ItemIndex <= 0 then Exit;

  ProductID := TEntityID(cmbLineProduct.Items.Objects[cmbLineProduct.ItemIndex]);

  if not Assigned(FViewModel) then Exit;

  for I := 0 to High(FViewModel.Products) do
    if FViewModel.Products[I].ID = ProductID then
    begin
      edtLinePrice.Text := Format('%.2f', [Double(FViewModel.Products[I].UnitPrice)]);
      Break;
    end;
end;

procedure TfrmSalesOrders.btnAddLineClick(Sender: TObject);
var
  ProductID:  TEntityID;
  ProductSKU: string;
  ProductName:string;
  Qty:        Double;
  Price:      Currency;
  Discount:   Double;
  NewLine:    TSalesOrderLineDTO;
  I:          Integer;
  PriceStr:   string;
  QtyStr:     string;
  DiscStr:    string;
begin
  { ── Validate the line input fields before adding ── }

  if cmbLineProduct.ItemIndex <= 0 then
  begin
    ShowMessage('Bitte einen Artikel auswählen.');
    cmbLineProduct.SetFocus;
    Exit;
  end;

  QtyStr := StringReplace(Trim(edtLineQty.Text), ',', '.', [rfReplaceAll]);
  Qty    := StrToFloatDef(QtyStr, 0);
  if Qty <= 0 then
  begin
    ShowMessage('Menge muss größer als 0 sein.');
    edtLineQty.SetFocus;
    Exit;
  end;

  PriceStr := StringReplace(Trim(edtLinePrice.Text), ',', '.', [rfReplaceAll]);
  Price    := StrToCurrDef(PriceStr, -1);
  if Price < 0 then
  begin
    ShowMessage('Verkaufspreis ist ungültig.');
    edtLinePrice.SetFocus;
    Exit;
  end;

  DiscStr  := StringReplace(Trim(edtLineDiscount.Text), ',', '.', [rfReplaceAll]);
  Discount := StrToFloatDef(DiscStr, 0);
  if (Discount < 0) or (Discount > 100) then
  begin
    ShowMessage('Rabatt muss zwischen 0 und 100 % liegen.');
    edtLineDiscount.SetFocus;
    Exit;
  end;

  { ── Look up the product name & SKU from the ViewModel ── }
  ProductID   := TEntityID(cmbLineProduct.Items.Objects[cmbLineProduct.ItemIndex]);
  ProductName := '';
  ProductSKU  := '';

  for I := 0 to High(FViewModel.Products) do
    if FViewModel.Products[I].ID = ProductID then
    begin
      ProductName := FViewModel.Products[I].Name;
      ProductSKU  := FViewModel.Products[I].SKU;
      Break;
    end;

  { ── Build the line record and append it to the draft array ── }
  FillChar(NewLine, SizeOf(NewLine), 0);
  NewLine.ProductID      := ProductID;
  NewLine.ProductSKU     := ProductSKU;
  NewLine.ProductName    := ProductName;
  NewLine.Quantity       := Qty;
  NewLine.UnitPrice      := Price;
  NewLine.DiscountPercent:= Discount;

  { Calculate the line total immediately }
  NewLine.LineTotal := (Qty * Price) * (1.0 - Discount / 100.0);

  SetLength(FDraftLines, Length(FDraftLines) + 1);
  FDraftLines[High(FDraftLines)] := NewLine;

  { ── Refresh the lines list and totals ── }
  PopulateLinesList;

  { ── Reset the input row for the next line ── }
  cmbLineProduct.ItemIndex := 0;
  edtLineQty.Text          := '1';
  edtLinePrice.Text        := '0,00';
  edtLineDiscount.Text     := '0';
  cmbLineProduct.SetFocus;
end;

procedure TfrmSalesOrders.btnRemoveLineClick(Sender: TObject);
var
  SelItem: TListItem;
  Idx:     Integer;
  I:       Integer;
begin
  SelItem := lvLines.Selected;
  if SelItem = nil then
  begin
    ShowMessage('Bitte eine Position markieren, die entfernt werden soll.');
    Exit;
  end;

  { The item's Data field stores the array index (set in PopulateLinesList) }
  Idx := Integer(SelItem.Data);

  if (Idx < 0) or (Idx > High(FDraftLines)) then Exit;

  { Remove the element at position Idx by shifting subsequent elements left }
  for I := Idx to High(FDraftLines) - 1 do
    FDraftLines[I] := FDraftLines[I + 1];

  SetLength(FDraftLines, Length(FDraftLines) - 1);

  { Rebuild the list-view and recalculate totals }
  PopulateLinesList;
end;

{ ============================================================
  Editor Save / Cancel
  ============================================================ }

procedure TfrmSalesOrders.btnSaveOrderClick(Sender: TObject);
var
  ErrMsg:    string;
  CreateDTO: TSalesOrderCreateDTO;
  Res:       TOperationResult;
begin
  { ── Input validation ── }
  if not ValidateNewOrder(ErrMsg) then
  begin
    lblEditorStatus.Caption    := ErrMsg;
    lblEditorStatus.Font.Color := clRed;
    Exit;
  end;

  { ── Assemble the DTO and call the ViewModel ── }
  CreateDTO := BuildCreateDTO;

  if Assigned(FViewModel) then
  begin
    Res := FViewModel.CreateOrder(CreateDTO, 0 {UserID – replace with session ID});

    if Res.Success then
    begin
      SetStatusMessage(Format('Neuer Auftrag erfolgreich angelegt (ID %d).',
                              [Res.AffectedID]));
      HideEditorPanel;
    end
    else
    begin
      lblEditorStatus.Caption    := 'Fehler: ' + Res.Message;
      lblEditorStatus.Font.Color := clRed;
    end;
  end;
end;

procedure TfrmSalesOrders.btnCancelEditClick(Sender: TObject);
begin
  { Discard the draft and close the editor without any prompt.
    Drafts are not persisted until "Speichern" is clicked. }
  HideEditorPanel;
end;

end.
