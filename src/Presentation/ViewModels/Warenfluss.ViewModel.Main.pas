unit Warenfluss.ViewModel.Main;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  Warenfluss.Types,
  Warenfluss.DTOs.Auth,
  Warenfluss.DTOs.Report,
  Warenfluss.Interfaces.Services,
  Warenfluss.ViewModel.Base;

type
  TMainViewModel = class(TBaseViewModel)
  private
    FReportService: IReportService;
    FAuthService: IAuthenticationService;
    FCurrentUser: TUserDTO;
    FDashboard: TDashboardSummaryDTO;
  public
    constructor Create(AReportService: IReportService; AAuthService: IAuthenticationService);
    procedure RefreshDashboard;
    procedure SetUser(const AUser: TUserDTO);

    property CurrentUser: TUserDTO read FCurrentUser;
    property Dashboard: TDashboardSummaryDTO read FDashboard;
  end;

implementation

constructor TMainViewModel.Create(AReportService: IReportService; AAuthService: IAuthenticationService);
begin
  inherited Create;
  FReportService := AReportService;
  FAuthService := AAuthService;
end;

procedure TMainViewModel.SetUser(const AUser: TUserDTO);
begin
  FCurrentUser := AUser;
  NotifyChanged;
end;

procedure TMainViewModel.RefreshDashboard;
begin
  IsBusy := True;
  try
    if Assigned(FReportService) then
      FDashboard := FReportService.GetDashboardSummary;
    StatusMessage := 'Dashboard updated';
    NotifyChanged;
  finally
    IsBusy := False;
  end;
end;

end.
