unit Warenfluss.Domain.AuditLog;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TAuditLog = class
  private
    FID: TEntityID;
    FTimestamp: TDateTime;
    FUserID: TEntityID;
    FUsername: string;
    FAction: string;
    FEntityName: string;
    FEntityID: TEntityID;
    FDetails: string;
    FClientIP: string;
  public
    constructor Create;
    property ID: TEntityID read FID write FID;
    property Timestamp: TDateTime read FTimestamp write FTimestamp;
    property UserID: TEntityID read FUserID write FUserID;
    property Username: string read FUsername write FUsername;
    property Action: string read FAction write FAction;
    property EntityName: string read FEntityName write FEntityName;
    property EntityID: TEntityID read FEntityID write FEntityID;
    property Details: string read FDetails write FDetails;
    property ClientIP: string read FClientIP write FClientIP;
  end;

implementation

constructor TAuditLog.Create;
begin
  inherited Create;
  FID := 0;
  FTimestamp := Now;
  FUserID := 0;
  FEntityID := 0;
end;

end.
