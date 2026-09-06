unit Warenfluss.View.Products;

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
  Warenfluss.DTOs.Product,
  Warenfluss.Interfaces.Services,
  Warenfluss.ViewModel.Product;

type
  TfrmProducts = class(TForm)
    { --- Main layout --- }
    pnlToolbar:    TPanel;
    pnlList:       TPanel;
    splEditor:     TSplitter;
    pnlEditor:     TPanel;

    { --- Toolbar --- }
    lblViewTitle:  TLabel;
    edtSearch:     TEdit;
    btnSearch:     TButton;
    btnNew:        TButton;
    btnEdit:       TButton;
    btnDeactivate: TButton;
    btnRefresh:    TButton;
    chkOnlyActive: TCheckBox;

    { --- Product list --- }
    lvProducts: TListView;

    { --- Editor panel --- }
    lblEditorTitle:    TLabel;
    lblEditorSKU:      TLabel;
    edtSKU:            TEdit;
    lblEditorBarcode:  TLabel;
    edtBarcode:        TEdit;
    lblEditorName:     TLabel;
    edtName:           TEdit;
    lblEditorCategory: TLabel;
    cmbCategory:       TComboBox;
    lblEditorDesc:     TLabel;
    memDescription:    TMemo;
    lblEditorCostPrice:TLabel;
    edtCostPrice:      TEdit;
    lblEditorUnitPrice:TLabel;
    edtUnitPrice:      TEdit;
    lblEditorMinStock: TLabel;
    edtMinStock:       TEdit;
    lblEditorMaxStock: TLabel;
    edtMaxStock:       TEdit;
    lblEditorUnit:     TLabel;
    cmbUnit:           TComboBox;
    chkIsActive:       TCheckBox;
    lblEditorStatus:   TLabel;
    btnSave:           TButton;
    btnCancelEdit:     TButton;

    { --- Event handlers (declared so DFM can bind them) --- }
    procedure FormCreate(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeactivateClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure chkOnlyActiveClick(Sender: TObject);
    procedure lvProductsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvProductsDblClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelEditClick(Sender: TObject);

  private
    FViewModel: TProductViewModel;
    FEditMode:  Boolean;
    FEditingID: TEntityID;

    procedure OnViewModelChanged;
    procedure PopulateList;
    procedure PopulateCategories;
    procedure PopulateUnitTypes;
    procedure ShowEditor(AIsNew: Boolean);
    procedure HideEditor;
    procedure LoadProductIntoEditor(const ADTO: TProductDTO);
    procedure ClearEditor;
    procedure UpdateToolbarState;
    procedure UpdateLocalization;
    function  GetSelectedProduct(out ADTO: TProductDTO): Boolean;
    function  ValidateEditor(out AMsg: string): Boolean;

  public
    constructor CreateWithViewModel(AOwner: TComponent; AViewModel: TProductViewModel); reintroduce;
  end;

var
  frmProducts: TfrmProducts;

implementation

{$R *.dfm}

{ ============================================================
  Constructor
  ============================================================ }

constructor TfrmProducts.CreateWithViewModel(AOwner: TComponent;
  AViewModel: TProductViewModel);
begin
  inherited Create(AOwner);
  FViewModel := AViewModel;
  if Assigned(FViewModel) then
    FViewModel.OnChanged := OnViewModelChanged;
end;

{ ============================================================
  Form init
  ============================================================ }

procedure TfrmProducts.FormCreate(Sender: TObject);
begin
  UpdateLocalization;
  PopulateUnitTypes;
  HideEditor;

  { Configure the ListView }
  lvProducts.ViewStyle   := vsReport;
  lvProducts.RowSelect   := True;
  lvProducts.ReadOnly    := True;
  lvProducts.GridLines   := True;
  lvProducts.MultiSelect := False;

  lvProducts.Columns.Clear;
  with lvProducts.Columns.Add do begin Caption := _('FIELD_SKU',          'SKU');            Width := 130; end;
  with lvProducts.Columns.Add do begin Caption := _('FIELD_NAME',         'Bezeichnung');     Width := 230; end;
  with lvProducts.Columns.Add do begin Caption := _('FIELD_CATEGORY',     'Kategorie');       Width := 130; end;
  with lvProducts.Columns.Add do begin Caption := _('FIELD_COST_PRICE',   'EK-Preis');        Width :=  90; Alignment := taRightJustify; end;
  with lvProducts.Columns.Add do begin Caption := _('FIELD_UNIT_PRICE',   'VK-Preis');        Width :=  90; Alignment := taRightJustify; end;
  with lvProducts.Columns.Add do begin Caption := _('FIELD_CURRENT_STOCK','Bestand');         Width :=  90; Alignment := taRightJustify; end;
  with lvProducts.Columns.Add do begin Caption := _('FIELD_MIN_STOCK',    'Mindestbestand');  Width :=  80; Alignment := taRightJustify; end;
  with lvProducts.Columns.Add do begin Caption := 'Einheit';                                  Width :=  70; end;
  with lvProducts.Columns.Add do begin Caption := 'Status';                                   Width :=  80; end;

  chkOnlyActive.Checked := True;
  UpdateToolbarState;

  if Assigned(FViewModel) then
  begin
    FViewModel.OnlyActive := True;
    FViewModel.LoadProducts;
  end;
end;

{ ============================================================
  Localization
  ============================================================ }

procedure TfrmProducts.UpdateLocalization;
begin
  Caption              := _('NAV_PRODUCTS', 'Artikelstamm');
  lblViewTitle.Caption := _('NAV_PRODUCTS', 'Artikelstamm');
  edtSearch.TextHint   := _('BTN_SEARCH', 'Suchen') + ' (SKU, Bezeichnung, Barcode …)';
  btnSearch.Caption    := _('BTN_SEARCH',   'Suchen');
  btnNew.Caption       := _('BTN_NEW',      'Neu');
  btnEdit.Caption      := _('BTN_EDIT',     'Bearbeiten');
  btnDeactivate.Caption:= _('BTN_DELETE',   'Deaktivieren');
  btnRefresh.Caption   := _('BTN_REFRESH',  'Aktualisieren');
  chkOnlyActive.Caption:= 'Nur aktive Artikel';

  lblEditorSKU.Caption       := _('FIELD_SKU',        'Artikelnummer (SKU)');
  lblEditorBarcode.Caption   := _('FIELD_BARCODE',    'Barcode / EAN');
  lblEditorName.Caption      := _('FIELD_NAME',       'Bezeichnung');
  lblEditorCategory.Caption  := _('FIELD_CATEGORY',   'Kategorie');
  lblEditorDesc.Caption      := 'Beschreibung';
  lblEditorCostPrice.Caption := _('FIELD_COST_PRICE', 'Einkaufspreis');
  lblEditorUnitPrice.Caption := _('FIELD_UNIT_PRICE', 'Verkaufspreis');
  lblEditorMinStock.Caption  := _('FIELD_MIN_STOCK',  'Mindestbestand');
  lblEditorMaxStock.Caption  := 'Maximalbestand';
  lblEditorUnit.Caption      := 'Mengeneinheit';
  chkIsActive.Caption        := 'Aktiv';
  btnSave.Caption            := _('BTN_SAVE',   'Speichern');
  btnCancelEdit.Caption      := _('BTN_CANCEL', 'Abbrechen');
end;

{ ============================================================
  ViewModel callback
  ============================================================ }

procedure TfrmProducts.OnViewModelChanged;
begin
  if not Assigned(FViewModel) then Exit;
  PopulateList;
  PopulateCategories;
  UpdateToolbarState;
  lblEditorStatus.Caption := FViewModel.StatusMessage;
end;

{ ============================================================
  List population
  ============================================================ }

procedure TfrmProducts.PopulateList;
var
  I: Integer;
  P: TProductDTO;
  Item: TListItem;
begin
  lvProducts.Items.BeginUpdate;
  try
    lvProducts.Items.Clear;
    if not Assigned(FViewModel) then Exit;

    for I := 0 to High(FViewModel.Products) do
    begin
      P    := FViewModel.Products[I];
      Item := lvProducts.Items.Add;

      Item.Caption := P.SKU;
      Item.Data    := Pointer(P.ID);

      Item.SubItems.Add(P.Name);
      Item.SubItems.Add(P.CategoryName);
      Item.SubItems.Add(FormatMoney(P.CostPrice));
      Item.SubItems.Add(FormatMoney(P.UnitPrice));

      if P.IsLowStock then
        Item.SubItems.Add(FormatQty(P.CurrentStockTotal) + ' !')
      else
        Item.SubItems.Add(FormatQty(P.CurrentStockTotal));

      Item.SubItems.Add(FormatQty(P.MinStockLevel));
      Item.SubItems.Add(P.UnitName);

      if P.IsActive then
        Item.SubItems.Add('Aktiv')
      else
      begin
        Item.SubItems.Add('Inaktiv');
     //   Item.Font.Color := clGray;
      end;

      if P.IsLowStock then
      //  Item.Font.Color := clMaroon;
    end;
  finally
    lvProducts.Items.EndUpdate;
  end;

  UpdateToolbarState;
end;

procedure TfrmProducts.PopulateCategories;
var
  I: Integer;
  SavedID: TEntityID;
begin
  SavedID := 0;
  if cmbCategory.ItemIndex > 0 then
    SavedID := TEntityID(cmbCategory.Items.Objects[cmbCategory.ItemIndex]);

  cmbCategory.Items.BeginUpdate;
  try
    cmbCategory.Items.Clear;
    cmbCategory.Items.AddObject('— (keine Kategorie)', TObject(0));
    if Assigned(FViewModel) then
      for I := 0 to High(FViewModel.Categories) do
        cmbCategory.Items.AddObject(
          FViewModel.Categories[I].Name,
          TObject(FViewModel.Categories[I].ID));
  finally
    cmbCategory.Items.EndUpdate;
  end;

  cmbCategory.ItemIndex := 0;
  if SavedID > 0 then
    for I := 0 to cmbCategory.Items.Count - 1 do
      if TEntityID(cmbCategory.Items.Objects[I]) = SavedID then
      begin
        cmbCategory.ItemIndex := I;
        Break;
      end;
end;

procedure TfrmProducts.PopulateUnitTypes;
begin
  cmbUnit.Items.Clear;
  cmbUnit.Items.AddObject('Stueck (PCS)',    TObject(Ord(puPiece)));
  cmbUnit.Items.AddObject('Kilogramm (KG)', TObject(Ord(puKilogram)));
  cmbUnit.Items.AddObject('Gramm (G)',      TObject(Ord(puGram)));
  cmbUnit.Items.AddObject('Meter (M)',      TObject(Ord(puMeter)));
  cmbUnit.Items.AddObject('Liter (L)',      TObject(Ord(puLiter)));
  cmbUnit.Items.AddObject('Karton (BOX)',   TObject(Ord(puBox)));
  cmbUnit.Items.AddObject('Palette (PAL)',  TObject(Ord(puPalette)));
  cmbUnit.ItemIndex := 0;
end;

{ ============================================================
  Toolbar state
  ============================================================ }

procedure TfrmProducts.UpdateToolbarState;
var
  HasSel: Boolean;
begin
  HasSel := (lvProducts.Selected <> nil);
  btnEdit.Enabled       := HasSel;
  btnDeactivate.Enabled := HasSel;
end;

{ ============================================================
  Editor show / hide / fill / clear
  ============================================================ }

procedure TfrmProducts.ShowEditor(AIsNew: Boolean);
begin
  pnlEditor.Visible := True;
  splEditor.Visible  := True;
  if AIsNew then
    lblEditorTitle.Caption := 'Neuer Artikel anlegen'
  else
    lblEditorTitle.Caption := 'Artikel bearbeiten';
  edtSKU.SetFocus;
end;

procedure TfrmProducts.HideEditor;
begin
  pnlEditor.Visible := False;
  splEditor.Visible  := False;
  FEditMode  := False;
  FEditingID := 0;
  lblEditorStatus.Caption := '';
end;

procedure TfrmProducts.ClearEditor;
begin
  edtSKU.Clear;
  edtBarcode.Clear;
  edtName.Clear;
  memDescription.Clear;
  edtCostPrice.Text  := '0.00';
  edtUnitPrice.Text  := '0.00';
  edtMinStock.Text   := '0';
  edtMaxStock.Text   := '0';
  cmbCategory.ItemIndex := 0;
  cmbUnit.ItemIndex     := 0;
  chkIsActive.Checked   := True;
  lblEditorStatus.Caption := '';
end;

procedure TfrmProducts.LoadProductIntoEditor(const ADTO: TProductDTO);
var
  I: Integer;
begin
  edtSKU.Text         := ADTO.SKU;
  edtBarcode.Text     := ADTO.Barcode;
  edtName.Text        := ADTO.Name;
  memDescription.Text := ADTO.Description;
  edtCostPrice.Text   := Format('%.4f', [Double(ADTO.CostPrice)]);
  edtUnitPrice.Text   := Format('%.4f', [Double(ADTO.UnitPrice)]);
  edtMinStock.Text    := Format('%.2f', [ADTO.MinStockLevel]);
  edtMaxStock.Text    := Format('%.2f', [ADTO.MaxStockLevel]);
  chkIsActive.Checked := ADTO.IsActive;

  cmbCategory.ItemIndex := 0;
  for I := 0 to cmbCategory.Items.Count - 1 do
    if TEntityID(cmbCategory.Items.Objects[I]) = ADTO.CategoryID then
    begin
      cmbCategory.ItemIndex := I;
      Break;
    end;

  cmbUnit.ItemIndex := 0;
  for I := 0 to cmbUnit.Items.Count - 1 do
    if TProductUnit(NativeInt(cmbUnit.Items.Objects[I])) = ADTO.UnitType then
    begin
      cmbUnit.ItemIndex := I;
      Break;
    end;
end;

{ ============================================================
  Toolbar handlers
  ============================================================ }

procedure TfrmProducts.btnSearchClick(Sender: TObject);
begin
  if Assigned(FViewModel) then
    FViewModel.Search(Trim(edtSearch.Text));
end;

procedure TfrmProducts.edtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then btnSearchClick(Sender);
end;

procedure TfrmProducts.btnRefreshClick(Sender: TObject);
begin
  edtSearch.Clear;
  if Assigned(FViewModel) then
    FViewModel.LoadProducts;
end;

procedure TfrmProducts.chkOnlyActiveClick(Sender: TObject);
begin
  if Assigned(FViewModel) then
  begin
    FViewModel.OnlyActive := chkOnlyActive.Checked;
    FViewModel.LoadProducts;
  end;
end;

procedure TfrmProducts.btnNewClick(Sender: TObject);
begin
  FEditMode  := False;
  FEditingID := 0;
  ClearEditor;
  ShowEditor(True);
end;

procedure TfrmProducts.btnEditClick(Sender: TObject);
var
  DTO: TProductDTO;
begin
  if not GetSelectedProduct(DTO) then Exit;
  FEditMode  := True;
  FEditingID := DTO.ID;
  LoadProductIntoEditor(DTO);
  ShowEditor(False);
end;

procedure TfrmProducts.btnDeactivateClick(Sender: TObject);
var
  DTO: TProductDTO;
  Res: TOperationResult;
begin
  if not GetSelectedProduct(DTO) then Exit;

  if MessageDlg(
       Format('Artikel "%s" (%s) wirklich deaktivieren?', [DTO.Name, DTO.SKU]),
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  if Assigned(FViewModel) then
  begin
    Res := FViewModel.DeactivateProduct(DTO.ID);
    if not Res.Success then
      ShowMessage('Fehler beim Deaktivieren: ' + Res.Message);
  end;
end;

{ ============================================================
  Editor: Save / Cancel
  ============================================================ }

procedure TfrmProducts.btnSaveClick(Sender: TObject);
var
  ErrMsg:  string;
  CatID:   TEntityID;
  UnitTyp: TProductUnit;
  Res:     TOperationResult;
begin
  if not ValidateEditor(ErrMsg) then
  begin
    lblEditorStatus.Caption    := ErrMsg;
    lblEditorStatus.Font.Color := clRed;
    Exit;
  end;

  CatID := 0;
  if cmbCategory.ItemIndex > 0 then
    CatID := TEntityID(cmbCategory.Items.Objects[cmbCategory.ItemIndex]);

  UnitTyp := puPiece;
  if cmbUnit.ItemIndex >= 0 then
    UnitTyp := TProductUnit(NativeInt(cmbUnit.Items.Objects[cmbUnit.ItemIndex]));

  if not FEditMode then
  begin
    var CreateDTO: TProductCreateDTO;
    CreateDTO.SKU           := Trim(edtSKU.Text);
    CreateDTO.Barcode       := Trim(edtBarcode.Text);
    CreateDTO.Name          := Trim(edtName.Text);
    CreateDTO.Description   := Trim(memDescription.Text);
    CreateDTO.CategoryID    := CatID;
    CreateDTO.CostPrice     := StrToCurrDef(StringReplace(edtCostPrice.Text, ',', '.', [rfReplaceAll]), 0);
    CreateDTO.UnitPrice     := StrToCurrDef(StringReplace(edtUnitPrice.Text, ',', '.', [rfReplaceAll]), 0);
    CreateDTO.MinStockLevel := StrToFloatDef(StringReplace(edtMinStock.Text, ',', '.', [rfReplaceAll]), 0);
    CreateDTO.MaxStockLevel := StrToFloatDef(StringReplace(edtMaxStock.Text, ',', '.', [rfReplaceAll]), 0);
    CreateDTO.UnitType      := UnitTyp;
    Res := FViewModel.SaveProduct(CreateDTO);
  end
  else
  begin
    var UpdateDTO: TProductUpdateDTO;
    UpdateDTO.ID            := FEditingID;
    UpdateDTO.SKU           := Trim(edtSKU.Text);
    UpdateDTO.Barcode       := Trim(edtBarcode.Text);
    UpdateDTO.Name          := Trim(edtName.Text);
    UpdateDTO.Description   := Trim(memDescription.Text);
    UpdateDTO.CategoryID    := CatID;
    UpdateDTO.CostPrice     := StrToCurrDef(StringReplace(edtCostPrice.Text, ',', '.', [rfReplaceAll]), 0);
    UpdateDTO.UnitPrice     := StrToCurrDef(StringReplace(edtUnitPrice.Text, ',', '.', [rfReplaceAll]), 0);
    UpdateDTO.MinStockLevel := StrToFloatDef(StringReplace(edtMinStock.Text, ',', '.', [rfReplaceAll]), 0);
    UpdateDTO.MaxStockLevel := StrToFloatDef(StringReplace(edtMaxStock.Text, ',', '.', [rfReplaceAll]), 0);
    UpdateDTO.UnitType      := UnitTyp;
    UpdateDTO.IsActive      := chkIsActive.Checked;
    Res := FViewModel.UpdateProduct(UpdateDTO);
  end;

  if Res.Success then
  begin
    lblEditorStatus.Caption    := 'Gespeichert.';
    lblEditorStatus.Font.Color := clGreen;
    HideEditor;
  end
  else
  begin
    lblEditorStatus.Caption    := 'Fehler: ' + Res.Message;
    lblEditorStatus.Font.Color := clRed;
  end;
end;

procedure TfrmProducts.btnCancelEditClick(Sender: TObject);
begin
  HideEditor;
end;

{ ============================================================
  List selection
  ============================================================ }

procedure TfrmProducts.lvProductsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  DTO: TProductDTO;
begin
  if Selected and Assigned(Item) then
    if GetSelectedProduct(DTO) then
      FViewModel.SelectedProduct := DTO;
  UpdateToolbarState;
end;

procedure TfrmProducts.lvProductsDblClick(Sender: TObject);
begin
  btnEditClick(Sender);
end;

{ ============================================================
  Helpers
  ============================================================ }

function TfrmProducts.GetSelectedProduct(out ADTO: TProductDTO): Boolean;
var
  Item: TListItem;
  ID:   TEntityID;
  I:    Integer;
begin
  Result := False;
  Item := lvProducts.Selected;
  if (Item = nil) or not Assigned(FViewModel) then Exit;
  ID := TEntityID(Item.Data);
  for I := 0 to High(FViewModel.Products) do
    if FViewModel.Products[I].ID = ID then
    begin
      ADTO := FViewModel.Products[I];
      Exit(True);
    end;
end;

function TfrmProducts.ValidateEditor(out AMsg: string): Boolean;
begin
  Result := False;
  if Trim(edtSKU.Text) = '' then
  begin
    AMsg := 'Artikelnummer (SKU) ist ein Pflichtfeld.';
    edtSKU.SetFocus;
    Exit;
  end;
  if Trim(edtName.Text) = '' then
  begin
    AMsg := 'Bezeichnung ist ein Pflichtfeld.';
    edtName.SetFocus;
    Exit;
  end;
  if StrToCurrDef(StringReplace(edtUnitPrice.Text, ',', '.', [rfReplaceAll]), -1) < 0 then
  begin
    AMsg := 'Verkaufspreis ist ungueltig.';
    edtUnitPrice.SetFocus;
    Exit;
  end;
  Result := True;
  AMsg   := '';
end;

end.
