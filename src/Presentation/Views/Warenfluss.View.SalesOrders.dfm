object frmSalesOrders: TfrmSalesOrders
  Left = 0
  Top = 0
  Caption = 'Verkaufsauftrag'#228'ge'
  ClientHeight = 720
  ClientWidth = 1200
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
    Left = 820
    Top = 56
    Width = 5
    Height = 624
    Align = alRight
    Visible = False
    ExplicitLeft = 820
    ExplicitHeight = 624
  end
  object pnlToolbar: TPanel
    Left = 0
    Top = 0
    Width = 1200
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object lblViewTitle: TLabel
      Left = 16
      Top = 14
      Width = 180
      Height = 21
      Caption = 'Verkaufsauftrag'#228'ge'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2894892
      Font.Height = -16
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSearch: TEdit
      Left = 215
      Top = 14
      Width = 240
      Height = 25
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      TextHint = 'Suchen (Auftragsnr., Kundenname ...)'
      OnKeyDown = edtSearchKeyDown
    end
    object btnSearch: TButton
      Left = 463
      Top = 14
      Width = 80
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
    object btnNew: TButton
      Left = 565
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
      TabOrder = 2
      OnClick = btnNewClick
    end
    object btnConfirm: TButton
      Left = 655
      Top = 14
      Width = 100
      Height = 25
      Caption = 'Best'#228'tigen'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = btnConfirmClick
    end
    object btnComplete: TButton
      Left = 763
      Top = 14
      Width = 110
      Height = 25
      Caption = 'Abschlie'#223'en'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = btnCompleteClick
    end
    object btnCancelOrder: TButton
      Left = 881
      Top = 14
      Width = 100
      Height = 25
      Caption = 'Stornieren'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = btnCancelOrderClick
    end
    object btnRefresh: TButton
      Left = 990
      Top = 14
      Width = 100
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
  object pnlFooter: TPanel
    Left = 0
    Top = 680
    Width = 1200
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object lblSummaryCount: TLabel
      Left = 16
      Top = 12
      Width = 80
      Height = 15
      Caption = 'Auftr'#228'ge: 0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3355443
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSummaryOpenValue: TLabel
      Left = 170
      Top = 12
      Width = 120
      Height = 15
      Caption = 'Offener Wert: 0,00 '#8364
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 11162880
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblStatusMessage: TLabel
      Left = 380
      Top = 12
      Width = 3
      Height = 15
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlEditor: TPanel
    Left = 825
    Top = 56
    Width = 375
    Height = 624
    Align = alRight
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    Visible = False
    object pnlEditorHeader: TPanel
      Left = 0
      Top = 0
      Width = 375
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblEditorTitle: TLabel
        Left = 16
        Top = 10
        Width = 200
        Height = 20
        Caption = 'Neuen Auftrag anlegen'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2894892
        Font.Height = -15
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlEditorMaster: TPanel
      Left = 0
      Top = 40
      Width = 375
      Height = 220
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object lblEditorCustomer: TLabel
        Left = 16
        Top = 8
        Width = 52
        Height = 15
        Caption = 'Kunde *'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object cmbCustomer: TComboBox
        Left = 16
        Top = 26
        Width = 340
        Height = 23
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object lblEditorWarehouse: TLabel
        Left = 16
        Top = 58
        Width = 52
        Height = 15
        Caption = 'Lager *'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object cmbWarehouse: TComboBox
        Left = 16
        Top = 76
        Width = 340
        Height = 23
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object lblEditorRequiredDate: TLabel
        Left = 16
        Top = 108
        Width = 70
        Height = 15
        Caption = 'Lieferdatum'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object dtpRequiredDate: TDateTimePicker
        Left = 16
        Top = 126
        Width = 200
        Height = 23
        Date = 42005.000000000000000000
        Time = 42005.000000000000000000
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object lblEditorNotes: TLabel
        Left = 16
        Top = 158
        Width = 75
        Height = 15
        Caption = 'Bemerkungen'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object memNotes: TMemo
        Left = 16
        Top = 176
        Width = 340
        Height = 36
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        MaxLength = 500
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 3
        WantReturns = False
      end
    end
    object pnlEditorLines: TPanel
      Left = 0
      Top = 260
      Width = 375
      Height = 280
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object lblEditorLinesTitle: TLabel
        Left = 16
        Top = 4
        Width = 130
        Height = 15
        Caption = 'Auftragspositionen *'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblLineProduct: TLabel
        Left = 16
        Top = 24
        Width = 35
        Height = 15
        Caption = 'Artikel'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object cmbLineProduct: TComboBox
        Left = 16
        Top = 42
        Width = 220
        Height = 23
        Style = csDropDown
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnChange = cmbLineProductChange
      end
      object lblLineQty: TLabel
        Left = 244
        Top = 24
        Width = 28
        Height = 15
        Caption = 'Menge'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtLineQty: TEdit
        Left = 244
        Top = 42
        Width = 50
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        Text = '1'
      end
      object lblLinePrice: TLabel
        Left = 16
        Top = 70
        Width = 70
        Height = 15
        Caption = 'VK-Preis ('#8364')'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtLinePrice: TEdit
        Left = 16
        Top = 88
        Width = 120
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        Text = '0,00'
      end
      object lblLineDiscount: TLabel
        Left = 148
        Top = 70
        Width = 45
        Height = 15
        Caption = 'Rabatt %'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtLineDiscount: TEdit
        Left = 148
        Top = 88
        Width = 60
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        Text = '0'
      end
      object btnAddLine: TButton
        Left = 220
        Top = 88
        Width = 80
        Height = 23
        Caption = '+ Position'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
        OnClick = btnAddLineClick
      end
      object btnRemoveLine: TButton
        Left = 308
        Top = 88
        Width = 50
        Height = 23
        Caption = #8722
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 5
        OnClick = btnRemoveLineClick
      end
      object lvLines: TListView
        Left = 16
        Top = 120
        Width = 340
        Height = 100
        BorderStyle = bsNone
        Columns = <>
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        GridLines = True
        ParentFont = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 6
        ViewStyle = vsReport
      end
      object lblTotalsNetto: TLabel
        Left = 16
        Top = 226
        Width = 100
        Height = 15
        Caption = 'Netto: 0,00 '#8364
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblTotalsTax: TLabel
        Left = 16
        Top = 244
        Width = 140
        Height = 15
        Caption = 'MwSt (19 %): 0,00 '#8364
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblTotalsBrutto: TLabel
        Left = 200
        Top = 232
        Width = 100
        Height = 18
        Caption = 'Brutto: 0,00 '#8364
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2894892
        Font.Height = -14
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlEditorButtons: TPanel
      Left = 0
      Top = 540
      Width = 375
      Height = 84
      Align = alBottom
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      object lblEditorStatus: TLabel
        Left = 16
        Top = 6
        Width = 340
        Height = 28
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object btnSaveOrder: TButton
        Left = 16
        Top = 42
        Width = 155
        Height = 30
        Caption = 'Speichern'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btnSaveOrderClick
      end
      object btnCancelEdit: TButton
        Left = 180
        Top = 42
        Width = 155
        Height = 30
        Caption = 'Abbrechen'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = btnCancelEditClick
      end
    end
  end
  object pnlList: TPanel
    Left = 0
    Top = 56
    Width = 820
    Height = 624
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object lvOrders: TListView
      Left = 0
      Top = 0
      Width = 820
      Height = 624
      Align = alClient
      BorderStyle = bsNone
      Columns = <>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      GridLines = True
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = lvOrdersDblClick
      OnSelectItem = lvOrdersSelectItem
    end
  end
end
