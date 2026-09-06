unit Warenfluss.Interfaces.Services;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.DTOs.Auth,
  Warenfluss.DTOs.Product,
  Warenfluss.DTOs.Inventory,
  Warenfluss.DTOs.Order,
  Warenfluss.DTOs.Report;

type
  { Authentication Service }
  IAuthenticationService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A01}']
    function Login(const ARequest: TLoginRequestDTO): TLoginResponseDTO;
    procedure Logout(const AToken: string);
    function ValidateToken(const AToken: string): Boolean;
    function GetCurrentUser(const AToken: string): TUserDTO;
  end;

  { User Service }
  IUserService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A02}']
    function GetAllUsers: TArray<TUserDTO>;
    function GetUserByID(AID: TEntityID): TUserDTO;
    function CreateUser(const ADTO: TUserCreateDTO): TOperationResult;
    function UpdateUser(const ADTO: TUserUpdateDTO): TOperationResult;
    function DeactivateUser(AID: TEntityID): TOperationResult;
  end;

  { Product Service }
  IProductService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A03}']
    function GetAllProducts(AOnlyActive: Boolean = True): TArray<TProductDTO>;
    function GetProductByID(AID: TEntityID): TProductDTO;
    function GetProductBySKU(const ASKU: string): TProductDTO;
    function SearchProducts(const AQuery: string): TArray<TProductDTO>;
    function GetLowStockProducts: TArray<TProductDTO>;
    function CreateProduct(const ADTO: TProductCreateDTO): TOperationResult;
    function UpdateProduct(const ADTO: TProductUpdateDTO): TOperationResult;
    function DeleteProduct(AID: TEntityID): TOperationResult;
  end;

  { Category, Supplier, Customer, Warehouse Services }
  ICategoryService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A04}']
    function GetAllCategories: TArray<TCategoryDTO>;
    function GetCategoryByID(AID: TEntityID): TCategoryDTO;
    function SaveCategory(const ADTO: TCategoryDTO): TOperationResult;
    function DeleteCategory(AID: TEntityID): TOperationResult;
  end;

  ISupplierService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A05}']
    function GetAllSuppliers: TArray<TSupplierDTO>;
    function GetSupplierByID(AID: TEntityID): TSupplierDTO;
    function SaveSupplier(const ADTO: TSupplierDTO): TOperationResult;
    function DeleteSupplier(AID: TEntityID): TOperationResult;
  end;

  ICustomerService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A06}']
    function GetAllCustomers: TArray<TCustomerDTO>;
    function GetCustomerByID(AID: TEntityID): TCustomerDTO;
    function SaveCustomer(const ADTO: TCustomerDTO): TOperationResult;
    function DeleteCustomer(AID: TEntityID): TOperationResult;
  end;

  IWarehouseService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A07}']
    function GetAllWarehouses: TArray<TWarehouseDTO>;
    function GetWarehouseByID(AID: TEntityID): TWarehouseDTO;
    function SaveWarehouse(const ADTO: TWarehouseDTO): TOperationResult;
    function DeleteWarehouse(AID: TEntityID): TOperationResult;
  end;

  { Inventory & Stock Services }
  IInventoryService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A08}']
    function GetStockByWarehouse(AWarehouseID: TEntityID): TArray<TStockItemDTO>;
    function GetStockByProduct(AProductID: TEntityID): TArray<TStockItemDTO>;
    function GetAllStockItems: TArray<TStockItemDTO>;
    function GetAvailableStock(AProductID, AWarehouseID: TEntityID): Double;
    function AdjustStock(const ADTO: TStockAdjustmentDTO; AUserID: TEntityID): TOperationResult;
    function GetMovementHistory(AProductID: TEntityID = 0; ALimit: Integer = 200): TArray<TStockMovementDTO>;
  end;

  { Stock Transfer Service }
  IStockTransferService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A09}']
    function TransferStock(const ADTO: TStockTransferDTO; AUserID: TEntityID): TOperationResult;
  end;

  { Purchase Order Service }
  IPurchaseOrderService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A10}']
    function GetAllOrders: TArray<TPurchaseOrderDTO>;
    function GetOrderByID(AID: TEntityID): TPurchaseOrderDTO;
    function CreateOrder(const ADTO: TPurchaseOrderCreateDTO; AUserID: TEntityID): TOperationResult;
    function ApproveOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
    function ReceiveGoods(AID: TEntityID; AUserID: TEntityID): TOperationResult;
    function CancelOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
  end;

  { Sales Order Service }
  ISalesOrderService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A11}']
    function GetAllOrders: TArray<TSalesOrderDTO>;
    function GetOrderByID(AID: TEntityID): TSalesOrderDTO;
    function CreateOrder(const ADTO: TSalesOrderCreateDTO; AUserID: TEntityID): TOperationResult;
    function ConfirmOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
    function CompleteOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
    function CancelOrder(AID: TEntityID; AUserID: TEntityID): TOperationResult;
  end;

  { Report Service }
  IReportService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A12}']
    function GetDashboardSummary: TDashboardSummaryDTO;
    function GetInventoryValuation(AWarehouseID: TEntityID = 0): TInventoryValuationSummaryDTO;
  end;

  { Audit Service }
  IAuditService = interface
    ['{7C25E34A-4A0E-47BC-BE21-F99248471A13}']
    procedure LogAction(AUserID: TEntityID; const AUsername, AAction, AEntityName: string; AEntityID: TEntityID; const ADetails, AClientIP: string);
    function GetRecentLogs(ALimit: Integer = 200): TArray<TAuditLogDTO>;
    function GetLogsForEntity(const AEntityName: string; AEntityID: TEntityID): TArray<TAuditLogDTO>;
  end;

implementation

end.
