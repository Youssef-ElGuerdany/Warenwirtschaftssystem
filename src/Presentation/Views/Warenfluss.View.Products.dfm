object frmProducts: TfrmProducts
  Left = 0
  Top = 0
  Caption = 'Artikelstamm'
  ClientHeight = 680
  ClientWidth = 1060
  Color = clWhitesmoke
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object splEditor: TSplitter
    Left = 730
    Top = 56
    Height = 624
    Visible = False
    ExplicitLeft = 600
    ExplicitTop = 200
    ExplicitHeight = 100
  end
  object pnlToolbar: TPanel
    Left = 0
    Top = 0
    Width = 1060
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object lblViewTitle: TLabel
      Left = 16
      Top = 16
      Width = 97
      Height = 21
      Caption = 'Artikelstamm'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2894892
      Font.Height = -16
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSearch: TEdit
      Left = 160
      Top = 14
      Width = 260
      Height = 25
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      TextHint = 'Suchen (SKU, Bezeichnung, Barcode ...)'
      OnKeyDown = edtSearchKeyDown
    end
    object btnSearch: TButton
      Left = 428
      Top = 14
      Width = 90
      Height = 25
      Caption = 'Suchen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnSearchClick
    end
    object chkOnlyActive: TCheckBox
      Left = 530
      Top = 18
      Width = 130
      Height = 17
      Caption = 'Nur aktive Artikel'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      State = cbChecked
      TabOrder = 2
      OnClick = chkOnlyActiveClick
    end
    object btnNew: TButton
      Left = 680
      Top = 14
      Width = 80
      Height = 25
      Caption = 'Neu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = btnNewClick
    end
    object btnEdit: TButton
      Left = 766
      Top = 14
      Width = 100
      Height = 25
      Caption = 'Bearbeiten'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = btnEditClick
    end
    object btnDeactivate: TButton
      Left = 872
      Top = 14
      Width = 100
      Height = 25
      Caption = 'Deaktivieren'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = btnDeactivateClick
    end
    object btnRefresh: TButton
      Left = 978
      Top = 14
      Width = 70
      Height = 25
      Caption = 'Aktualisieren'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnClick = btnRefreshClick
    end
  end
  object pnlList: TPanel
    Left = 0
    Top = 56
    Width = 730
    Height = 624
    Align = alLeft
    BevelOuter = bvNone
    Color = clWhitesmoke
    ParentBackground = False
    TabOrder = 1
    object lvProducts: TListView
      Left = 0
      Top = 0
      Width = 730
      Height = 624
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      Columns = <>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      GridLines = True
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = lvProductsDblClick
      OnSelectItem = lvProductsSelectItem
    end
  end
  object pnlEditor: TPanel
    Left = 733
    Top = 56
    Width = 327
    Height = 624
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    Visible = False
    object lblEditorTitle: TLabel
      Left = 16
      Top = 12
      Width = 123
      Height = 20
      Caption = 'Artikel bearbeiten'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2894892
      Font.Height = -15
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorSKU: TLabel
      Left = 16
      Top = 46
      Width = 121
      Height = 15
      Caption = 'Artikelnummer (SKU)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorBarcode: TLabel
      Left = 16
      Top = 96
      Width = 80
      Height = 15
      Caption = 'Barcode / EAN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorName: TLabel
      Left = 16
      Top = 146
      Width = 72
      Height = 15
      Caption = 'Bezeichnung'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorCategory: TLabel
      Left = 16
      Top = 196
      Width = 55
      Height = 15
      Caption = 'Kategorie'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorDesc: TLabel
      Left = 16
      Top = 245
      Width = 76
      Height = 15
      Caption = 'Beschreibung'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorCostPrice: TLabel
      Left = 16
      Top = 326
      Width = 73
      Height = 15
      Caption = 'Einkaufspreis'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorUnitPrice: TLabel
      Left = 165
      Top = 326
      Width = 76
      Height = 15
      Caption = 'Verkaufspreis'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorMinStock: TLabel
      Left = 16
      Top = 376
      Width = 89
      Height = 15
      Caption = 'Mindestbestand'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorMaxStock: TLabel
      Left = 165
      Top = 376
      Width = 91
      Height = 15
      Caption = 'Maximalbestand'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorUnit: TLabel
      Left = 16
      Top = 426
      Width = 85
      Height = 15
      Caption = 'Mengeneinheit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEditorStatus: TLabel
      Left = 16
      Top = 478
      Width = 295
      Height = 15
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object edtSKU: TEdit
      Left = 16
      Top = 64
      Width = 295
      Height = 23
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object edtBarcode: TEdit
      Left = 16
      Top = 114
      Width = 295
      Height = 23
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object edtName: TEdit
      Left = 16
      Top = 164
      Width = 295
      Height = 23
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object cmbCategory: TComboBox
      Left = 16
      Top = 214
      Width = 295
      Height = 23
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object memDescription: TMemo
      Left = 16
      Top = 263
      Width = 295
      Height = 55
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 4
    end
    object edtCostPrice: TEdit
      Left = 16
      Top = 344
      Width = 135
      Height = 23
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      Text = '0.00'
    end
    object edtUnitPrice: TEdit
      Left = 165
      Top = 344
      Width = 146
      Height = 23
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      Text = '0.00'
    end
    object edtMinStock: TEdit
      Left = 16
      Top = 394
      Width = 135
      Height = 23
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      Text = '0'
    end
    object edtMaxStock: TEdit
      Left = 165
      Top = 394
      Width = 146
      Height = 23
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 8
      Text = '0'
    end
    object cmbUnit: TComboBox
      Left = 16
      Top = 444
      Width = 175
      Height = 23
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 9
    end
    object chkIsActive: TCheckBox
      Left = 206
      Top = 448
      Width = 100
      Height = 17
      Caption = 'Aktiv'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      State = cbChecked
      TabOrder = 10
    end
    object btnSave: TButton
      Left = 16
      Top = 502
      Width = 130
      Height = 30
      Caption = 'Speichern'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 11
      OnClick = btnSaveClick
    end
    object btnCancelEdit: TButton
      Left = 156
      Top = 502
      Width = 110
      Height = 30
      Cancel = True
      Caption = 'Abbrechen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 12
      OnClick = btnCancelEditClick
    end
  end
end
