unit Warenfluss.ViewModel.Base;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes;

type
  TNotifyViewModelEvent = procedure of object;

  TBaseViewModel = class
  private
    FOnChanged: TNotifyViewModelEvent;
    FIsBusy: Boolean;
    FStatusMessage: string;
  protected
    procedure NotifyChanged; virtual;
  public
    constructor Create; virtual;
    property IsBusy: Boolean read FIsBusy write FIsBusy;
    property StatusMessage: string read FStatusMessage write FStatusMessage;
    property OnChanged: TNotifyViewModelEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TBaseViewModel.Create;
begin
  inherited Create;
  FIsBusy := False;
  FStatusMessage := '';
end;

procedure TBaseViewModel.NotifyChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged();
end;

end.
