unit Warenfluss.ViewModel.SalesOrder;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  Warenfluss.Types,
  Warenfluss.DTOs.Order,
  Warenfluss.DTOs.Product,
  Warenfluss.Interfaces.Services,
  Warenfluss.ViewModel.Base;

type
  TSalesOrderViewModel = class(TBaseViewModel)
  private
    FSalesService: ISalesOrderService;
    FCustomerService: ICustomerService;
    FWarehouseService: IWarehouseService;
    FOrders: TArray<TSalesOrderDTO>;
    FCustomers: TArray<TCustomerDTO>;
    FWarehouses: TArray<TWarehouseDTO>;
    FSelectedOrder: TSalesOrderDTO;
  public
    constructor Create(ASalesService: ISalesOrderService; ACustomerService: ICustomerService; AWarehouseService: IWarehouseService);
    procedure LoadOrders;
    function CreateOrder(const ADTO: TSalesOrderCreateDTO; AUserID: TEntityID): TOperationResult;
    function ConfirmOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
    function CompleteOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
    function CancelOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;

    property Orders: TArray<TSalesOrderDTO> read FOrders;
    property Customers: TArray<TCustomerDTO> read FCustomers;
    property Warehouses: TArray<TWarehouseDTO> read FWarehouses;
    property SelectedOrder: TSalesOrderDTO read FSelectedOrder write FSelectedOrder;
  end;

implementation

constructor TSalesOrderViewModel.Create(ASalesService: ISalesOrderService; ACustomerService: ICustomerService;
  AWarehouseService: IWarehouseService);
begin
  inherited Create;
  FSalesService := ASalesService;
  FCustomerService := ACustomerService;
  FWarehouseService := AWarehouseService;
end;

procedure TSalesOrderViewModel.LoadOrders;
begin
  IsBusy := True;
  try
    if Assigned(FSalesService) then
      FOrders := FSalesService.GetAllOrders;
    if Assigned(FCustomerService) then
      FCustomers := FCustomerService.GetAllCustomers;
    if Assigned(FWarehouseService) then
      FWarehouses := FWarehouseService.GetAllWarehouses;
    NotifyChanged;
  finally
    IsBusy := False;
  end;
end;

function TSalesOrderViewModel.CreateOrder(const ADTO: TSalesOrderCreateDTO; AUserID: TEntityID): TOperationResult;
begin
  Result := FSalesService.CreateOrder(ADTO, AUserID);
  if Result.Success then
    LoadOrders;
end;

function TSalesOrderViewModel.ConfirmOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
begin
  Result := FSalesService.ConfirmOrder(AID, AUserID);
  if Result.Success then
    LoadOrders;
end;

function TSalesOrderViewModel.CompleteOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
begin
  Result := FSalesService.CompleteOrder(AID, AUserID);
  if Result.Success then
    LoadOrders;
end;

function TSalesOrderViewModel.CancelOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
begin
  Result := FSalesService.CancelOrder(AID, AUserID);
  if Result.Success then
    LoadOrders;
end;

end.
