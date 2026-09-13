unit Warenfluss.ViewModel.SalesOrder;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

/// <summary>
///   ViewModel for the Sales Orders (Verkaufsaufträge) view.
///
///   Responsibility:
///     This class acts as the presentation-logic bridge between the
///     <c>ISalesOrderService</c> / <c>ICustomerService</c> / <c>IWarehouseService</c>
///     application services and the <c>TfrmSalesOrders</c> view.
///
///   It holds the following in-memory collections, freshly loaded on demand:
///     - <c>Orders</c>    – all sales orders (TSalesOrderDTO)
///     - <c>Customers</c> – all customers for the "Kunde" dropdown
///     - <c>Warehouses</c>– all warehouses for the "Lager" dropdown
///     - <c>Products</c>  – all active products for the order-line article picker
///
///   Lifecycle commands (Confirm / Complete / Cancel) delegate directly to the
///   service, then reload the order list so the view always displays current data.
///
///   Threading note:
///     All service calls are synchronous.  IsBusy is toggled around the load
///     so the view can optionally render a busy indicator.
/// </summary>
interface

uses
  System.SysUtils,
  Warenfluss.Types,
  Warenfluss.DTOs.Order,
  Warenfluss.DTOs.Product,
  Warenfluss.Interfaces.Services,
  Warenfluss.ViewModel.Base;

type
  /// <summary>
  ///   Concrete ViewModel for the Sales-Orders screen.
  ///   Inherits the <c>OnChanged</c> callback, <c>IsBusy</c> flag and
  ///   <c>StatusMessage</c> property from <c>TBaseViewModel</c>.
  /// </summary>
  TSalesOrderViewModel = class(TBaseViewModel)
  private
    { ── Service dependencies (injected via constructor) ── }
    FSalesService:     ISalesOrderService;
    FCustomerService:  ICustomerService;
    FWarehouseService: IWarehouseService;
    FProductService:   IProductService;    // needed for article picker in order lines

    { ── Cached collections (refreshed by LoadOrders) ── }
    FOrders:     TArray<TSalesOrderDTO>;
    FCustomers:  TArray<TCustomerDTO>;
    FWarehouses: TArray<TWarehouseDTO>;
    FProducts:   TArray<TProductDTO>;     // active products for article selection

    { ── Currently selected / highlighted order ── }
    FSelectedOrder: TSalesOrderDTO;

  public
    // ─────────────────────────────────────────────────────────────────────
    // Construction
    // ─────────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Creates the ViewModel and injects all required service dependencies.
    /// </summary>
    /// <param name="ASalesService">
    ///   Service for CRUD and lifecycle operations on sales orders.
    /// </param>
    /// <param name="ACustomerService">
    ///   Service for loading the customer master list.
    /// </param>
    /// <param name="AWarehouseService">
    ///   Service for loading the warehouse list.
    /// </param>
    /// <param name="AProductService">
    ///   Service for loading active products used in order-line selection.
    ///   Pass <c>nil</c> if product selection is not required; the Products
    ///   array will simply remain empty.
    /// </param>
    constructor Create(ASalesService:    ISalesOrderService;
                       ACustomerService:  ICustomerService;
                       AWarehouseService: IWarehouseService;
                       AProductService:   IProductService = nil); reintroduce;

    // ─────────────────────────────────────────────────────────────────────
    // Data Loading
    // ─────────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Refreshes all four in-memory collections from the service layer,
    ///   then fires <c>OnChanged</c> so the view can repopulate its controls.
    /// </summary>
    /// <remarks>
    ///   Sets <c>IsBusy := True</c> for the duration of the call and always
    ///   resets it – even if a service raises an exception.
    ///   After a successful create/confirm/complete/cancel operation the
    ///   relevant command method calls LoadOrders automatically.
    /// </remarks>
    procedure LoadOrders;

    // ─────────────────────────────────────────────────────────────────────
    // Query Helpers
    // ─────────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Fetches a single order (including its lines) from the service by ID.
    /// </summary>
    /// <param name="AID">
    ///   The entity ID of the order to retrieve.
    /// </param>
    /// <returns>
    ///   A fully populated <c>TSalesOrderDTO</c>.
    ///   If the service is not assigned, an empty (zero-ID) record is returned.
    /// </returns>
    function GetOrderByID(AID: TEntityID): TSalesOrderDTO;

    // ─────────────────────────────────────────────────────────────────────
    // Lifecycle Commands
    // ─────────────────────────────────────────────────────────────────────

    /// <summary>
    ///   Creates a new sales order from the supplied DTO.
    /// </summary>
    /// <param name="ADTO">
    ///   Data-transfer object populated by the view's editor panel.
    ///   Must contain at least one order line.
    /// </param>
    /// <param name="AUserID">
    ///   ID of the currently authenticated user (written to CreatedByUserID).
    /// </param>
    /// <returns>
    ///   <c>TOperationResult.Success = True</c> on success; on failure the
    ///   <c>Message</c> field contains a human-readable German error text.
    /// </returns>
    function CreateOrder(const ADTO: TSalesOrderCreateDTO;
                               AUserID: TEntityID): TOperationResult;

    /// <summary>
    ///   Advances a Draft order to the Confirmed state.
    ///   Stock reservation is performed by the service.
    /// </summary>
    /// <param name="AID">Order entity ID.</param>
    /// <param name="AUserID">Authenticated user ID (audit trail).</param>
    function ConfirmOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;

    /// <summary>
    ///   Marks a Confirmed order as Completed (goods dispatched).
    ///   Triggers the stock-dispatch movement in the service layer.
    /// </summary>
    /// <param name="AID">Order entity ID.</param>
    /// <param name="AUserID">Authenticated user ID (audit trail).</param>
    function CompleteOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;

    /// <summary>
    ///   Cancels a Draft or Confirmed order.
    ///   If the order was Confirmed, any stock reservations are released.
    /// </summary>
    /// <param name="AID">Order entity ID.</param>
    /// <param name="AUserID">Authenticated user ID (audit trail).</param>
    function CancelOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;

    // ─────────────────────────────────────────────────────────────────────
    // Properties (read-only data exposed to the View)
    // ─────────────────────────────────────────────────────────────────────

    /// <summary>All loaded sales orders (refreshed by <c>LoadOrders</c>).</summary>
    property Orders: TArray<TSalesOrderDTO> read FOrders;

    /// <summary>Master list of customers for the Kunde combo-box.</summary>
    property Customers: TArray<TCustomerDTO> read FCustomers;

    /// <summary>Master list of warehouses for the Lager combo-box.</summary>
    property Warehouses: TArray<TWarehouseDTO> read FWarehouses;

    /// <summary>
    ///   Active products for the order-line article picker.
    ///   Empty when no <c>IProductService</c> was supplied at construction time.
    /// </summary>
    property Products: TArray<TProductDTO> read FProducts;

    /// <summary>
    ///   The order most recently selected (or highlighted) in the list view.
    ///   Set by the view whenever the user clicks a row.
    /// </summary>
    property SelectedOrder: TSalesOrderDTO
      read  FSelectedOrder
      write FSelectedOrder;
  end;

