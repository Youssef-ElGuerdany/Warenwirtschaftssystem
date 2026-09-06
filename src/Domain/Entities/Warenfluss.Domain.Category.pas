unit Warenfluss.Domain.Category;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TCategory = class
  private
    FID: TEntityID;
    FCode: string;
    FName: string;
    FDescription: string;
    FIsActive: Boolean;
  public
    constructor Create;
    property ID: TEntityID read FID write FID;
    property Code: string read FCode write FCode;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

implementation

constructor TCategory.Create;
begin
  inherited Create;
  FID := 0;
  FIsActive := True;
end;

end.
