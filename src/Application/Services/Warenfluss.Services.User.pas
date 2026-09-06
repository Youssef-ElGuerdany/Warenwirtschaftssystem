unit Warenfluss.Services.User;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Security,
  Warenfluss.Domain.User,
  Warenfluss.DTOs.Auth,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TUserService = class(TInterfacedObject, IUserService)
  private
    FUserRepo: IUserRepository;
    FAuditService: IAuditService;
    function EntityToDTO(AUser: TUser): TUserDTO;
  public
    constructor Create(AUserRepo: IUserRepository; AAuditService: IAuditService);

    function GetAllUsers: TArray<TUserDTO>;
    function GetUserByID(AID: TEntityID): TUserDTO;
    function CreateUser(const ADTO: TUserCreateDTO): TOperationResult;
    function UpdateUser(const ADTO: TUserUpdateDTO): TOperationResult;
    function DeactivateUser(AID: TEntityID): TOperationResult;
  end;

implementation

constructor TUserService.Create(AUserRepo: IUserRepository; AAuditService: IAuditService);
begin
  inherited Create;
  FUserRepo := AUserRepo;
  FAuditService := AAuditService;
end;

function TUserService.EntityToDTO(AUser: TUser): TUserDTO;
begin
  if AUser = nil then Exit;
  Result.ID := AUser.ID;
  Result.Username := AUser.Username;
  Result.FullName := AUser.FullName;
  Result.Email := AUser.Email;
  Result.Role := AUser.Role;
  Result.RoleName := RoleTypeToString(AUser.Role);
  Result.IsActive := AUser.IsActive;
  Result.CreatedAt := AUser.CreatedAt;
  Result.LastLoginAt := AUser.LastLoginAt;
end;

function TUserService.GetAllUsers: TArray<TUserDTO>;
var
  List: TObjectList<TUser>;
  I: Integer;
begin
  List := FUserRepo.GetAll;
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
      Result[I] := EntityToDTO(List[I]);
  finally
    List.Free;
  end;
end;

function TUserService.GetUserByID(AID: TEntityID): TUserDTO;
var
  User: TUser;
begin
  User := FUserRepo.GetByID(AID);
  if User = nil then
    raise EEntityNotFoundException.Create('User', IntToStr(AID));
  Result := EntityToDTO(User);
end;

function TUserService.CreateUser(const ADTO: TUserCreateDTO): TOperationResult;
var
  User: TUser;
  Salt: string;
  Hash: string;
  NewID: TEntityID;
begin
  if Trim(ADTO.Username) = '' then
    raise EValidationException.Create('Username cannot be empty.');

  if Trim(ADTO.Password) = '' then
    raise EValidationException.Create('Password cannot be empty.');

  if FUserRepo.GetByUsername(ADTO.Username) <> nil then
    raise EConflictException.Create(Format('User "%s" already exists.', [ADTO.Username]));

  Salt := TSecurityHelper.GenerateSalt(16);
  Hash := TSecurityHelper.HashPassword(ADTO.Password, Salt);

  User := TUser.Create;
  try
    User.Username := Trim(ADTO.Username);
    User.FullName := Trim(ADTO.FullName);
    User.Email := Trim(ADTO.Email);
    User.Role := ADTO.Role;
    User.PasswordSalt := Salt;
    User.PasswordHash := Hash;
    User.IsActive := True;
    User.CreatedAt := Now;

    NewID := FUserRepo.Save(User);
    if Assigned(FAuditService) then
      FAuditService.LogAction(0, 'System', 'USER_CREATED', 'User', NewID, 'Created user ' + User.Username, '127.0.0.1');

    Result := TOperationResult.Ok('User created successfully.', NewID);
  finally
    User.Free;
  end;
end;

function TUserService.UpdateUser(const ADTO: TUserUpdateDTO): TOperationResult;
var
  User: TUser;
  Salt, Hash: string;
begin
  User := FUserRepo.GetByID(ADTO.ID);
  if User = nil then
    raise EEntityNotFoundException.Create('User', IntToStr(ADTO.ID));

  User.FullName := Trim(ADTO.FullName);
  User.Email := Trim(ADTO.Email);
  User.Role := ADTO.Role;
  User.IsActive := ADTO.IsActive;

  if Trim(ADTO.NewPassword) <> '' then
  begin
    Salt := TSecurityHelper.GenerateSalt(16);
    Hash := TSecurityHelper.HashPassword(ADTO.NewPassword, Salt);
    User.PasswordSalt := Salt;
    User.PasswordHash := Hash;
  end;

  FUserRepo.Save(User);
  if Assigned(FAuditService) then
    FAuditService.LogAction(0, 'System', 'USER_UPDATED', 'User', User.ID, 'Updated user ' + User.Username, '127.0.0.1');

  Result := TOperationResult.Ok('User updated successfully.', User.ID);
end;

function TUserService.DeactivateUser(AID: TEntityID): TOperationResult;
var
  User: TUser;
begin
  User := FUserRepo.GetByID(AID);
  if User = nil then
    raise EEntityNotFoundException.Create('User', IntToStr(AID));

  User.IsActive := False;
  FUserRepo.Save(User);

  if Assigned(FAuditService) then
    FAuditService.LogAction(0, 'System', 'USER_DEACTIVATED', 'User', User.ID, 'Deactivated user ' + User.Username, '127.0.0.1');

  Result := TOperationResult.Ok('User deactivated.', AID);
end;

end.
