unit Warenfluss.Services.Authentication;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Security,
  Warenfluss.Events,
  Warenfluss.Domain.User,
  Warenfluss.DTOs.Auth,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TAuthenticationService = class(TInterfacedObject, IAuthenticationService)
  private
    FUserRepo: IUserRepository;
    FAuditService: IAuditService;
    FSessions: TDictionary<string, TSecurityContext>;
  public
    constructor Create(AUserRepo: IUserRepository; AAuditService: IAuditService);
    destructor Destroy; override;

    function Login(const ARequest: TLoginRequestDTO): TLoginResponseDTO;
    procedure Logout(const AToken: string);
    function ValidateToken(const AToken: string): Boolean;
    function GetCurrentUser(const AToken: string): TUserDTO;
  end;

implementation

constructor TAuthenticationService.Create(AUserRepo: IUserRepository; AAuditService: IAuditService);
begin
  inherited Create;
  FUserRepo := AUserRepo;
  FAuditService := AAuditService;
  FSessions := TDictionary<string, TSecurityContext>.Create;
end;

destructor TAuthenticationService.Destroy;
begin
  FSessions.Free;
  inherited Destroy;
end;

function TAuthenticationService.Login(const ARequest: TLoginRequestDTO): TLoginResponseDTO;
var
  User: TUser;
  Ctx: TSecurityContext;
  Token: string;
begin
  Result.Success := False;
  Result.UserID := 0;
  Result.Username := ARequest.Username;
  Result.FullName := '';
  Result.Role := roleWarehouseClerk;
  Result.RoleName := '';
  Result.Token := '';
  Result.ErrorMessage := '';

  User := FUserRepo.GetByUsername(ARequest.Username);
  if User = nil then
  begin
    Result.ErrorMessage := 'Invalid username or password.';
    Exit;
  end;

  if not User.IsActive then
  begin
    Result.ErrorMessage := 'User account is inactive.';
    Exit;
  end;

  if not TSecurityHelper.VerifyPassword(ARequest.Password, User.PasswordSalt, User.PasswordHash) then
  begin
    Result.ErrorMessage := 'Invalid username or password.';
    Exit;
  end;

  // Generate token and session
  Token := TSecurityHelper.GenerateSessionToken;
  Ctx.UserID := User.ID;
  Ctx.Username := User.Username;
  Ctx.FullName := User.FullName;
  Ctx.Role := User.Role;
  Ctx.Permissions := TSecurityHelper.GetRolePermissions(User.Role);
  Ctx.Token := Token;
  Ctx.LoginTime := Now;

  FSessions.AddOrSetValue(Token, Ctx);

  // Update LastLoginAt
  User.LastLoginAt := Now;
  FUserRepo.Save(User);

  // Audit and Event
  if Assigned(FAuditService) then
    FAuditService.LogAction(User.ID, User.Username, 'LOGIN', 'User', User.ID, 'User logged in successfully', ARequest.ClientIP);

  TDomainEventBus.Instance.Publish(TUserLoggedInEvent.Create(User.ID, User.Username, ARequest.ClientIP));

  Result.Success := True;
  Result.UserID := User.ID;
  Result.Username := User.Username;
  Result.FullName := User.FullName;
  Result.Role := User.Role;
  Result.RoleName := RoleTypeToString(User.Role);
  Result.Token := Token;
end;

procedure TAuthenticationService.Logout(const AToken: string);
begin
  if FSessions.ContainsKey(AToken) then
    FSessions.Remove(AToken);
end;

function TAuthenticationService.ValidateToken(const AToken: string): Boolean;
begin
  Result := FSessions.ContainsKey(AToken);
end;

function TAuthenticationService.GetCurrentUser(const AToken: string): TUserDTO;
var
  Ctx: TSecurityContext;
begin
  if FSessions.TryGetValue(AToken, Ctx) then
  begin
    Result.ID := Ctx.UserID;
    Result.Username := Ctx.Username;
    Result.FullName := Ctx.FullName;
    Result.Email := '';
    Result.Role := Ctx.Role;
    Result.RoleName := RoleTypeToString(Ctx.Role);
    Result.IsActive := True;
    Result.CreatedAt := 0;
    Result.LastLoginAt := Ctx.LoginTime;
  end
  else
    raise EUnauthorizedException.Create('Session invalid or expired.');
end;

end.
