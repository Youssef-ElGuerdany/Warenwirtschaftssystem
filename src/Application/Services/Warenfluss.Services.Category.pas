unit Warenfluss.Services.Category;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Domain.Category,
  Warenfluss.DTOs.Product,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TCategoryService = class(TInterfacedObject, ICategoryService)
  private
    FRepo: ICategoryRepository;
  public
    constructor Create(ARepo: ICategoryRepository);
    function GetAllCategories: TArray<TCategoryDTO>;
    function GetCategoryByID(AID: TEntityID): TCategoryDTO;
    function SaveCategory(const ADTO: TCategoryDTO): TOperationResult;
    function DeleteCategory(AID: TEntityID): TOperationResult;
  end;

implementation

constructor TCategoryService.Create(ARepo: ICategoryRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

function TCategoryService.GetAllCategories: TArray<TCategoryDTO>;
var
  List: TObjectList<TCategory>;
  I: Integer;
begin
  List := FRepo.GetAll;
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
    begin
      Result[I].ID := List[I].ID;
      Result[I].Code := List[I].Code;
      Result[I].Name := List[I].Name;
      Result[I].Description := List[I].Description;
      Result[I].IsActive := List[I].IsActive;
    end;
  finally
    List.Free;
  end;
end;

function TCategoryService.GetCategoryByID(AID: TEntityID): TCategoryDTO;
var
  Cat: TCategory;
begin
  Cat := FRepo.GetByID(AID);
  if Cat = nil then
    raise EEntityNotFoundException.Create('Category', IntToStr(AID));
  Result.ID := Cat.ID;
  Result.Code := Cat.Code;
  Result.Name := Cat.Name;
  Result.Description := Cat.Description;
  Result.IsActive := Cat.IsActive;
end;

function TCategoryService.SaveCategory(const ADTO: TCategoryDTO): TOperationResult;
var
  Cat: TCategory;
  NewID: TEntityID;
begin
  if Trim(ADTO.Name) = '' then
    raise EValidationException.Create('Category name cannot be empty.');

  if ADTO.ID > 0 then
    Cat := FRepo.GetByID(ADTO.ID)
  else
    Cat := TCategory.Create;

  try
    Cat.Code := Trim(ADTO.Code);
    Cat.Name := Trim(ADTO.Name);
    Cat.Description := Trim(ADTO.Description);
    Cat.IsActive := ADTO.IsActive;
    NewID := FRepo.Save(Cat);
    Result := TOperationResult.Ok('Category saved successfully.', NewID);
  finally
    if ADTO.ID = 0 then
      Cat.Free;
  end;
end;

function TCategoryService.DeleteCategory(AID: TEntityID): TOperationResult;
begin
  FRepo.Delete(AID);
  Result := TOperationResult.Ok('Category deleted.', AID);
end;

end.
