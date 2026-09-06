unit Warenfluss.ViewModel.Inventory;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
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
    FWarehouses: TArray<TWarehouseDTO>;
    FMovements: TArray<TStockMovementDTO>;
    FSelectedWarehouseID: TEntityID;
  public
    constructor Create(AInventoryService: IInventoryService; ATransferService: IStockTransferService; AWarehouseService: IWarehouseService);
    procedure LoadStock;
    procedure LoadMovements(AProductID: TEntityID = 0);
    function AdjustStock(AProductID, AWarehouseID: TEntityID; ADelta: Double; const AReason: string; AUserID: TEntityID): TOperationResult;
    function TransferStock(AProductID, ASrcWH, ATgtWH: TEntityID; AQty: Double; const AReason: string; AUserID: TEntityID): TOperationResult;

    property StockItems: TArray<TStockItemDTO> read FStockItems;
    property Warehouses: TArray<TWarehouseDTO> read FWarehouses;
    property Movements: TArray<TStockMovementDTO> read FMovements;
    property SelectedWarehouseID: TEntityID read FSelectedWarehouseID write FSelectedWarehouseID;
  end;

implementation

constructor TInventoryViewModel.Create(AInventoryService: IInventoryService; ATransferService: IStockTransferService;
  AWarehouseService: IWarehouseService);
begin
  inherited Create;
  FInventoryService := AInventoryService;
  FStockTransferService := ATransferService;
  FWarehouseService := AWarehouseService;
  FSelectedWarehouseID := 0;
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
    end;
    NotifyChanged;
  finally
    IsBusy := False;
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

function TInventoryViewModel.AdjustStock(AProductID, AWarehouseID: TEntityID; ADelta: Double; const AReason: string;
  AUserID: TEntityID): TOperationResult;
var
  DTO: TStockAdjustmentDTO;
begin
  DTO.ProductID := AProductID;
  DTO.WarehouseID := AWarehouseID;
  DTO.AdjustmentQuantity := ADelta;
  DTO.Reason := AReason;

  Result := FInventoryService.AdjustStock(DTO, AUserID);
  if Result.Success then
    LoadStock;
end;

function TInventoryViewModel.TransferStock(AProductID, ASrcWH, ATgtWH: TEntityID; AQty: Double; const AReason: string;
  AUserID: TEntityID): TOperationResult;
var
  DTO: TStockTransferDTO;
begin
  DTO.ProductID := AProductID;
  DTO.SourceWarehouseID := ASrcWH;
  DTO.TargetWarehouseID := ATgtWH;
  DTO.Quantity := AQty;
  DTO.Reason := AReason;

  Result := FStockTransferService.TransferStock(DTO, AUserID);
  if Result.Success then
    LoadStock;
end;

end.
