unit Warenfluss.Services.Warehouse;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Domain.Warehouse,
  Warenfluss.DTOs.Product,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TWarehouseService = class(TInterfacedObject, IWarehouseService)
  private
    FRepo: IWarehouseRepository;
  public
    constructor Create(ARepo: IWarehouseRepository);
    function GetAllWarehouses: TArray<TWarehouseDTO>;
    function GetWarehouseByID(AID: TEntityID): TWarehouseDTO;
    function SaveWarehouse(const ADTO: TWarehouseDTO): TOperationResult;
    function DeleteWarehouse(AID: TEntityID): TOperationResult;
  end;

implementation

constructor TWarehouseService.Create(ARepo: IWarehouseRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

function TWarehouseService.GetAllWarehouses: TArray<TWarehouseDTO>;
var
  List: TObjectList<TWarehouse>;
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
      Result[I].Location := List[I].Location;
      Result[I].IsActive := List[I].IsActive;
    end;
  finally
    List.Free;
  end;
end;

function TWarehouseService.GetWarehouseByID(AID: TEntityID): TWarehouseDTO;
var
  WH: TWarehouse;
begin
  WH := FRepo.GetByID(AID);
  if WH = nil then
    raise EEntityNotFoundException.Create('Warehouse', IntToStr(AID));
  Result.ID := WH.ID;
  Result.Code := WH.Code;
  Result.Name := WH.Name;
  Result.Location := WH.Location;
  Result.IsActive := WH.IsActive;
end;

function TWarehouseService.SaveWarehouse(const ADTO: TWarehouseDTO): TOperationResult;
var
  WH: TWarehouse;
  NewID: TEntityID;
begin
  if Trim(ADTO.Name) = '' then
    raise EValidationException.Create('Warehouse name cannot be empty.');

  if ADTO.ID > 0 then
    WH := FRepo.GetByID(ADTO.ID)
  else
    WH := TWarehouse.Create;

  try
    WH.Code := Trim(ADTO.Code);
    WH.Name := Trim(ADTO.Name);
    WH.Location := Trim(ADTO.Location);
    WH.IsActive := ADTO.IsActive;
    NewID := FRepo.Save(WH);
    Result := TOperationResult.Ok('Warehouse saved successfully.', NewID);
  finally
    if ADTO.ID = 0 then
      WH.Free;
  end;
end;

function TWarehouseService.DeleteWarehouse(AID: TEntityID): TOperationResult;
begin
  FRepo.Delete(AID);
  Result := TOperationResult.Ok('Warehouse deleted.', AID);
end;

end.
