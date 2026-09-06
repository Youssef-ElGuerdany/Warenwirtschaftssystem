object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Warenfluss - Lager- und Auftragsverwaltung'
  ClientHeight = 700
  ClientWidth = 1100
  Color = 16119285
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlSidebar: TPanel
    Left = 0
    Top = 0
    Width = 240
    Height = 700
    Align = alLeft
    BevelOuter = bvNone
    Color = 2894892
    ParentBackground = False
    TabOrder = 0
    object lblBrand: TLabel
      Left = 20
      Top = 20
      Width = 160
      Height = 28
      Caption = 'WARENFLUSS'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -20
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblTagline: TLabel
      Left = 20
      Top = 50
      Width = 126
      Height = 15
      Caption = 'Enterprise Architecture'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 11842740
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object btnNavDashboard: TButton
      Left = 15
      Top = 90
      Width = 210
      Height = 40
      Caption = 'Dashboard'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnNavDashboardClick
    end
    object btnNavProducts: TButton
      Left = 15
      Top = 135
      Width = 210
      Height = 40
      Caption = 'Artikelstamm'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnNavProductsClick
    end
    object btnNavInventory: TButton
      Left = 15
      Top = 180
      Width = 210
      Height = 40
      Caption = 'Lagerbestand'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnNavInventoryClick
    end
    object btnNavSalesOrders: TButton
      Left = 15
      Top = 225
      Width = 210
      Height = 40
      Caption = 'Verkaufsauftr'#228'ge'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = btnNavSalesOrdersClick
    end
    object btnNavPurchaseOrders: TButton
      Left = 15
      Top = 270
      Width = 210
      Height = 40
      Caption = 'Einkaufsbestellungen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = btnNavPurchaseOrdersClick
    end
    object btnNavReports: TButton
      Left = 15
      Top = 315
      Width = 210
      Height = 40
      Caption = 'Berichte && Auswertung'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = btnNavReportsClick
    end
    object btnNavAudit: TButton
      Left = 15
      Top = 360
      Width = 210
      Height = 40
      Caption = 'Audit-Log'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnClick = btnNavAuditClick
    end
  end
  object pnlHeader: TPanel
    Left = 240
    Top = 0
    Width = 860
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object lblUserStatus: TLabel
      Left = 20
      Top = 22
      Width = 200
      Height = 15
      Caption = 'Angemeldet: Administrator'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4210752
      Font.Height = -13
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnLanguageToggle: TButton
      Left = 670
      Top = 14
      Width = 175
      Height = 32
      Caption = 'Sprache: Deutsch (DE)'
      TabOrder = 0
      OnClick = btnLanguageToggleClick
    end
  end
  object pnlContent: TPanel
    Left = 240
    Top = 60
    Width = 860
    Height = 640
    Align = alClient
    BevelOuter = bvNone
    Color = 16119285
    ParentBackground = False
    TabOrder = 2
    object pnlDashboardView: TPanel
      Left = 20
      Top = 20
      Width = 820
      Height = 600
      BevelOuter = bvNone
      Color = 16119285
      ParentBackground = False
      TabOrder = 0
      object lblDashTitle: TLabel
        Left = 0
        Top = 0
        Width = 195
        Height = 25
        Caption = 'Dashboard '#8211' '#220'bersicht'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3355443
        Font.Height = -19
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object pnlKpiProducts: TPanel
        Left = 0
        Top = 45
        Width = 190
        Height = 110
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblKpiProdVal: TLabel
          Left = 15
          Top = 20
          Width = 36
          Height = 37
          Caption = '12'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 13854720
          Font.Height = -27
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblKpiProdLbl: TLabel
          Left = 15
          Top = 65
          Width = 73
          Height = 15
          Caption = 'Artikel gesamt'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlKpiLowStock: TPanel
        Left = 210
        Top = 45
        Width = 190
        Height = 110
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        object lblKpiLowStockVal: TLabel
          Left = 15
          Top = 20
          Width = 16
          Height = 37
          Caption = '0'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 255
          Font.Height = -27
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblKpiLowStockLbl: TLabel
          Left = 15
          Top = 65
          Width = 145
          Height = 15
          Caption = 'Meldebestand unterschritten'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlKpiSales: TPanel
        Left = 420
        Top = 45
        Width = 190
        Height = 110
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
        object lblKpiSalesVal: TLabel
          Left = 15
          Top = 20
          Width = 16
          Height = 37
          Caption = '3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 32768
          Font.Height = -27
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblKpiSalesLbl: TLabel
          Left = 15
          Top = 65
          Width = 127
          Height = 15
          Caption = 'Offene Verkaufsauftr'#228'ge'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlKpiValuation: TPanel
        Left = 630
        Top = 45
        Width = 190
        Height = 110
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 3
        object lblKpiValuationVal: TLabel
          Left = 15
          Top = 20
          Width = 115
          Height = 37
          Caption = '42.500 '#8364
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 9127187
          Font.Height = -27
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblKpiValuationLbl: TLabel
          Left = 15
          Top = 65
          Width = 112
          Height = 15
          Caption = 'Lagergesamtwert (EK)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
    end
  end
end