implementation

{ ============================================================
  Constructor
  Purpose: Store the injected service references and perform no
           I/O — data loading is deferred to LoadOrders so the
           view can decide when to trigger the first fetch.
  ============================================================ }

constructor TSalesOrderViewModel.Create(ASalesService:    ISalesOrderService;
                                        ACustomerService:  ICustomerService;
                                        AWarehouseService: IWarehouseService;
                                        AProductService:   IProductService);
begin
  inherited Create;
  FSalesService     := ASalesService;
  FCustomerService  := ACustomerService;
  FWarehouseService := AWarehouseService;
  FProductService   := AProductService;
end;

{ ============================================================
  LoadOrders
  Purpose: Refresh all four master-data caches in one call and
           notify the view via the OnChanged callback.
  Design note: Each service is guarded with Assigned() so that
           a nil dependency does not cause an AV – it simply
           leaves the matching array empty.
  ============================================================ }

procedure TSalesOrderViewModel.LoadOrders;
begin
  IsBusy := True;
  try
    { Load the orders list from the sales service }
    if Assigned(FSalesService) then
      FOrders := FSalesService.GetAllOrders
    else
      FOrders := [];

    { Load the customer master for the dropdown }
    if Assigned(FCustomerService) then
      FCustomers := FCustomerService.GetAllCustomers
    else
      FCustomers := [];

    { Load the warehouse master for the dropdown }
    if Assigned(FWarehouseService) then
      FWarehouses := FWarehouseService.GetAllWarehouses
    else
      FWarehouses := [];

    { Load active products for the order-line article picker.
      Only active products are loaded to prevent creating lines
      for discontinued articles. }
    if Assigned(FProductService) then
      FProducts := FProductService.GetAllProducts(True {OnlyActive})
    else
      FProducts := [];

    { Signal the view that the data has changed }
    NotifyChanged;
  finally
    IsBusy := False;
  end;
end;

{ ============================================================
  GetOrderByID
  Purpose: Retrieve a single order with its full line detail.
           Used by the detail panel to display line items after
           the user selects a row in the list view.
  ============================================================ }

function TSalesOrderViewModel.GetOrderByID(AID: TEntityID): TSalesOrderDTO;
begin
  { Return an empty record when the service is not available
    to avoid nil-pointer exceptions in the caller }
  if not Assigned(FSalesService) then
  begin
    FillChar(Result, SizeOf(Result), 0);
    Exit;
  end;

  Result := FSalesService.GetOrderByID(AID);
end;

{ ============================================================
  CreateOrder
  Purpose: Delegate a new-order creation to the service and,
           on success, refresh the order list so the newly
           created order is immediately visible in the view.
  ============================================================ }

function TSalesOrderViewModel.CreateOrder(const ADTO: TSalesOrderCreateDTO;
                                          AUserID: TEntityID): TOperationResult;
begin
  Result := FSalesService.CreateOrder(ADTO, AUserID);

  { Reload only on success to avoid overwriting the list with
    potentially inconsistent data after a failed write }
  if Result.Success then
    LoadOrders;
end;

{ ============================================================
  ConfirmOrder
  Purpose: Advance a Draft order to Confirmed state.
           The service handles stock reservation internally.
  ============================================================ }

function TSalesOrderViewModel.ConfirmOrder(AID: TEntityID;
                                           AUserID: TEntityID): TOperationResult;
begin
  Result := FSalesService.ConfirmOrder(AID, AUserID);
  if Result.Success then
    LoadOrders;
end;

{ ============================================================
  CompleteOrder
  Purpose: Mark a Confirmed order as Completed (goods shipped).
           The service triggers the stock-dispatch movement.
  ============================================================ }

function TSalesOrderViewModel.CompleteOrder(AID: TEntityID;
                                            AUserID: TEntityID): TOperationResult;
begin
  Result := FSalesService.CompleteOrder(AID, AUserID);
  if Result.Success then
    LoadOrders;
end;

{ ============================================================
  CancelOrder
  Purpose: Cancel a Draft or Confirmed order.
           The service releases any reserved stock on Confirmed
           orders automatically.
  ============================================================ }

function TSalesOrderViewModel.CancelOrder(AID: TEntityID;
                                          AUserID: TEntityID): TOperationResult;
begin
  Result := FSalesService.CancelOrder(AID, AUserID);
  if Result.Success then
    LoadOrders;
end;

end.
