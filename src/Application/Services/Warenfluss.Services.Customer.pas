unit Warenfluss.Services.Customer;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Domain.Customer,
  Warenfluss.DTOs.Product,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TCustomerService = class(TInterfacedObject, ICustomerService)
  private
    FRepo: ICustomerRepository;
  public
    constructor Create(ARepo: ICustomerRepository);
    function GetAllCustomers: TArray<TCustomerDTO>;
    function GetCustomerByID(AID: TEntityID): TCustomerDTO;
    function SaveCustomer(const ADTO: TCustomerDTO): TOperationResult;
    function DeleteCustomer(AID: TEntityID): TOperationResult;
  end;

implementation

constructor TCustomerService.Create(ARepo: ICustomerRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

function TCustomerService.GetAllCustomers: TArray<TCustomerDTO>;
var
  List: TObjectList<TCustomer>;
  I: Integer;
begin
  List := FRepo.GetAll;
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
    begin
      Result[I].ID := List[I].ID;
      Result[I].Code := List[I].Code;
      Result[I].CompanyName := List[I].CompanyName;
      Result[I].ContactPerson := List[I].ContactPerson;
      Result[I].Email := List[I].Email;
      Result[I].Phone := List[I].Phone;
      Result[I].Address := List[I].Address;
      Result[I].City := List[I].City;
      Result[I].PostalCode := List[I].PostalCode;
      Result[I].Country := List[I].Country;
      Result[I].CreditLimit := List[I].CreditLimit;
      Result[I].OutstandingBalance := List[I].OutstandingBalance;
      Result[I].IsActive := List[I].IsActive;
    end;
  finally
    List.Free;
  end;
end;

function TCustomerService.GetCustomerByID(AID: TEntityID): TCustomerDTO;
var
  Cust: TCustomer;
begin
  Cust := FRepo.GetByID(AID);
  if Cust = nil then
    raise EEntityNotFoundException.Create('Customer', IntToStr(AID));
  Result.ID := Cust.ID;
  Result.Code := Cust.Code;
  Result.CompanyName := Cust.CompanyName;
  Result.ContactPerson := Cust.ContactPerson;
  Result.Email := Cust.Email;
  Result.Phone := Cust.Phone;
  Result.Address := Cust.Address;
  Result.City := Cust.City;
  Result.PostalCode := Cust.PostalCode;
  Result.Country := Cust.Country;
  Result.CreditLimit := Cust.CreditLimit;
  Result.OutstandingBalance := Cust.OutstandingBalance;
  Result.IsActive := Cust.IsActive;
end;

function TCustomerService.SaveCustomer(const ADTO: TCustomerDTO): TOperationResult;
var
  Cust: TCustomer;
  NewID: TEntityID;
begin
  if Trim(ADTO.CompanyName) = '' then
    raise EValidationException.Create('Customer company name cannot be empty.');

  if ADTO.ID > 0 then
    Cust := FRepo.GetByID(ADTO.ID)
  else
    Cust := TCustomer.Create;

  try
    Cust.Code := Trim(ADTO.Code);
    Cust.CompanyName := Trim(ADTO.CompanyName);
    Cust.ContactPerson := Trim(ADTO.ContactPerson);
    Cust.Email := Trim(ADTO.Email);
    Cust.Phone := Trim(ADTO.Phone);
    Cust.Address := Trim(ADTO.Address);
    Cust.City := Trim(ADTO.City);
    Cust.PostalCode := Trim(ADTO.PostalCode);
    Cust.Country := Trim(ADTO.Country);
    Cust.CreditLimit := ADTO.CreditLimit;
    Cust.OutstandingBalance := ADTO.OutstandingBalance;
    Cust.IsActive := ADTO.IsActive;
    NewID := FRepo.Save(Cust);
    Result := TOperationResult.Ok('Customer saved successfully.', NewID);
  finally
    if ADTO.ID = 0 then
      Cust.Free;
  end;
end;

function TCustomerService.DeleteCustomer(AID: TEntityID): TOperationResult;
begin
  FRepo.Delete(AID);
  Result := TOperationResult.Ok('Customer deleted.', AID);
end;

end.
