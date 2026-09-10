unit Test.AuthenticationService;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Security,
  Warenfluss.Domain.User,
  Warenfluss.DTOs.Auth,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services,
  Warenfluss.Services.Authentication,
  Warenfluss.Services.Audit,
  Warenfluss.Repositories.Mock,
  Warenfluss.ORM.DataSeeder,
  Warenfluss.TestRunner;

type
  TTestAuthenticationService = class(TTestCase)
  private
    FUserRepo: IUserRepository;
    FAuditRepo: IAuditRepository;
    FAuditService: IAuditService;
    FAuthService: IAuthenticationService;
  public
    procedure SetUp; override;
    procedure TestSuccessfulLogin;
    procedure TestInvalidPassword;
    procedure TestUserNotFound;
    procedure TestInactiveUser;
    procedure TestValidateToken;
    procedure TestSeededDefaultUsers;
  end;

implementation

procedure TTestAuthenticationService.SetUp;
var
  Admin: TUser;
  Salt, Hash: string;
begin
  FUserRepo := TMockUserRepository.Create;
  FAuditRepo := TMockAuditRepository.Create;
  FAuditService := TAuditService.Create(FAuditRepo);
  FAuthService := TAuthenticationService.Create(FUserRepo, FAuditService);

  Salt := TSecurityHelper.GenerateSalt(16);
  Hash := TSecurityHelper.HashPassword('secret123', Salt);

  Admin := TUser.Create;
  Admin.Username := 'testadmin';
  Admin.FullName := 'Test Administrator';
  Admin.Role := roleAdmin;
  Admin.PasswordSalt := Salt;
  Admin.PasswordHash := Hash;
  Admin.IsActive := True;
  FUserRepo.Save(Admin);
end;

procedure TTestAuthenticationService.TestSuccessfulLogin;
var
  Req: TLoginRequestDTO;
  Resp: TLoginResponseDTO;
begin
  Req.Username := 'testadmin';
  Req.Password := 'secret123';
  Req.ClientIP := '127.0.0.1';

  Resp := FAuthService.Login(Req);
  AssertTrue(Resp.Success, 'Login should succeed for valid credentials');
  AssertEquals('testadmin', Resp.Username, 'Username should match');
  AssertTrue(Resp.Token <> '', 'Token should not be empty');
  AssertTrue(FAuthService.ValidateToken(Resp.Token), 'Generated token should be valid');
end;

procedure TTestAuthenticationService.TestInvalidPassword;
var
  Req: TLoginRequestDTO;
  Resp: TLoginResponseDTO;
begin
  Req.Username := 'testadmin';
  Req.Password := 'wrongpass';
  Req.ClientIP := '127.0.0.1';

  Resp := FAuthService.Login(Req);
  AssertFalse(Resp.Success, 'Login should fail for invalid password');
  AssertEquals('', Resp.Token, 'Token should be empty on failure');
end;

procedure TTestAuthenticationService.TestUserNotFound;
var
  Req: TLoginRequestDTO;
  Resp: TLoginResponseDTO;
begin
  Req.Username := 'nonexistent';
  Req.Password := 'secret123';
  Req.ClientIP := '127.0.0.1';

  Resp := FAuthService.Login(Req);
  AssertFalse(Resp.Success, 'Login should fail for nonexistent user');
end;

procedure TTestAuthenticationService.TestInactiveUser;
var
  User: TUser;
  Req: TLoginRequestDTO;
  Resp: TLoginResponseDTO;
  Salt, Hash: string;
begin
  Salt := TSecurityHelper.GenerateSalt(16);
  Hash := TSecurityHelper.HashPassword('pass123', Salt);

  User := TUser.Create;
  User.Username := 'inactive_user';
  User.PasswordSalt := Salt;
  User.PasswordHash := Hash;
  User.IsActive := False;
  FUserRepo.Save(User);

  Req.Username := 'inactive_user';
  Req.Password := 'pass123';
  Req.ClientIP := '127.0.0.1';

  Resp := FAuthService.Login(Req);
  AssertFalse(Resp.Success, 'Login should fail for inactive user');
end;

procedure TTestAuthenticationService.TestValidateToken;
var
  Req: TLoginRequestDTO;
  Resp: TLoginResponseDTO;
begin
  Req.Username := 'testadmin';
  Req.Password := 'secret123';
  Req.ClientIP := '127.0.0.1';

  Resp := FAuthService.Login(Req);
  AssertTrue(FAuthService.ValidateToken(Resp.Token), 'Valid token must pass validation');
  AssertFalse(FAuthService.ValidateToken('invalid_dummy_token_999'), 'Invalid token must fail validation');

  FAuthService.Logout(Resp.Token);
  AssertFalse(FAuthService.ValidateToken(Resp.Token), 'Token must be invalidated after logout');
end;

procedure TTestAuthenticationService.TestSeededDefaultUsers;
var
  Req: TLoginRequestDTO;
  Resp: TLoginResponseDTO;
begin
  TDataSeeder.SeedDefaultData(FUserRepo, nil, nil, nil, nil, nil, nil);

  // 1. Test seeded admin credentials
  Req.Username := 'admin';
  Req.Password := 'admin123';
  Req.ClientIP := '127.0.0.1';
  Resp := FAuthService.Login(Req);
  AssertTrue(Resp.Success, 'Login must succeed for seeded admin');
  AssertEquals('admin', Resp.Username, 'Username must be admin');
  AssertEquals('System Administrator', Resp.FullName, 'FullName must match seeded data');

  // 2. Test seeded clerk credentials
  Req.Username := 'clerk';
  Req.Password := 'user123';
  Req.ClientIP := '127.0.0.1';
  Resp := FAuthService.Login(Req);
  AssertTrue(Resp.Success, 'Login must succeed for seeded clerk');
  AssertEquals('clerk', Resp.Username, 'Username must be clerk');
end;

initialization
  TTestRunner.RegisterTest(TTestAuthenticationService);

end.
