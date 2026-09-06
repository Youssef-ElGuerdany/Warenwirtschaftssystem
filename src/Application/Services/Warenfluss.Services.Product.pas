unit Warenfluss.Services.Product;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses

  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.Exceptions,
  Warenfluss.Domain.Product,
  Warenfluss.Domain.Category,

  Warenfluss.DTOs.Product,
  Warenfluss.Interfaces.Repositories,
  Warenfluss.Interfaces.Services;

type
  TProductService = class(TInterfacedObject, IProductService)
  private
    FProductRepo: IProductRepository;
    FCategoryRepo: ICategoryRepository;
    FAuditService: IAuditService;
    function EntityToDTO(AProduct: TProduct): TProductDTO;
  public
    constructor Create(AProductRepo: IProductRepository; ACategoryRepo: ICategoryRepository; AAuditService: IAuditService);

    function GetAllProducts(AOnlyActive: Boolean = True): TArray<TProductDTO>;
    function GetProductByID(AID: TEntityID): TProductDTO;
    function GetProductBySKU(const ASKU: string): TProductDTO;
    function SearchProducts(const AQuery: string): TArray<TProductDTO>;
    function GetLowStockProducts: TArray<TProductDTO>;
    function CreateProduct(const ADTO: TProductCreateDTO): TOperationResult;
    function UpdateProduct(const ADTO: TProductUpdateDTO): TOperationResult;
    function DeleteProduct(AID: TEntityID): TOperationResult;
  end;

implementation

uses Warenfluss.Domain.ProductValidator;

constructor TProductService.Create(AProductRepo: IProductRepository; ACategoryRepo: ICategoryRepository; AAuditService: IAuditService);
begin
  inherited Create;
  FProductRepo := AProductRepo;
  FCategoryRepo := ACategoryRepo;
  FAuditService := AAuditService;
end;

function TProductService.EntityToDTO(AProduct: TProduct): TProductDTO;
var
  Cat: TCategory;
begin
  if AProduct = nil then Exit;
  Result.ID := AProduct.ID;
  Result.SKU := AProduct.SKU;
  Result.Barcode := AProduct.Barcode;
  Result.Name := AProduct.Name;
  Result.Description := AProduct.Description;
  Result.CategoryID := AProduct.CategoryID;
  Result.CategoryName := '';
  if (AProduct.CategoryID > 0) and Assigned(FCategoryRepo) then
  begin
    Cat := FCategoryRepo.GetByID(AProduct.CategoryID);
    if Cat <> nil then
      Result.CategoryName := Cat.Name;
  end;
  Result.CostPrice := AProduct.CostPrice;
  Result.UnitPrice := AProduct.UnitPrice;
  Result.CurrentStockTotal := AProduct.CurrentStockTotal;
  Result.MinStockLevel := AProduct.MinStockLevel;
  Result.MaxStockLevel := AProduct.MaxStockLevel;
  Result.UnitType := AProduct.UnitType;
  Result.UnitName := ProductUnitToString(AProduct.UnitType);
  Result.IsActive := AProduct.IsActive;
  Result.IsLowStock := AProduct.IsLowStock;
end;

function TProductService.GetAllProducts(AOnlyActive: Boolean): TArray<TProductDTO>;
var
  List: TObjectList<TProduct>;
  I: Integer;
begin
  List := FProductRepo.GetAll(AOnlyActive);
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
      Result[I] := EntityToDTO(List[I]);
  finally
    List.Free;
  end;
end;

function TProductService.GetProductByID(AID: TEntityID): TProductDTO;
var
  Prod: TProduct;
begin
  Prod := FProductRepo.GetByID(AID);
  if Prod = nil then
    raise EEntityNotFoundException.Create('Product', IntToStr(AID));
  Result := EntityToDTO(Prod);
end;

function TProductService.GetProductBySKU(const ASKU: string): TProductDTO;
var
  Prod: TProduct;
begin
  Prod := FProductRepo.GetBySKU(ASKU);
  if Prod = nil then
    raise EEntityNotFoundException.Create('Product', ASKU);
  Result := EntityToDTO(Prod);
end;

function TProductService.SearchProducts(const AQuery: string): TArray<TProductDTO>;
var
  List: TObjectList<TProduct>;
  I: Integer;
begin
  List := FProductRepo.Search(AQuery);
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
      Result[I] := EntityToDTO(List[I]);
  finally
    List.Free;
  end;
