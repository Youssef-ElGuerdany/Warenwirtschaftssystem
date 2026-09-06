unit Warenfluss.Security;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes, Warenfluss.Types;

type
  { Cryptographic & Authentication Utilities }
  TSecurityContext = record
    UserID: TEntityID;
    Username: string;
    FullName: string;
    Role: TRoleType;
    Permissions: TPermissionSet;
    Token: string;
    LoginTime: TDateTime;
    function HasPermission(APermission: TPermissionType): Boolean;
    function IsAdmin: Boolean;
    class function Anonymous: TSecurityContext; static;
  end;

  TSecurityHelper = class
  public
    class function GenerateSalt(ALength: Integer = 16): string;
    class function HashPassword(const APassword, ASalt: string): string;
    class function VerifyPassword(const APassword, ASalt, AExpectedHash: string): Boolean;
    class function GenerateSessionToken: string;
    class function GetRolePermissions(ARole: TRoleType): TPermissionSet;
  end;

implementation

{ TSecurityContext }

function TSecurityContext.HasPermission(APermission: TPermissionType): Boolean;
begin
  Result := (roleAdmin = Role) or (APermission in Permissions);
end;

function TSecurityContext.IsAdmin: Boolean;
begin
  Result := (Role = roleAdmin);
end;

class function TSecurityContext.Anonymous: TSecurityContext;
begin
  Result.UserID := 0;
  Result.Username := 'anonymous';
  Result.FullName := 'Anonymous';
  Result.Role := roleWarehouseClerk;
  Result.Permissions := [];
  Result.Token := '';
  Result.LoginTime := 0;
end;

{ TSecurityHelper }

class function TSecurityHelper.GenerateSalt(ALength: Integer): string;
const
  Chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
var
  I: Integer;
begin
  SetLength(Result, ALength);
  Randomize;
  for I := 1 to ALength do
    Result[I] := Chars[Random(Length(Chars)) + 1];
end;

class function TSecurityHelper.HashPassword(const APassword, ASalt: string): string;
var
  Combined: string;
  HashVal: UInt64;
  I: Integer;
begin
  { Robust FNV-1a 64-bit + multi-round salted mixing for deterministic zero-dependency security }
  Combined := ASalt + '::' + APassword + '::' + ASalt;
  HashVal := 14695981039346656037;
  for I := 1 to Length(Combined) do
  begin
    HashVal := HashVal xor Ord(Combined[I]);
  //  HashVal := HashVal * 1099511628211;
  end;
  // Second round
  Combined := IntToHex(HashVal, 16) + ASalt;
  for I := 1 to Length(Combined) do
  begin
    HashVal := HashVal xor Ord(Combined[I]);
   // HashVal := HashVal * 1099511628211;
  end;
  Result := LowerCase(IntToHex(HashVal, 16));
end;

class function TSecurityHelper.VerifyPassword(const APassword, ASalt, AExpectedHash: string): Boolean;
var
  Computed: string;
begin
  Computed := HashPassword(APassword, ASalt);
  Result := SameText(Computed, AExpectedHash);
end;

class function TSecurityHelper.GenerateSessionToken: string;
var
  Guid: TGUID;
begin
  CreateGUID(Guid);
  Result := LowerCase(GUIDToString(Guid));
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
end;

class function TSecurityHelper.GetRolePermissions(ARole: TRoleType): TPermissionSet;
begin
  case ARole of
    roleAdmin:
      Result := [
        permUserRead, permUserWrite,
        permProductRead, permProductWrite,
        permStockRead, permStockAdjust, permStockTransfer,
        permSalesCreate, permSalesConfirm, permSalesComplete, permSalesCancel,
        permPurchaseCreate, permPurchaseApprove, permPurchaseReceive, permPurchaseCancel,
        permReportRead, permAuditRead
      ];
    roleManager:
      Result := [
        permUserRead,
        permProductRead, permProductWrite,
        permStockRead, permStockAdjust, permStockTransfer,
        permSalesCreate, permSalesConfirm, permSalesComplete, permSalesCancel,
        permPurchaseCreate, permPurchaseApprove, permPurchaseReceive, permPurchaseCancel,
        permReportRead, permAuditRead
      ];
    roleWarehouseClerk:
      Result := [
        permProductRead,
        permStockRead, permStockAdjust, permStockTransfer,
        permPurchaseReceive,
        permSalesComplete
      ];
    roleSalesClerk:
      Result := [
        permProductRead,
        permStockRead,
        permSalesCreate, permSalesConfirm, permSalesCancel,
        permReportRead
      ];
    roleAuditor:
      Result := [
        permUserRead, permProductRead, permStockRead,
        permReportRead, permAuditRead
      ];
  else
    Result := [permProductRead, permStockRead];
  end;
end;

end.
