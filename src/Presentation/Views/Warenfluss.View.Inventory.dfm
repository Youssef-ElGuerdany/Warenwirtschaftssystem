object frmInventory: TfrmInventory
  Left = 0
  Top = 0
  Caption = 'Lagerbestand & Bestandsf'#252'hrung'
  ClientHeight = 700
  ClientWidth = 1100
  Color = clWhitesmoke
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object splAction: TSplitter
    Left = 755
    Top = 56
    Width = 5
    Height = 604
    Align = alRight
    Visible = False
    ExplicitLeft = 740
    ExplicitHeight = 580
  end
  object pnlToolbar: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object lblViewTitle: TLabel
      Left = 16
      Top = 16
      Width = 100
      Height = 21
      Caption = 'Lagerbestand'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2894892
      Font.Height = -16
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblWarehouseFilter: TLabel
      Left = 135
      Top = 18
      Width = 32
      Height = 15
      Caption = 'Lager:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object cmbWarehouseFilter: TComboBox
      Left = 175
      Top = 14
      Width = 170
      Height = 23
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnChange = cmbWarehouseFilterChange
    end
    object edtSearch: TEdit
      Left = 360
      Top = 14
      Width = 230
      Height = 23
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      TextHint = 'Suchen (Artikel, SKU, Lager ...)'
      OnKeyDown = edtSearchKeyDown
    end
    object btnSearch: TButton
      Left = 598
      Top = 13
      Width = 75
      Height = 26
      Caption = 'Suchen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnSearchClick
    end
    object btnAdjust: TButton
      Left = 690
      Top = 13
      Width = 120
      Height = 26
      Caption = 'Bestand anpassen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = btnAdjustClick
    end
    object btnTransfer: TButton
      Left = 820
      Top = 13
      Width = 90
      Height = 26
      Caption = 'Umlagern'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = btnTransferClick
    end
    object btnRefresh: TButton
      Left = 920
      Top = 13
      Width = 95
      Height = 26
      Caption = 'Aktualisieren'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = btnRefreshClick
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 660
    Width = 1100
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object lblSummaryPositions: TLabel
      Left = 16
      Top = 12
      Width = 69
      Height = 15
      Caption = 'Positionen: 0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3355443
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSummaryTotalQty: TLabel
      Left = 160
      Top = 12
      Width = 95
      Height = 15
      Caption = 'Gesamtbestand: 0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3355443
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSummaryTotalValue: TLabel
      Left = 330
      Top = 12
      Width = 103
      Height = 15
      Caption = 'Gesamtwert: 0,00 '#8364
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 11162880
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblStatusMessage: TLabel
      Left = 550
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
  object pnlAction: TPanel
    Left = 760
    Top = 56
    Width = 340
    Height = 604
    Align = alRight
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    Visible = False
    object pnlActionHeader: TPanel
      Left = 0
      Top = 0
      Width = 340
      Height = 100
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblActionTitle: TLabel
        Left = 16
        Top = 12
        Width = 125
        Height = 20
        Caption = 'Bestandskorrektur'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2894892
        Font.Height = -15
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblActionProdHeader: TLabel
        Left = 16
        Top = 42
        Width = 37
        Height = 15
        Caption = 'Artikel:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblActionProdName: TLabel
        Left = 65
        Top = 42
        Width = 255
        Height = 15
        AutoSize = False
        Caption = '-'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblActionSKUHeader: TLabel
        Left = 16
        Top = 66
        Width = 24
        Height = 15
        Caption = 'SKU:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblActionSKUVal: TLabel
        Left = 65
        Top = 66
        Width = 255
        Height = 15
        AutoSize = False
        Caption = '-'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlAdjustGroup: TPanel
      Left = 0
      Top = 100
      Width = 340
      Height = 290
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object lblAdjustWHHeader: TLabel
        Left = 16
        Top = 8
        Width = 32
        Height = 15
        Caption = 'Lager:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblAdjustWHVal: TLabel
        Left = 65
        Top = 8
        Width = 255
        Height = 15
        AutoSize = False
        Caption = '-'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblAdjustCurrentHeader: TLabel
        Left = 16
        Top = 36
        Width = 95
        Height = 15
        Caption = 'Aktueller Bestand:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblAdjustCurrentVal: TLabel
        Left = 135
        Top = 36
        Width = 7
        Height = 15
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblAdjustDeltaHeader: TLabel
        Left = 16
        Top = 68
        Width = 139
        Height = 15
        Caption = 'Anpassungsmenge (+ / -):'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblAdjustResultHeader: TLabel
        Left = 16
        Top = 126
        Width = 123
        Height = 15
        Caption = 'Resultierender Bestand:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblAdjustResultVal: TLabel
        Left = 160
        Top = 126
        Width = 7
        Height = 15
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblAdjustReasonHeader: TLabel
        Left = 16
        Top = 158
        Width = 108
        Height = 15
        Caption = 'Grund / Bemerkung:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object edtAdjustDelta: TEdit
        Left = 16
        Top = 90
        Width = 300
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Text = '0'
        OnChange = edtAdjustDeltaChange
      end
      object cmbAdjustReason: TComboBox
        Left = 16
        Top = 180
        Width = 300
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
      object edtAdjustReasonNote: TEdit
        Left = 16
        Top = 212
        Width = 300
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        TextHint = 'Zus'#228'tzliche Bemerkung (optional)'
      end
    end
    object pnlTransferGroup: TPanel
      Left = 0
      Top = 390
      Width = 340
      Height = 100
      Align = alClient
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      Visible = False
      object lblTransferSrcWHHeader: TLabel
        Left = 16
        Top = 8
        Width = 57
        Height = 15
        Caption = 'Quelllager:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblTransferSrcWHVal: TLabel
        Left = 90
        Top = 8
        Width = 230
        Height = 15
        AutoSize = False
        Caption = '-'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblTransferAvailHeader: TLabel
        Left = 16
        Top = 32
        Width = 128
        Height = 15
        Caption = 'Verf'#252'gbar im Quelllager:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblTransferAvailVal: TLabel
        Left = 160
        Top = 32
        Width = 7
        Height = 15
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTransferTgtWHHeader: TLabel
        Left = 16
        Top = 58
        Width = 48
        Height = 15
        Caption = 'Ziellager:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTransferQtyHeader: TLabel
        Left = 16
        Top = 110
        Width = 82
        Height = 15
        Caption = 'Transfermenge:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTransferReasonHeader: TLabel
        Left = 16
        Top = 162
        Width = 75
        Height = 15
        Caption = 'Grund / Notiz:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object cmbTransferTgtWH: TComboBox
        Left = 16
        Top = 78
        Width = 300
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
      object edtTransferQty: TEdit
        Left = 16
        Top = 130
        Width = 300
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        Text = '1'
        OnChange = edtTransferQtyChange
      end
      object edtTransferReasonNote: TEdit
        Left = 16
        Top = 182
        Width = 300
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        Text = 'Umlagerung zwischen Lagern'
      end
    end
    object pnlActionButtons: TPanel
      Left = 0
      Top = 490
      Width = 340
      Height = 114
      Align = alBottom
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      object lblActionFeedback: TLabel
        Left = 16
        Top = 6
        Width = 300
        Height = 32
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object btnExecuteAction: TButton
        Left = 16
        Top = 44
        Width = 145
        Height = 30
        Caption = 'Ausf'#252'hren'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btnExecuteActionClick
      end
      object btnCancelAction: TButton
        Left = 171
        Top = 44
        Width = 145
        Height = 30
        Caption = 'Abbrechen'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = btnCancelActionClick
      end
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 56
    Width = 755
    Height = 604
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object pgcInventory: TPageControl
      Left = 0
      Top = 0
      Width = 755
      Height = 604
      ActivePage = tsStock
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnChange = pgcInventoryChange
      object tsStock: TTabSheet
        Caption = 'Bestands'#252'bersicht'
        object lvStock: TListView
          Left = 0
          Top = 0
          Width = 747
          Height = 574
          Align = alClient
          BorderStyle = bsNone
          Columns = <>
          GridLines = True
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnDblClick = lvStockDblClick
          OnSelectItem = lvStockSelectItem
        end
      end
      object tsMovements: TTabSheet
        Caption = 'Bewegungsprotokoll (Journal)'
        ImageIndex = 1
        object pnlMovementsTop: TPanel
          Left = 0
          Top = 0
          Width = 747
          Height = 42
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 0
          object lblMovementsInfo: TLabel
            Left = 400
            Top = 13
            Width = 3
            Height = 15
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGray
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object btnRefreshMovements: TButton
            Left = 12
            Top = 8
            Width = 140
            Height = 26
            Caption = 'Journal aktualisieren'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            OnClick = btnRefreshMovementsClick
          end
          object chkFilterMovementByProduct: TCheckBox
            Left = 168
            Top = 12
            Width = 220
            Height = 17
            Caption = 'Nur f'#252'r markierten Artikel filtern'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            OnClick = chkFilterMovementByProductClick
          end
        end
        object lvMovements: TListView
          Left = 0
          Top = 42
          Width = 747
          Height = 532
          Align = alClient
          BorderStyle = bsNone
          Columns = <>
          GridLines = True
          ReadOnly = True
          RowSelect = True
          TabOrder = 1
          ViewStyle = vsReport
        end
      end
    end
  end
end
