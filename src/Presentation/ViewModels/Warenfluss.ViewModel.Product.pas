unit Warenfluss.ViewModel.Product;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  Warenfluss.Types,
  Warenfluss.DTOs.Product,
  Warenfluss.Interfaces.Services,
  Warenfluss.ViewModel.Base;

type
  TProductViewModel = class(TBaseViewModel)
  private
    FProductService: IProductService;
    FCategoryService: ICategoryService;
    FProducts: TArray<TProductDTO>;
    FCategories: TArray<TCategoryDTO>;
    FSelectedProduct: TProductDTO;
    FSearchQuery: string;
    FOnlyActive: Boolean;
  public
    constructor Create(AProductService: IProductService; ACategoryService: ICategoryService);
    procedure LoadProducts;
    procedure Search(const AQuery: string);
    function SaveProduct(const ADTO: TProductCreateDTO): TOperationResult;
    function UpdateProduct(const ADTO: TProductUpdateDTO): TOperationResult;
    function DeactivateProduct(AID: TEntityID): TOperationResult;

    property Products: TArray<TProductDTO> read FProducts;
    property Categories: TArray<TCategoryDTO> read FCategories;
    property SelectedProduct: TProductDTO read FSelectedProduct write FSelectedProduct;
    property OnlyActive: Boolean read FOnlyActive write FOnlyActive;
  end;

implementation

constructor TProductViewModel.Create(AProductService: IProductService; ACategoryService: ICategoryService);
begin
  inherited Create;
  FProductService := AProductService;
  FCategoryService := ACategoryService;
  FOnlyActive := True;
end;

procedure TProductViewModel.LoadProducts;
begin
  IsBusy := True;
  try
    if Assigned(FProductService) then
      FProducts := FProductService.GetAllProducts(FOnlyActive);
    if Assigned(FCategoryService) then
      FCategories := FCategoryService.GetAllCategories;
    NotifyChanged;
  finally
    IsBusy := False;
  end;
end;

procedure TProductViewModel.Search(const AQuery: string);
begin
  FSearchQuery := AQuery;
  IsBusy := True;
  try
    if Trim(AQuery) = '' then
      FProducts := FProductService.GetAllProducts(FOnlyActive)
    else
      FProducts := FProductService.SearchProducts(AQuery);
    NotifyChanged;
  finally
    IsBusy := False;
  end;
end;

function TProductViewModel.SaveProduct(const ADTO: TProductCreateDTO): TOperationResult;
begin
  Result := FProductService.CreateProduct(ADTO);
  if Result.Success then
    LoadProducts;
end;

function TProductViewModel.UpdateProduct(const ADTO: TProductUpdateDTO): TOperationResult;
begin
  Result := FProductService.UpdateProduct(ADTO);
  if Result.Success then
    LoadProducts;
end;

function TProductViewModel.DeactivateProduct(AID: TEntityID): TOperationResult;
begin
  Result := FProductService.DeleteProduct(AID);
  if Result.Success then
    LoadProducts;
end;

end.
