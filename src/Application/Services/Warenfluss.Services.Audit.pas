unit Warenfluss.Services.Audit;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.Domain.AuditLog,
  Warenfluss.DTOs.Report,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TAuditService = class(TInterfacedObject, IAuditService)
  private
    FRepo: IAuditRepository;
  public
    constructor Create(ARepo: IAuditRepository);
    procedure LogAction(AUserID: TEntityID; const AUsername, AAction, AEntityName: string; AEntityID: TEntityID; const ADetails, AClientIP: string);
    function GetRecentLogs(ALimit: Integer = 200): TArray<TAuditLogDTO>;
    function GetLogsForEntity(const AEntityName: string; AEntityID: TEntityID): TArray<TAuditLogDTO>;
  end;

implementation

constructor TAuditService.Create(ARepo: IAuditRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

procedure TAuditService.LogAction(AUserID: TEntityID; const AUsername, AAction, AEntityName: string;
  AEntityID: TEntityID; const ADetails, AClientIP: string);
var
  Log: TAuditLog;
begin
  if not Assigned(FRepo) then Exit;
  Log := TAuditLog.Create;
  try
    Log.UserID := AUserID;
    Log.Username := AUsername;
    Log.Action := AAction;
    Log.EntityName := AEntityName;
    Log.EntityID := AEntityID;
    Log.Details := ADetails;
    Log.ClientIP := AClientIP;
    Log.Timestamp := Now;
    FRepo.AddLog(Log);
  finally
    Log.Free;
  end;
end;

function TAuditService.GetRecentLogs(ALimit: Integer): TArray<TAuditLogDTO>;
var
  List: TObjectList<TAuditLog>;
  I: Integer;
begin
  List := FRepo.GetAll(ALimit);
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
    begin
      Result[I].ID := List[I].ID;
      Result[I].Timestamp := List[I].Timestamp;
      Result[I].UserID := List[I].UserID;
      Result[I].Username := List[I].Username;
      Result[I].Action := List[I].Action;
      Result[I].EntityName := List[I].EntityName;
      Result[I].EntityID := List[I].EntityID;
      Result[I].Details := List[I].Details;
      Result[I].ClientIP := List[I].ClientIP;
    end;
  finally
    List.Free;
  end;
end;

function TAuditService.GetLogsForEntity(const AEntityName: string; AEntityID: TEntityID): TArray<TAuditLogDTO>;
var
  List: TObjectList<TAuditLog>;
  I: Integer;
begin
  List := FRepo.GetByEntity(AEntityName, AEntityID);
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
    begin
      Result[I].ID := List[I].ID;
      Result[I].Timestamp := List[I].Timestamp;
      Result[I].UserID := List[I].UserID;
      Result[I].Username := List[I].Username;
      Result[I].Action := List[I].Action;
      Result[I].EntityName := List[I].EntityName;
      Result[I].EntityID := List[I].EntityID;
      Result[I].Details := List[I].Details;
      Result[I].ClientIP := List[I].ClientIP;
    end;
  finally
    List.Free;
  end;
end;

end.
