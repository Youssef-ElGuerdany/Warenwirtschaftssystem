unit Warenfluss.Domain.User;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TUser = class
  private
    FID: TEntityID;
    FUsername: string;
    FPasswordHash: string;
    FPasswordSalt: string;
    FFullName: string;
    FEmail: string;
    FRole: TRoleType;
    FIsActive: Boolean;
    FCreatedAt: TDateTime;
    FLastLoginAt: TDateTime;
  public
    constructor Create;
    property ID: TEntityID read FID write FID;
    property Username: string read FUsername write FUsername;
    property PasswordHash: string read FPasswordHash write FPasswordHash;
    property PasswordSalt: string read FPasswordSalt write FPasswordSalt;
    property FullName: string read FFullName write FFullName;
    property Email: string read FEmail write FEmail;
    property Role: TRoleType read FRole write FRole;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property LastLoginAt: TDateTime read FLastLoginAt write FLastLoginAt;
  end;

implementation

constructor TUser.Create;
begin
  inherited Create;
  FID := 0;
  FRole := roleWarehouseClerk;
  FIsActive := True;
  FCreatedAt := Now;
  FLastLoginAt := 0;
end;

end.
