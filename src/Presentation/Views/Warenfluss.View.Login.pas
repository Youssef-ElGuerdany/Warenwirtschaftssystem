unit Warenfluss.View.Login;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics,
  Warenfluss.Types,
  Warenfluss.Localization,
  Warenfluss.DTOs.Auth,
  Warenfluss.Interfaces.Services;

type
  TfrmLogin = class(TForm)
    pnlBackground: TPanel;
    pnlCard: TPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    lblUsername: TLabel;
    edtUsername: TEdit;
    lblPassword: TLabel;
    edtPassword: TEdit;
    btnLogin: TButton;
    btnCancel: TButton;
    lblError: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FAuthService: IAuthenticationService;
    FAuthenticatedUser: TLoginResponseDTO;
  public
    constructor CreateWithService(AOwner: TComponent; AAuthService: IAuthenticationService); reintroduce;
    property AuthenticatedUser: TLoginResponseDTO read FAuthenticatedUser;
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

constructor TfrmLogin.CreateWithService(AOwner: TComponent; AAuthService: IAuthenticationService);
begin
  inherited Create(AOwner);
  FAuthService := AAuthService;
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  Caption := _('APP_TITLE', 'Warenfluss');
  lblTitle.Caption := 'WARENFLUSS';
  lblSubtitle.Caption := 'Enterprise Lager- und Auftragsverwaltung';
  lblUsername.Caption := _('FIELD_USERNAME', 'Benutzername');
  lblPassword.Caption := _('FIELD_PASSWORD', 'Passwort');
  btnLogin.Caption := _('BTN_LOGIN', 'Anmelden');
  btnCancel.Caption := _('BTN_CANCEL', 'Abbrechen');
  lblError.Caption := '';
  edtUsername.Text := 'admin';
  edtPassword.Text := 'admin123';
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  Req: TLoginRequestDTO;
begin
  if not Assigned(FAuthService) then
  begin
    ModalResult := mrOk;
    Exit;
  end;

  Req.Username := Trim(edtUsername.Text);
  Req.Password := Trim(edtPassword.Text);
  Req.ClientIP := '127.0.0.1';

  FAuthenticatedUser := FAuthService.Login(Req);
  if FAuthenticatedUser.Success then
  begin
    ModalResult := mrOk;
  end
  else
  begin
    lblError.Caption := FAuthenticatedUser.ErrorMessage;
    lblError.Font.Color := clRed;
  end;
end;

procedure TfrmLogin.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
