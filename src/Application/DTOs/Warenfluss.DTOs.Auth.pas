unit Warenfluss.DTOs.Auth;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TLoginRequestDTO = record
    Username: string;
    Password: string;
    ClientIP: string;
  end;

  TLoginResponseDTO = record
    Success: Boolean;
    UserID: TEntityID;
    Username: string;
    FullName: string;
    Role: TRoleType;
    RoleName: string;
    Token: string;
    ErrorMessage: string;
  end;

  TUserDTO = record
    ID: TEntityID;
    Username: string;
    FullName: string;
    Email: string;
    Role: TRoleType;
    RoleName: string;
    IsActive: Boolean;
    CreatedAt: TDateTime;
    LastLoginAt: TDateTime;
  end;

  TUserCreateDTO = record
    Username: string;
    Password: string;
    FullName: string;
    Email: string;
    Role: TRoleType;
  end;

  TUserUpdateDTO = record
    ID: TEntityID;
    FullName: string;
    Email: string;
    Role: TRoleType;
    IsActive: Boolean;
    NewPassword: string;
  end;

implementation

end.