end;

function TProductService.GetLowStockProducts: TArray<TProductDTO>;
var
  List: TObjectList<TProduct>;
  I: Integer;
begin
  List := FProductRepo.GetLowStockProducts;
  try
    SetLength(Result, List.Count);
    for I := 0 to List.Count - 1 do
      Result[I] := EntityToDTO(List[I]);
  finally
    List.Free;
  end;
end;

function TProductService.CreateProduct(const ADTO: TProductCreateDTO): TOperationResult;
var
  Prod: TProduct;
  Existing: TProduct;
  NewID: TEntityID;
begin
  Existing := FProductRepo.GetBySKU(ADTO.SKU);
  if Existing <> nil then
    raise EConflictException.Create(Format('Product SKU "%s" already exists.', [ADTO.SKU]));

  Prod := TProduct.Create;
  try
    Prod.SKU := Trim(ADTO.SKU);
    Prod.Barcode := Trim(ADTO.Barcode);
    Prod.Name := Trim(ADTO.Name);
    Prod.Description := Trim(ADTO.Description);
    Prod.CategoryID := ADTO.CategoryID;
    Prod.CostPrice := ADTO.CostPrice;
    Prod.UnitPrice := ADTO.UnitPrice;
    Prod.MinStockLevel := ADTO.MinStockLevel;
    Prod.MaxStockLevel := ADTO.MaxStockLevel;
    Prod.UnitType := ADTO.UnitType;
    Prod.IsActive := True;

    TProductValidator.Validate(Prod);

    NewID := FProductRepo.Save(Prod);
    if Assigned(FAuditService) then
      FAuditService.LogAction(0, 'System', 'PRODUCT_CREATED', 'Product', NewID, 'Created product ' + Prod.SKU, '127.0.0.1');

    Result := TOperationResult.Ok('Product created successfully.', NewID);
  except
    Prod.Free;
    raise;
  end;
end;

function TProductService.UpdateProduct(const ADTO: TProductUpdateDTO): TOperationResult;
var
  Prod: TProduct;
  Existing: TProduct;
begin
  Prod := FProductRepo.GetByID(ADTO.ID);
  if Prod = nil then
    raise EEntityNotFoundException.Create('Product', IntToStr(ADTO.ID));

  Existing := FProductRepo.GetBySKU(ADTO.SKU);
  if (Existing <> nil) and (Existing.ID <> ADTO.ID) then
    raise EConflictException.Create(Format('Product SKU "%s" already belongs to another product.', [ADTO.SKU]));

  Prod.SKU := Trim(ADTO.SKU);
  Prod.Barcode := Trim(ADTO.Barcode);
  Prod.Name := Trim(ADTO.Name);
  Prod.Description := Trim(ADTO.Description);
  Prod.CategoryID := ADTO.CategoryID;
  Prod.CostPrice := ADTO.CostPrice;
  Prod.UnitPrice := ADTO.UnitPrice;
  Prod.MinStockLevel := ADTO.MinStockLevel;
  Prod.MaxStockLevel := ADTO.MaxStockLevel;
  Prod.UnitType := ADTO.UnitType;
  Prod.IsActive := ADTO.IsActive;
  Prod.UpdatedAt := Now;

  TProductValidator.Validate(Prod);

  FProductRepo.Save(Prod);
  if Assigned(FAuditService) then
    FAuditService.LogAction(0, 'System', 'PRODUCT_UPDATED', 'Product', Prod.ID, 'Updated product ' + Prod.SKU, '127.0.0.1');

  Result := TOperationResult.Ok('Product updated successfully.', Prod.ID);
end;

function TProductService.DeleteProduct(AID: TEntityID): TOperationResult;
var
  Prod: TProduct;
begin
  Prod := FProductRepo.GetByID(AID);
  if Prod = nil then
    raise EEntityNotFoundException.Create('Product', IntToStr(AID));

  // Soft delete / deactivate
  Prod.IsActive := False;
  FProductRepo.Save(Prod);

  if Assigned(FAuditService) then
    FAuditService.LogAction(0, 'System', 'PRODUCT_DEACTIVATED', 'Product', AID, 'Deactivated product ' + Prod.SKU, '127.0.0.1');

  Result := TOperationResult.Ok('Product deactivated.', AID);
end;

end.
