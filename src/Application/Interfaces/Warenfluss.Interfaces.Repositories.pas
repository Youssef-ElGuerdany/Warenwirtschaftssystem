unit Warenfluss.Interfaces.Repositories;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Warenfluss.Types,
  Warenfluss.Domain.User,
  Warenfluss.Domain.Category,
  Warenfluss.Domain.Supplier,
  Warenfluss.Domain.Customer,
  Warenfluss.Domain.Warehouse,
  Warenfluss.Domain.Product,
  Warenfluss.Domain.StockMovement,
  Warenfluss.Domain.PurchaseOrder,
  Warenfluss.Domain.SalesOrder,
  Warenfluss.Domain.AuditLog;

type
  { Unit of Work / Transaction Manager }
  IUnitOfWork = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B01}']
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;
  end;

  { User Repository }
  IUserRepository = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B02}']
    function GetByID(AID: TEntityID): TUser;
    function GetByUsername(const AUsername: string): TUser;
    function GetAll: TObjectList<TUser>;
    function Save(AUser: TUser): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  { Master Data Repositories }
  ICategoryRepository = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B03}']
    function GetByID(AID: TEntityID): TCategory;
    function GetAll: TObjectList<TCategory>;
    function Save(ACategory: TCategory): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  ISupplierRepository = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B04}']
    function GetByID(AID: TEntityID): TSupplier;
    function GetAll: TObjectList<TSupplier>;
    function Save(ASupplier: TSupplier): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  ICustomerRepository = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B05}']
    function GetByID(AID: TEntityID): TCustomer;
    function GetAll: TObjectList<TCustomer>;
    function Save(ACustomer: TCustomer): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  IWarehouseRepository = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B06}']
    function GetByID(AID: TEntityID): TWarehouse;
    function GetAll: TObjectList<TWarehouse>;
    function Save(AWarehouse: TWarehouse): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  { Product Repository }
  IProductRepository = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B07}']
    function GetByID(AID: TEntityID): TProduct;
    function GetBySKU(const ASKU: string): TProduct;
    function GetAll(AOnlyActive: Boolean = True): TObjectList<TProduct>;
    function GetLowStockProducts: TObjectList<TProduct>;
    function Search(const AQuery: string): TObjectList<TProduct>;
    function Save(AProduct: TProduct): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  { Stock & Movement Repository }
  IStockRepository = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B08}']
    function GetStockItem(AProductID, AWarehouseID: TEntityID): TStockItem;
    function GetStockByProduct(AProductID: TEntityID): TObjectList<TStockItem>;
    function GetStockByWarehouse(AWarehouseID: TEntityID): TObjectList<TStockItem>;
    function GetAllStockItems: TObjectList<TStockItem>;
    procedure SaveStockItem(AStockItem: TStockItem);
    procedure AddStockMovement(AMovement: TStockMovement);
    function GetMovementsByProduct(AProductID: TEntityID; ALimit: Integer = 100): TObjectList<TStockMovement>;
    function GetAllMovements(ALimit: Integer = 500): TObjectList<TStockMovement>;
  end;

  { Purchase Order Repository }
  IPurchaseOrderRepository = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B09}']
    function GetByID(AID: TEntityID): TPurchaseOrder;
    function GetByOrderNumber(const ANumber: string): TPurchaseOrder;
    function GetAll: TObjectList<TPurchaseOrder>;
    function GetByStatus(AStatus: TPurchaseOrderStatus): TObjectList<TPurchaseOrder>;
    function Save(AOrder: TPurchaseOrder): TEntityID;
    function Delete(AID: TEntityID): Boolean;
    function GenerateNextOrderNumber: string;
  end;

  { Sales Order Repository }
  ISalesOrderRepository = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B10}']
    function GetByID(AID: TEntityID): TSalesOrder;
    function GetByOrderNumber(const ANumber: string): TSalesOrder;
    function GetAll: TObjectList<TSalesOrder>;
    function GetByStatus(AStatus: TSalesOrderStatus): TObjectList<TSalesOrder>;
    function Save(AOrder: TSalesOrder): TEntityID;
    function Delete(AID: TEntityID): Boolean;
    function GenerateNextOrderNumber: string;
  end;

  { Audit Repository }
  IAuditRepository = interface
    ['{8E12F6C1-285B-4C79-99E7-94BC10023B11}']
    procedure AddLog(ALog: TAuditLog);
    function GetAll(ALimit: Integer = 500): TObjectList<TAuditLog>;
    function GetByEntity(const AEntityName: string; AEntityID: TEntityID): TObjectList<TAuditLog>;
  end;

implementation

end.
