unit Warenfluss.ORM.Database;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes,
  mormot.core.base,
  mormot.core.os,
  mormot.orm.core,
  mormot.orm.sqlite3,
  Warenfluss.ORM.Models;

type
  TWarenflussDatabase = class
  private
    FModel: TOrmModel;
    FRestServer: TRestOrmServerDB;
    FDatabasePath: TFileName;
  public
    constructor Create(const ADBPath: TFileName = '');
    destructor Destroy; override;

    property Model: TOrmModel read FModel;
    property RestServer: TRestOrmServerDB read FRestServer;
    property DatabasePath: TFileName read FDatabasePath;
  end;

implementation

constructor TWarenflussDatabase.Create(const ADBPath: TFileName);
var
  DataDir: string;
begin
  inherited Create;
  if ADBPath <> '' then
    FDatabasePath := ADBPath
  else
  begin
    DataDir := ExtractFilePath(ParamStr(0)) + 'data' + PathDelim;
    if not DirectoryExists(DataDir) then
      ForceDirectories(DataDir);
    FDatabasePath := DataDir + 'warenfluss.db3';
  end;

  FModel := CreateWarenflussModel;
  FRestServer := TRestOrmServerDB.CreateStandalone(FModel, nil, FDatabasePath);
end;

destructor TWarenflussDatabase.Destroy;
begin
  FRestServer.Free;
  FModel.Free;
  inherited Destroy;
end;

end.
