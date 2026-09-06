object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Warenfluss - Anmeldung'
  ClientHeight = 360
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlBackground: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 360
    Align = alClient
    BevelOuter = bvNone
    Color = clWhitesmoke
    ParentBackground = False
    TabOrder = 0
    object pnlCard: TPanel
      Left = 24
      Top = 20
      Width = 370
      Height = 315
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblTitle: TLabel
        Left = 24
        Top = 20
        Width = 131
        Height = 30
        Caption = 'WARENFLUSS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13854720
        Font.Height = -21
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblSubtitle: TLabel
        Left = 24
        Top = 48
        Width = 220
        Height = 15
        Caption = 'Enterprise Lager- und Auftragsverwaltung'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblUsername: TLabel
        Left = 24
        Top = 85
        Width = 83
        Height = 15
        Caption = 'Benutzername'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblPassword: TLabel
        Left = 24
        Top = 145
        Width = 50
        Height = 15
        Caption = 'Passwort'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblError: TLabel
        Left = 24
        Top = 202
        Width = 320
        Height = 15
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtUsername: TEdit
        Left = 24
        Top = 105
        Width = 320
        Height = 25
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Text = 'admin'
      end
      object edtPassword: TEdit
        Left = 24
        Top = 165
        Width = 320
        Height = 25
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        PasswordChar = '*'
        TabOrder = 1
        Text = 'admin123'
      end
      object btnLogin: TButton
        Left = 24
        Top = 230
        Width = 200
        Height = 35
        Caption = 'Anmelden'
        Default = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = btnLoginClick
      end
      object btnCancel: TButton
        Left = 234
        Top = 230
        Width = 110
        Height = 35
        Cancel = True
        Caption = 'Abbrechen'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnClick = btnCancelClick
      end
    end
  end
end
