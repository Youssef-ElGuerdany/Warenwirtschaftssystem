unit Warenfluss.View.Inventory;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Graphics, Vcl.Dialogs,
  Warenfluss.Types,
  Warenfluss.Localization,
  Warenfluss.DTOs.Inventory,
  Warenfluss.DTOs.Product,
  Warenfluss.ViewModel.Inventory;

type
  TInventoryActionMode = (iamNone, iamAdjust, iamTransfer);

  TfrmInventory = class(TForm)
    { --- Main Layout Panels --- }
    pnlToolbar: TPanel;
    pnlFooter:  TPanel;
    splAction:  TSplitter;
    pnlAction:  TPanel;
    pnlMain:    TPanel;

    { --- Toolbar Controls --- }
    lblViewTitle:       TLabel;
    lblWarehouseFilter: TLabel;
    cmbWarehouseFilter: TComboBox;
    edtSearch:          TEdit;
    btnSearch:          TButton;
    btnAdjust:          TButton;
    btnTransfer:        TButton;
    btnRefresh:         TButton;

    { --- Central PageControl & Tabs --- }
    pgcInventory: TPageControl;
    tsStock:      TTabSheet;
    tsMovements:  TTabSheet;
    lvStock:      TListView;
    lvMovements:  TListView;

    { --- Movements Sub-Toolbar --- }
    pnlMovementsTop:            TPanel;
    btnRefreshMovements:        TButton;
    chkFilterMovementByProduct: TCheckBox;
    lblMovementsInfo:           TLabel;

    { --- Footer / Summary Bar --- }
    lblSummaryPositions:  TLabel;
    lblSummaryTotalQty:   TLabel;
    lblSummaryTotalValue: TLabel;
    lblStatusMessage:     TLabel;

    { --- Action Side-Panel (Adjustment / Transfer) --- }
    pnlActionHeader:        TPanel;
    lblActionTitle:         TLabel;
    lblActionProdHeader:    TLabel;
    lblActionProdName:      TLabel;
    lblActionSKUHeader:     TLabel;
    lblActionSKUVal:        TLabel;

    { Adjustment controls }
    pnlAdjustGroup:         TPanel;
    lblAdjustWHHeader:      TLabel;
    lblAdjustWHVal:         TLabel;
    lblAdjustCurrentHeader: TLabel;
    lblAdjustCurrentVal:    TLabel;
    lblAdjustDeltaHeader:   TLabel;
    edtAdjustDelta:         TEdit;
    lblAdjustResultHeader:  TLabel;
    lblAdjustResultVal:     TLabel;
    lblAdjustReasonHeader:  TLabel;
    cmbAdjustReason:        TComboBox;
    edtAdjustReasonNote:    TEdit;

    { Transfer controls }
    pnlTransferGroup:       TPanel;
    lblTransferSrcWHHeader: TLabel;
    lblTransferSrcWHVal:    TLabel;
    lblTransferAvailHeader: TLabel;
    lblTransferAvailVal:    TLabel;
    lblTransferTgtWHHeader: TLabel;
    cmbTransferTgtWH:       TComboBox;
    lblTransferQtyHeader:   TLabel;
    edtTransferQty:         TEdit;
    lblTransferReasonHeader:TLabel;
    edtTransferReasonNote:  TEdit;

    { Action buttons }
    pnlActionButtons:       TPanel;
    btnExecuteAction:       TButton;
    btnCancelAction:        TButton;
    lblActionFeedback:      TLabel;

    { --- Form Event Handlers --- }
    procedure FormCreate(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cmbWarehouseFilterChange(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnAdjustClick(Sender: TObject);
    procedure btnTransferClick(Sender: TObject);
    procedure lvStockSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvStockDblClick(Sender: TObject);

    procedure btnRefreshMovementsClick(Sender: TObject);
    procedure chkFilterMovementByProductClick(Sender: TObject);
    procedure pgcInventoryChange(Sender: TObject);

    procedure edtAdjustDeltaChange(Sender: TObject);
    procedure edtTransferQtyChange(Sender: TObject);
    procedure btnExecuteActionClick(Sender: TObject);
    procedure btnCancelActionClick(Sender: TObject);

  private
    FViewModel:   TInventoryViewModel;
    FActionMode:  TInventoryActionMode;
    FSelectedDTO: TStockItemDTO;
    FHasSelected: Boolean;

    procedure OnViewModelChanged;
    procedure PopulateStockList;
    procedure PopulateMovementsList;
    procedure PopulateWarehouseFilter;
    procedure UpdateSummaryBar;
    procedure UpdateToolbarState;
    procedure UpdateLocalization;

    procedure ShowAdjustmentPanel;
    procedure ShowTransferPanel;
    procedure HideActionPanel;
    procedure UpdateAdjustmentCalculations;

    function  GetSelectedStock(out ADTO: TStockItemDTO): Boolean;
    function  ValidateAdjustment(out AMsg: string; out ADelta: Double; out AReason: string): Boolean;
    function  ValidateTransfer(out AMsg: string; out ATgtWH: TEntityID; out AQty: Double; out AReason: string): Boolean;

  public
    constructor CreateWithViewModel(AOwner: TComponent; AViewModel: TInventoryViewModel); reintroduce;
  end;

var
  frmInventory: TfrmInventory;

implementation

{$R *.dfm}

{ ============================================================
  Constructor
  ============================================================ }

constructor TfrmInventory.CreateWithViewModel(AOwner: TComponent;
  AViewModel: TInventoryViewModel);
begin
  inherited Create(AOwner);
  FViewModel   := AViewModel;
  FActionMode  := iamNone;
  FHasSelected := False;

  if Assigned(FViewModel) then
    FViewModel.OnChanged := OnViewModelChanged;
end;

{ ============================================================
  Form Create & Init
  ============================================================ }

procedure TfrmInventory.FormCreate(Sender: TObject);
begin
  UpdateLocalization;
  HideActionPanel;

  { Configure Stock ListView }
  lvStock.ViewStyle   := vsReport;
  lvStock.RowSelect   := True;
  lvStock.ReadOnly    := True;
  lvStock.GridLines   := True;
  lvStock.MultiSelect := False;

  lvStock.Columns.Clear;
  with lvStock.Columns.Add do begin Caption := _('FIELD_SKU', 'SKU');                  Width := 110; end;
  with lvStock.Columns.Add do begin Caption := _('FIELD_NAME', 'Artikelbezeichnung');  Width := 210; end;
  with lvStock.Columns.Add do begin Caption := _('FIELD_WAREHOUSE', 'Lager');          Width := 140; end;
  with lvStock.Columns.Add do begin Caption := _('FIELD_STOCK', 'Bestand');            Width :=  90; Alignment := taRightJustify; end;
  with lvStock.Columns.Add do begin Caption := 'Reserviert';                           Width :=  85; Alignment := taRightJustify; end;
  with lvStock.Columns.Add do begin Caption := 'Verfügbar';                            Width :=  85; Alignment := taRightJustify; end;
  with lvStock.Columns.Add do begin Caption := _('FIELD_COST_PRICE', 'EK-Preis');      Width :=  90; Alignment := taRightJustify; end;
  with lvStock.Columns.Add do begin Caption := 'Gesamtwert';                           Width := 105; Alignment := taRightJustify; end;
  with lvStock.Columns.Add do begin Caption := 'Status';                               Width :=  80; end;

  { Configure Movements ListView }
  lvMovements.ViewStyle   := vsReport;
  lvMovements.RowSelect   := True;
  lvMovements.ReadOnly    := True;
  lvMovements.GridLines   := True;
  lvMovements.MultiSelect := False;

  lvMovements.Columns.Clear;
  with lvMovements.Columns.Add do begin Caption := 'Datum & Zeit';        Width := 130; end;
  with lvMovements.Columns.Add do begin Caption := 'Bewegungsart';        Width := 125; end;
  with lvMovements.Columns.Add do begin Caption := 'SKU';                 Width :=  95; end;
  with lvMovements.Columns.Add do begin Caption := 'Artikel';             Width := 170; end;
  with lvMovements.Columns.Add do begin Caption := 'Lager / Von';         Width := 120; end;
  with lvMovements.Columns.Add do begin Caption := 'Nach Lager';          Width := 120; end;
  with lvMovements.Columns.Add do begin Caption := 'Menge';               Width :=  75; Alignment := taRightJustify; end;
  with lvMovements.Columns.Add do begin Caption := 'EK-Kosten';           Width :=  85; Alignment := taRightJustify; end;
  with lvMovements.Columns.Add do begin Caption := 'Beleg / Ref';         Width :=  95; end;
  with lvMovements.Columns.Add do begin Caption := 'Grund / Bemerkung';   Width := 160; end;
  with lvMovements.Columns.Add do begin Caption := 'Benutzer';            Width :=  90; end;

  { Default Reason dropdown entries }
  cmbAdjustReason.Items.Clear;
  cmbAdjustReason.Items.Add('Inventurdifferenz');
  cmbAdjustReason.Items.Add('Bruch / Schwund / Beschädigung');
  cmbAdjustReason.Items.Add('Korrektur Wareneingang');
  cmbAdjustReason.Items.Add('Korrektur Warenausgang');
  cmbAdjustReason.Items.Add('Muster / Eigenverbrauch');
  cmbAdjustReason.Items.Add('Sonstiges');
  cmbAdjustReason.ItemIndex := 0;

  pgcInventory.ActivePageIndex := 0;
  UpdateToolbarState;

  if Assigned(FViewModel) then
  begin
    FViewModel.LoadStock;
    FViewModel.LoadMovements;
    PopulateWarehouseFilter;
  end;
end;

{ ============================================================
  Localization
  ============================================================ }

procedure TfrmInventory.UpdateLocalization;
begin
  Caption                    := _('NAV_INVENTORY', 'Lagerbestand & Bestandsführung');
  lblViewTitle.Caption       := _('NAV_INVENTORY', 'Lagerbestand');
  lblWarehouseFilter.Caption := _('FIELD_WAREHOUSE', 'Lager:') + ' ';
  edtSearch.TextHint         := _('BTN_SEARCH', 'Suchen') + ' (Artikel, SKU, Lager …)';
  btnSearch.Caption          := _('BTN_SEARCH', 'Suchen');
  btnAdjust.Caption          := 'Bestand anpassen';
  btnTransfer.Caption        := 'Umlagern';
  btnRefresh.Caption         := _('BTN_REFRESH', 'Aktualisieren');

  tsStock.Caption            := 'Bestandsübersicht';
  tsMovements.Caption        := 'Bewegungsprotokoll (Journal)';

  btnRefreshMovements.Caption        := 'Journal aktualisieren';
  chkFilterMovementByProduct.Caption := 'Nur für ausgewählten Artikel filtern';

  btnCancelAction.Caption    := _('BTN_CANCEL', 'Abbrechen');
end;

{ ============================================================
  ViewModel Callback
  ============================================================ }

procedure TfrmInventory.OnViewModelChanged;
begin
  if not Assigned(FViewModel) then Exit;
  PopulateStockList;
  PopulateMovementsList;
  UpdateSummaryBar;
  UpdateToolbarState;
  if FViewModel.StatusMessage <> '' then
    lblStatusMessage.Caption := FViewModel.StatusMessage;
end;

{ ============================================================
  Populate Warehouses Filter
  ============================================================ }

procedure TfrmInventory.PopulateWarehouseFilter;
var
  I: Integer;
begin
  cmbWarehouseFilter.Items.BeginUpdate;
  try
    cmbWarehouseFilter.Items.Clear;
    cmbWarehouseFilter.Items.AddObject('Alle Lager', TObject(0));
    if Assigned(FViewModel) then
    begin
      for I := 0 to High(FViewModel.Warehouses) do
        cmbWarehouseFilter.Items.AddObject(
          Format('%s (%s)', [FViewModel.Warehouses[I].Name, FViewModel.Warehouses[I].Code]),
          TObject(FViewModel.Warehouses[I].ID));
    end;
  finally
    cmbWarehouseFilter.Items.EndUpdate;
  end;
  cmbWarehouseFilter.ItemIndex := 0;
end;

{ ============================================================
  Populate Stock List
  ============================================================ }

procedure TfrmInventory.PopulateStockList;
var
  I: Integer;
  S: TStockItemDTO;
  Item: TListItem;
  PrevSelID: TEntityID;
begin
  PrevSelID := 0;
  if FHasSelected then
    PrevSelID := FSelectedDTO.ID;

  lvStock.Items.BeginUpdate;
  try
    lvStock.Items.Clear;
    if not Assigned(FViewModel) then Exit;

    for I := 0 to High(FViewModel.StockItems) do
    begin
      S := FViewModel.StockItems[I];
      Item := lvStock.Items.Add;

      Item.Caption := S.ProductSKU;
      Item.Data    := Pointer(S.ID);

      Item.SubItems.Add(S.ProductName);
      Item.SubItems.Add(Format('%s (%s)', [S.WarehouseName, S.WarehouseCode]));
      Item.SubItems.Add(FormatQty(S.Quantity));
      Item.SubItems.Add(FormatQty(S.ReservedQuantity));
      Item.SubItems.Add(FormatQty(S.AvailableQuantity));
      Item.SubItems.Add(FormatMoney(S.UnitCost));
      Item.SubItems.Add(FormatMoney(S.TotalValue));

      if S.Quantity <= 0 then
        Item.SubItems.Add('Leer')
      else if S.AvailableQuantity < S.Quantity then
        Item.SubItems.Add('Teilw. reserviert')
      else
        Item.SubItems.Add('Verfügbar');

      if (PrevSelID > 0) and (S.ID = PrevSelID) then
      begin
        Item.Selected := True;
        Item.Focused  := True;
      end;
    end;
  finally
    lvStock.Items.EndUpdate;
  end;

  UpdateToolbarState;
end;

{ ============================================================
  Populate Movements Journal
  ============================================================ }

procedure TfrmInventory.PopulateMovementsList;
var
  I: Integer;
  M: TStockMovementDTO;
  Item: TListItem;
  MoveTypeStr: string;
begin
  lvMovements.Items.BeginUpdate;
  try
    lvMovements.Items.Clear;
    if not Assigned(FViewModel) then Exit;

    for I := 0 to High(FViewModel.Movements) do
    begin
      M := FViewModel.Movements[I];
      Item := lvMovements.Items.Add;

      if M.Timestamp > 0 then
        Item.Caption := FormatDateTime('yyyy-mm-dd hh:nn:ss', M.Timestamp)
      else
        Item.Caption := '-';

      Item.Data := Pointer(M.ID);

      case M.MovementType of
   //     smtGoodsReceipt:      MoveTypeStr := 'Wareneingang (+)';
//        smtGoodsIssue:        MoveTypeStr := 'Warenausgang (-)';
        smtTransferOut:       MoveTypeStr := 'Umlagerung Abgang';
        smtTransferIn:        MoveTypeStr := 'Umlagerung Zugang';
        smtAdjustmentPlus:    MoveTypeStr := 'Korrektur (+)';
        smtAdjustmentMinus:   MoveTypeStr := 'Korrektur (-)';
     //   smtInventoryVariance: MoveTypeStr := 'Inventurdifferenz';
      else
        MoveTypeStr := M.MovementTypeName;
      end;

      Item.SubItems.Add(MoveTypeStr);
      Item.SubItems.Add(M.ProductSKU);
      Item.SubItems.Add(M.ProductName);
      Item.SubItems.Add(M.WarehouseName);

      if M.TargetWarehouseName <> '' then
        Item.SubItems.Add(M.TargetWarehouseName)
      else
        Item.SubItems.Add('—');

    //  if (M.MovementType in [smtGoodsIssue, smtTransferOut, smtAdjustmentMinus]) then
     if (M.MovementType in [ smtTransferOut, smtAdjustmentMinus]) then
        Item.SubItems.Add('-' + FormatQty(M.Quantity))
      else
        Item.SubItems.Add('+' + FormatQty(M.Quantity));

      Item.SubItems.Add(FormatMoney(M.UnitCost));

      if M.ReferenceType <> '' then
        Item.SubItems.Add(Format('%s #%d', [M.ReferenceType, M.ReferenceID]))
      else
        Item.SubItems.Add('—');

      Item.SubItems.Add(M.Reason);

      if M.Username <> '' then
        Item.SubItems.Add(M.Username)
      else if M.UserID > 0 then
        Item.SubItems.Add('User #' + IntToStr(M.UserID))
      else
        Item.SubItems.Add('System');
    end;
  finally
    lvMovements.Items.EndUpdate;
  end;

  lblMovementsInfo.Caption := Format('%d Bewegungen im Protokoll geladen', [Length(FViewModel.Movements)]);
end;

{ ============================================================
  Summary & KPI Bar
  ============================================================ }

procedure TfrmInventory.UpdateSummaryBar;
begin
  if not Assigned(FViewModel) then Exit;

  lblSummaryPositions.Caption  := Format('Positionen: %d', [FViewModel.GetTotalPositionCount]);
  lblSummaryTotalQty.Caption   := Format('Gesamtmenge: %s', [FormatQty(FViewModel.GetTotalQuantity)]);
  lblSummaryTotalValue.Caption := Format('Gesamtlagerwert: %s', [FormatMoney(FViewModel.GetTotalValuation)]);
end;

{ ============================================================
  Toolbar State
  ============================================================ }

procedure TfrmInventory.UpdateToolbarState;
var
  HasSel: Boolean;
begin
  HasSel := GetSelectedStock(FSelectedDTO);
  FHasSelected := HasSel;

  btnAdjust.Enabled   := HasSel;
  btnTransfer.Enabled := HasSel and (FSelectedDTO.AvailableQuantity > 0);
end;

{ ============================================================
  Selected Item Retrieval
  ============================================================ }

function TfrmInventory.GetSelectedStock(out ADTO: TStockItemDTO): Boolean;
var
  Item: TListItem;
  ID: TEntityID;
  I: Integer;
begin
  Result := False;
  Item := lvStock.Selected;
  if (Item = nil) or not Assigned(FViewModel) then Exit;

  ID := TEntityID(Item.Data);
  for I := 0 to High(FViewModel.StockItems) do
    if FViewModel.StockItems[I].ID = ID then
    begin
      ADTO := FViewModel.StockItems[I];
      Exit(True);
    end;
end;

{ ============================================================
  Toolbar Actions
  ============================================================ }

procedure TfrmInventory.btnSearchClick(Sender: TObject);
begin
  if Assigned(FViewModel) then
    FViewModel.Search(Trim(edtSearch.Text));
end;

procedure TfrmInventory.edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
    btnSearchClick(Sender);
end;

procedure TfrmInventory.cmbWarehouseFilterChange(Sender: TObject);
var
  WHID: TEntityID;
begin
  WHID := 0;
  if cmbWarehouseFilter.ItemIndex > 0 then
    WHID := TEntityID(cmbWarehouseFilter.Items.Objects[cmbWarehouseFilter.ItemIndex]);

  if Assigned(FViewModel) then
    FViewModel.FilterByWarehouse(WHID);
end;

procedure TfrmInventory.btnRefreshClick(Sender: TObject);
begin
  edtSearch.Clear;
  if Assigned(FViewModel) then
  begin
    FViewModel.Search('');
    FViewModel.LoadStock;
    FViewModel.LoadMovements;
  end;
end;

procedure TfrmInventory.lvStockSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  UpdateToolbarState;
  if Selected and FHasSelected then
  begin
    if FActionMode = iamAdjust then
      ShowAdjustmentPanel
    else if FActionMode = iamTransfer then
      ShowTransferPanel;

    if chkFilterMovementByProduct.Checked and Assigned(FViewModel) then
      FViewModel.LoadMovements(FSelectedDTO.ProductID);
  end;
end;

procedure TfrmInventory.lvStockDblClick(Sender: TObject);
begin
  btnAdjustClick(Sender);
end;

{ ============================================================
  PageControl & Movements Tab
  ============================================================ }

procedure TfrmInventory.pgcInventoryChange(Sender: TObject);
begin
  if pgcInventory.ActivePage = tsMovements then
  begin
    if chkFilterMovementByProduct.Checked and FHasSelected then
      FViewModel.LoadMovements(FSelectedDTO.ProductID)
    else
      FViewModel.LoadMovements(0);
  end;
end;

procedure TfrmInventory.btnRefreshMovementsClick(Sender: TObject);
begin
  if Assigned(FViewModel) then
  begin
    if chkFilterMovementByProduct.Checked and FHasSelected then
      FViewModel.LoadMovements(FSelectedDTO.ProductID)
    else
      FViewModel.LoadMovements(0);
  end;
end;

procedure TfrmInventory.chkFilterMovementByProductClick(Sender: TObject);
begin
  btnRefreshMovementsClick(Sender);
end;

{ ============================================================
  Side Panel: Adjustment Mode
  ============================================================ }

procedure TfrmInventory.btnAdjustClick(Sender: TObject);
begin
  if not GetSelectedStock(FSelectedDTO) then Exit;
  ShowAdjustmentPanel;
end;

procedure TfrmInventory.ShowAdjustmentPanel;
begin
  FActionMode := iamAdjust;
  pnlAction.Visible := True;
  splAction.Visible := True;

  lblActionTitle.Caption     := 'Bestandskorrektur';
  lblActionProdName.Caption  := FSelectedDTO.ProductName;
  lblActionSKUVal.Caption    := FSelectedDTO.ProductSKU;

  pnlAdjustGroup.Visible   := True;
  pnlTransferGroup.Visible := False;

  lblAdjustWHVal.Caption      := Format('%s (%s)', [FSelectedDTO.WarehouseName, FSelectedDTO.WarehouseCode]);
  lblAdjustCurrentVal.Caption := FormatQty(FSelectedDTO.Quantity);

  edtAdjustDelta.Text := '0';
  edtAdjustReasonNote.Clear;
  lblActionFeedback.Caption := '';

  UpdateAdjustmentCalculations;
  edtAdjustDelta.SetFocus;
end;

procedure TfrmInventory.edtAdjustDeltaChange(Sender: TObject);
begin
  UpdateAdjustmentCalculations;
end;

procedure TfrmInventory.UpdateAdjustmentCalculations;
var
  Delta, CurrentStock, NewStock: Double;
  ValStr: string;
begin
  ValStr := StringReplace(Trim(edtAdjustDelta.Text), ',', '.', [rfReplaceAll]);
  Delta := StrToFloatDef(ValStr, 0);
  CurrentStock := FSelectedDTO.Quantity;
  NewStock := CurrentStock + Delta;

  lblAdjustResultVal.Caption := FormatQty(NewStock);

  if NewStock < 0 then
  begin
    lblAdjustResultVal.Font.Color := clRed;
    lblActionFeedback.Caption    := 'Warnung: Resultierender Bestand darf nicht negativ sein!';
    lblActionFeedback.Font.Color := clRed;
  end
  else if Delta > 0 then
  begin
    lblAdjustResultVal.Font.Color := clGreen;
    lblActionFeedback.Caption    := Format('Zubuchung von %s Einheiten.', [FormatQty(Delta)]);
    lblActionFeedback.Font.Color := clGreen;
  end
  else if Delta < 0 then
  begin
    lblAdjustResultVal.Font.Color := $001A52B8; // Dark Amber
    lblActionFeedback.Caption    := Format('Abbuchung von %s Einheiten.', [FormatQty(Abs(Delta))]);
    lblActionFeedback.Font.Color := $001A52B8;
  end
  else
  begin
    lblAdjustResultVal.Font.Color := clWindowText;
    lblActionFeedback.Caption    := '';
  end;
end;

{ ============================================================
  Side Panel: Transfer Mode
  ============================================================ }

procedure TfrmInventory.btnTransferClick(Sender: TObject);
begin
  if not GetSelectedStock(FSelectedDTO) then Exit;
  ShowTransferPanel;
end;

procedure TfrmInventory.ShowTransferPanel;
var
  I: Integer;
  WH: TWarehouseDTO;
begin
  FActionMode := iamTransfer;
  pnlAction.Visible := True;
  splAction.Visible := True;

  lblActionTitle.Caption    := 'Lagerumbuchung (Transfer)';
  lblActionProdName.Caption := FSelectedDTO.ProductName;
  lblActionSKUVal.Caption   := FSelectedDTO.ProductSKU;

  pnlAdjustGroup.Visible   := False;
  pnlTransferGroup.Visible := True;

  lblTransferSrcWHVal.Caption := Format('%s (%s)', [FSelectedDTO.WarehouseName, FSelectedDTO.WarehouseCode]);
  lblTransferAvailVal.Caption := FormatQty(FSelectedDTO.AvailableQuantity);

  cmbTransferTgtWH.Items.BeginUpdate;
  try
    cmbTransferTgtWH.Items.Clear;
    if Assigned(FViewModel) then
    begin
      for I := 0 to High(FViewModel.Warehouses) do
      begin
        WH := FViewModel.Warehouses[I];
        if WH.ID <> FSelectedDTO.WarehouseID then
          cmbTransferTgtWH.Items.AddObject(
            Format('%s (%s)', [WH.Name, WH.Code]),
            TObject(WH.ID));
      end;
    end;
  finally
    cmbTransferTgtWH.Items.EndUpdate;
  end;

  if cmbTransferTgtWH.Items.Count > 0 then
    cmbTransferTgtWH.ItemIndex := 0;

  edtTransferQty.Text := '1';
  edtTransferReasonNote.Text := 'Umlagerung zwischen Lagern';
  lblActionFeedback.Caption := '';

  edtTransferQty.SetFocus;
end;

procedure TfrmInventory.edtTransferQtyChange(Sender: TObject);
var
  Qty: Double;
  ValStr: string;
begin
  ValStr := StringReplace(Trim(edtTransferQty.Text), ',', '.', [rfReplaceAll]);
  Qty := StrToFloatDef(ValStr, 0);

  if Qty <= 0 then
  begin
    lblActionFeedback.Caption    := 'Transfermenge muss größer als 0 sein.';
    lblActionFeedback.Font.Color := clRed;
  end
  else if Qty > FSelectedDTO.AvailableQuantity then
  begin
    lblActionFeedback.Caption    := Format('Menge überschreitet verfügbaren Bestand (max. %s)!',
      [FormatQty(FSelectedDTO.AvailableQuantity)]);
    lblActionFeedback.Font.Color := clRed;
  end
  else
  begin
    lblActionFeedback.Caption    := Format('Bereit zum Transfer von %s Einheiten.', [FormatQty(Qty)]);
    lblActionFeedback.Font.Color := clGreen;
  end;
end;

procedure TfrmInventory.HideActionPanel;
begin
  pnlAction.Visible := False;
  splAction.Visible := False;
  FActionMode       := iamNone;
  lblActionFeedback.Caption := '';
end;

procedure TfrmInventory.btnCancelActionClick(Sender: TObject);
begin
  HideActionPanel;
end;

{ ============================================================
  Action Validation & Execution
  ============================================================ }

function TfrmInventory.ValidateAdjustment(out AMsg: string; out ADelta: Double;
  out AReason: string): Boolean;
var
  ValStr: string;
begin
  Result := False;
  ValStr := StringReplace(Trim(edtAdjustDelta.Text), ',', '.', [rfReplaceAll]);
  ADelta := StrToFloatDef(ValStr, 0);

  if Abs(ADelta) < 0.0001 then
  begin
    AMsg := 'Bitte eine Anpassungsmenge ungleich 0 eingeben.';
    edtAdjustDelta.SetFocus;
    Exit;
  end;

  if (FSelectedDTO.Quantity + ADelta) < 0 then
  begin
    AMsg := 'Die Bestandsanpassung würde zu einem negativen Lagerbestand führen!';
    edtAdjustDelta.SetFocus;
    Exit;
  end;

  AReason := '';
  if cmbAdjustReason.ItemIndex >= 0 then
    AReason := cmbAdjustReason.Items[cmbAdjustReason.ItemIndex];

  if Trim(edtAdjustReasonNote.Text) <> '' then
  begin
    if AReason <> '' then
      AReason := AReason + ': ' + Trim(edtAdjustReasonNote.Text)
    else
      AReason := Trim(edtAdjustReasonNote.Text);
  end;

  if Trim(AReason) = '' then
    AReason := 'Manuelle Bestandskorrektur';

  Result := True;
  AMsg   := '';
end;

function TfrmInventory.ValidateTransfer(out AMsg: string; out ATgtWH: TEntityID;
  out AQty: Double; out AReason: string): Boolean;
var
  ValStr: string;
begin
  Result := False;
  if cmbTransferTgtWH.ItemIndex < 0 then
  begin
    AMsg := 'Bitte ein Ziellager auswählen.';
    cmbTransferTgtWH.SetFocus;
    Exit;
  end;

  ATgtWH := TEntityID(cmbTransferTgtWH.Items.Objects[cmbTransferTgtWH.ItemIndex]);
  if ATgtWH = FSelectedDTO.WarehouseID then
  begin
    AMsg := 'Quell- und Ziellager dürfen nicht identisch sein.';
    cmbTransferTgtWH.SetFocus;
    Exit;
  end;

  ValStr := StringReplace(Trim(edtTransferQty.Text), ',', '.', [rfReplaceAll]);
  AQty := StrToFloatDef(ValStr, 0);

  if AQty <= 0 then
  begin
    AMsg := 'Bitte eine gültige Transfermenge (> 0) eingeben.';
    edtTransferQty.SetFocus;
    Exit;
  end;

  if AQty > FSelectedDTO.AvailableQuantity then
  begin
    AMsg := Format('Verfügbarer Bestand nicht ausreichend (verfügbar: %s).',
      [FormatQty(FSelectedDTO.AvailableQuantity)]);
    edtTransferQty.SetFocus;
    Exit;
  end;

  AReason := Trim(edtTransferReasonNote.Text);
  if AReason = '' then
    AReason := 'Interne Umlagerung';

  Result := True;
  AMsg   := '';
end;

procedure TfrmInventory.btnExecuteActionClick(Sender: TObject);
var
  ErrMsg, Reason: string;
  Delta, Qty: Double;
  TgtWH: TEntityID;
  OpRes: TOperationResult;
  UserID: TEntityID;
begin
  if not Assigned(FViewModel) then Exit;
  UserID := FViewModel.CurrentUserID;
  if UserID <= 0 then UserID := 1;

  if FActionMode = iamAdjust then
  begin
    if not ValidateAdjustment(ErrMsg, Delta, Reason) then
    begin
      lblActionFeedback.Caption    := ErrMsg;
      lblActionFeedback.Font.Color := clRed;
      Exit;
    end;

    OpRes := FViewModel.AdjustStock(FSelectedDTO.ProductID, FSelectedDTO.WarehouseID, Delta, Reason, UserID);
    if OpRes.Success then
    begin
      lblStatusMessage.Caption    := Format('Bestand für %s erfolgreich angepasst.', [FSelectedDTO.ProductSKU]);
      lblStatusMessage.Font.Color := clGreen;
      HideActionPanel;
    end
    else
    begin
      lblActionFeedback.Caption    := 'Fehler: ' + OpRes.Message;
      lblActionFeedback.Font.Color := clRed;
    end;
  end
  else if FActionMode = iamTransfer then
  begin
    if not ValidateTransfer(ErrMsg, TgtWH, Qty, Reason) then
    begin
      lblActionFeedback.Caption    := ErrMsg;
      lblActionFeedback.Font.Color := clRed;
      Exit;
    end;

    OpRes := FViewModel.TransferStock(FSelectedDTO.ProductID, FSelectedDTO.WarehouseID, TgtWH, Qty, Reason, UserID);
    if OpRes.Success then
    begin
      lblStatusMessage.Caption    := Format('Umlagerung von %s erfolgreich durchgeführt.', [FSelectedDTO.ProductSKU]);
      lblStatusMessage.Font.Color := clGreen;
      HideActionPanel;
    end
    else
    begin
      lblActionFeedback.Caption    := 'Fehler: ' + OpRes.Message;
      lblActionFeedback.Font.Color := clRed;
    end;
  end;
end;

end.
