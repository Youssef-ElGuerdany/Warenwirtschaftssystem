unit Warenfluss.Domain.Customer;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TCustomer = class
  private
    FID: TEntityID;
    FCode: string;
    FCompanyName: string;
    FContactPerson: string;
    FEmail: string;
    FPhone: string;
    FAddress: string;
    FCity: string;
    FPostalCode: string;
    FCountry: string;
    FCreditLimit: Currency;
    FOutstandingBalance: Currency;
    FIsActive: Boolean;
  public
    constructor Create;
    property ID: TEntityID read FID write FID;
    property Code: string read FCode write FCode;
    property CompanyName: string read FCompanyName write FCompanyName;
    property ContactPerson: string read FContactPerson write FContactPerson;
    property Email: string read FEmail write FEmail;
    property Phone: string read FPhone write FPhone;
    property Address: string read FAddress write FAddress;
    property City: string read FCity write FCity;
    property PostalCode: string read FPostalCode write FPostalCode;
    property Country: string read FCountry write FCountry;
    property CreditLimit: Currency read FCreditLimit write FCreditLimit;
    property OutstandingBalance: Currency read FOutstandingBalance write FOutstandingBalance;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

implementation

constructor TCustomer.Create;
begin
  inherited Create;
  FID := 0;
  FCountry := 'Deutschland';
  FCreditLimit := 50000;
  FOutstandingBalance := 0;
  FIsActive := True;
end;

end.
