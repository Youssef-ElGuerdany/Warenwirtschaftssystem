unit Warenfluss.ViewModel.Inventory;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.StrUtils,
  Warenfluss.Types,
  Warenfluss.DTOs.Inventory,
  Warenfluss.DTOs.Product,
  Warenfluss.Interfaces.Services,
  Warenfluss.ViewModel.Base;

type
  TInventoryViewModel = class(TBaseViewModel)
  private
    FInventoryService: IInventoryService;
    FStockTransferService: IStockTransferService;
    FWarehouseService: IWarehouseService;
    FStockItems: TArray<TStockItemDTO>;
    FFilteredStockItems: TArray<TStockItemDTO>;
    FWarehouses: TArray<TWarehouseDTO>;
    FMovements: TArray<TStockMovementDTO>;
    FSelectedWarehouseID: TEntityID;
    FSearchQuery: string;
    FSelectedStockItem: TStockItemDTO;
    FHasSelectedStockItem: Boolean;
    FCurrentUserID: TEntityID;

    procedure ApplyFilter;
  public
    constructor Create(AInventoryService: IInventoryService; ATransferService: IStockTransferService;
      AWarehouseService: IWarehouseService); reintroduce;

    procedure LoadStock;
    procedure LoadMovements(AProductID: TEntityID = 0);
    procedure Search(const AQuery: string);
    procedure FilterByWarehouse(AWHID: TEntityID);

    function AdjustStock(AProductID, AWarehouseID: TEntityID; ADelta: Double;
      const AReason: string; AUserID: TEntityID): TOperationResult;
    function TransferStock(AProductID, ASrcWH, ATgtWH: TEntityID; AQty: Double;
      const AReason: string; AUserID: TEntityID): TOperationResult;

    function GetTotalQuantity: Double;
    function GetTotalValuation: Currency;
    function GetTotalPositionCount: Integer;

    property StockItems: TArray<TStockItemDTO> read FFilteredStockItems;
    property AllStockItems: TArray<TStockItemDTO> read FStockItems;
    property Warehouses: TArray<TWarehouseDTO> read FWarehouses;
    property Movements: TArray<TStockMovementDTO> read FMovements;
    property SelectedWarehouseID: TEntityID read FSelectedWarehouseID write FSelectedWarehouseID;
    property SearchQuery: string read FSearchQuery;
    property SelectedStockItem: TStockItemDTO read FSelectedStockItem write FSelectedStockItem;
    property HasSelectedStockItem: Boolean read FHasSelectedStockItem write FHasSelectedStockItem;
    property CurrentUserID: TEntityID read FCurrentUserID write FCurrentUserID;
  end;

implementation

constructor TInventoryViewModel.Create(AInventoryService: IInventoryService;
  ATransferService: IStockTransferService; AWarehouseService: IWarehouseService);
begin
  inherited Create;
  FInventoryService := AInventoryService;
  FStockTransferService := ATransferService;
  FWarehouseService := AWarehouseService;
  FSelectedWarehouseID := 0;
  FSearchQuery := '';
  FHasSelectedStockItem := False;
  FCurrentUserID := 1;
end;

procedure TInventoryViewModel.LoadStock;
begin
  IsBusy := True;
  try
    if Assigned(FWarehouseService) then
      FWarehouses := FWarehouseService.GetAllWarehouses;

    if Assigned(FInventoryService) then
    begin
      if FSelectedWarehouseID > 0 then
        FStockItems := FInventoryService.GetStockByWarehouse(FSelectedWarehouseID)
      else
        FStockItems := FInventoryService.GetAllStockItems;
    end
    else
      SetLength(FStockItems, 0);

    ApplyFilter;
  finally
    IsBusy := False;
  end;
end;

procedure TInventoryViewModel.ApplyFilter;
var
  I: Integer;
  Matches: TArray<TStockItemDTO>;
  Count: Integer;
  UpperQuery: string;
  Item: TStockItemDTO;
  MatchesQuery: Boolean;
begin
  UpperQuery := UpperCase(Trim(FSearchQuery));

  if UpperQuery = '' then
  begin
    FFilteredStockItems := Copy(FStockItems);
  end
  else
  begin
    SetLength(Matches, Length(FStockItems));
    Count := 0;
    for I := 0 to High(FStockItems) do
    begin
      Item := FStockItems[I];
      MatchesQuery := (Pos(UpperQuery, UpperCase(Item.ProductSKU)) > 0) or
                      (Pos(UpperQuery, UpperCase(Item.ProductName)) > 0) or
                      (Pos(UpperQuery, UpperCase(Item.WarehouseName)) > 0) or
                      (Pos(UpperQuery, UpperCase(Item.WarehouseCode)) > 0);
      if MatchesQuery then
      begin
        Matches[Count] := Item;
        Inc(Count);
      end;
    end;
    SetLength(Matches, Count);
    FFilteredStockItems := Matches;
  end;

  NotifyChanged;
end;

procedure TInventoryViewModel.Search(const AQuery: string);
begin
  FSearchQuery := AQuery;
  ApplyFilter;
end;

procedure TInventoryViewModel.FilterByWarehouse(AWHID: TEntityID);
begin
  if FSelectedWarehouseID <> AWHID then
  begin
    FSelectedWarehouseID := AWHID;
    LoadStock;
  end;
end;

procedure TInventoryViewModel.LoadMovements(AProductID: TEntityID);
begin
  if Assigned(FInventoryService) then
  begin
    FMovements := FInventoryService.GetMovementHistory(AProductID, 200);
    NotifyChanged;
  end;
end;

function TInventoryViewModel.AdjustStock(AProductID, AWarehouseID: TEntityID;
  ADelta: Double; const AReason: string; AUserID: TEntityID): TOperationResult;
var
  DTO: TStockAdjustmentDTO;
begin
  DTO.ProductID := AProductID;
  DTO.WarehouseID := AWarehouseID;
  DTO.AdjustmentQuantity := ADelta;
  DTO.Reason := AReason;

  if Assigned(FInventoryService) then
  begin
    Result := FInventoryService.AdjustStock(DTO, AUserID);
    if Result.Success then
    begin
      LoadStock;
      LoadMovements(AProductID);
    end;
  end
  else
  begin
    Result.Success := False;
    Result.Message := 'Inventory service not available.';
  end;
end;

function TInventoryViewModel.TransferStock(AProductID, ASrcWH, ATgtWH: TEntityID;
  AQty: Double; const AReason: string; AUserID: TEntityID): TOperationResult;
var
  DTO: TStockTransferDTO;
begin
  DTO.ProductID := AProductID;
  DTO.SourceWarehouseID := ASrcWH;
  DTO.TargetWarehouseID := ATgtWH;
  DTO.Quantity := AQty;
  DTO.Reason := AReason;

  if Assigned(FStockTransferService) then
  begin
    Result := FStockTransferService.TransferStock(DTO, AUserID);
    if Result.Success then
    begin
      LoadStock;
      LoadMovements(AProductID);
    end;
  end
  else
  begin
    Result.Success := False;
    Result.Message := 'Stock transfer service not available.';
  end;
end;

function TInventoryViewModel.GetTotalQuantity: Double;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(FFilteredStockItems) do
    Result := Result + FFilteredStockItems[I].Quantity;
end;

function TInventoryViewModel.GetTotalValuation: Currency;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(FFilteredStockItems) do
    Result := Result + FFilteredStockItems[I].TotalValue;
end;

function TInventoryViewModel.GetTotalPositionCount: Integer;
begin
  Result := Length(FFilteredStockItems);
end;

end.
