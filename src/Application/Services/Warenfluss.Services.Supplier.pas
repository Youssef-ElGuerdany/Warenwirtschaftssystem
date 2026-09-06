unit Warenfluss.Services.Supplier;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Domain.Supplier,
  Warenfluss.DTOs.Product,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TSupplierService = class(TInterfacedObject, ISupplierService)
  private
    FRepo: ISupplierRepository;
  public
    constructor Create(ARepo: ISupplierRepository);
    function GetAllSuppliers: TArray<TSupplierDTO>;
    function GetSupplierByID(AID: TEntityID): TSupplierDTO;
    function SaveSupplier(const ADTO: TSupplierDTO): TOperationResult;
    function DeleteSupplier(AID: TEntityID): TOperationResult;
  end;

implementation

constructor TSupplierService.Create(ARepo: ISupplierRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

function TSupplierService.GetAllSuppliers: TArray<TSupplierDTO>;
var
  List: TObjectList<TSupplier>;
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
      Result[I].IsActive := List[I].IsActive;
    end;
  finally
    List.Free;
  end;
end;

function TSupplierService.GetSupplierByID(AID: TEntityID): TSupplierDTO;
var
  Supp: TSupplier;
begin
  Supp := FRepo.GetByID(AID);
  if Supp = nil then
    raise EEntityNotFoundException.Create('Supplier', IntToStr(AID));
  Result.ID := Supp.ID;
  Result.Code := Supp.Code;
  Result.CompanyName := Supp.CompanyName;
  Result.ContactPerson := Supp.ContactPerson;
  Result.Email := Supp.Email;
  Result.Phone := Supp.Phone;
  Result.Address := Supp.Address;
  Result.City := Supp.City;
  Result.PostalCode := Supp.PostalCode;
  Result.Country := Supp.Country;
  Result.IsActive := Supp.IsActive;
end;

function TSupplierService.SaveSupplier(const ADTO: TSupplierDTO): TOperationResult;
var
  Supp: TSupplier;
  NewID: TEntityID;
begin
  if Trim(ADTO.CompanyName) = '' then
    raise EValidationException.Create('Supplier company name cannot be empty.');

  if ADTO.ID > 0 then
    Supp := FRepo.GetByID(ADTO.ID)
  else
    Supp := TSupplier.Create;

  try
    Supp.Code := Trim(ADTO.Code);
    Supp.CompanyName := Trim(ADTO.CompanyName);
    Supp.ContactPerson := Trim(ADTO.ContactPerson);
    Supp.Email := Trim(ADTO.Email);
    Supp.Phone := Trim(ADTO.Phone);
    Supp.Address := Trim(ADTO.Address);
    Supp.City := Trim(ADTO.City);
    Supp.PostalCode := Trim(ADTO.PostalCode);
    Supp.Country := Trim(ADTO.Country);
    Supp.IsActive := ADTO.IsActive;
    NewID := FRepo.Save(Supp);
    Result := TOperationResult.Ok('Supplier saved successfully.', NewID);
  finally
    if ADTO.ID = 0 then
      Supp.Free;
  end;
end;

function TSupplierService.DeleteSupplier(AID: TEntityID): TOperationResult;
begin
  FRepo.Delete(AID);
  Result := TOperationResult.Ok('Supplier deleted.', AID);
end;

end.
