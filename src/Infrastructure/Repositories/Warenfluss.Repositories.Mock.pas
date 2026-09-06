unit Warenfluss.Repositories.Mock;

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
  Warenfluss.Domain.AuditLog,
  Warenfluss.Interfaces.Repositories;

type
  { Mock In-Memory Unit of Work }
  TMockUnitOfWork = class(TInterfacedObject, IUnitOfWork)
  private
    FInTx: Boolean;
  public
    constructor Create;
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;
  end;

  { Mock User Repository }
  TMockUserRepository = class(TInterfacedObject, IUserRepository)
  private
    FItems: TObjectList<TUser>;
    FNextID: TEntityID;
  public
    constructor Create;
    destructor Destroy; override;
    function GetByID(AID: TEntityID): TUser;
    function GetByUsername(const AUsername: string): TUser;
    function GetAll: TObjectList<TUser>;
    function Save(AUser: TUser): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  { Mock Master Repositories }
  TMockCategoryRepository = class(TInterfacedObject, ICategoryRepository)
  private
    FItems: TObjectList<TCategory>;
    FNextID: TEntityID;
  public
    constructor Create;
    destructor Destroy; override;
    function GetByID(AID: TEntityID): TCategory;
    function GetAll: TObjectList<TCategory>;
    function Save(ACategory: TCategory): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  TMockSupplierRepository = class(TInterfacedObject, ISupplierRepository)
  private
    FItems: TObjectList<TSupplier>;
    FNextID: TEntityID;
  public
    constructor Create;
    destructor Destroy; override;
    function GetByID(AID: TEntityID): TSupplier;
    function GetAll: TObjectList<TSupplier>;
    function Save(ASupplier: TSupplier): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  TMockCustomerRepository = class(TInterfacedObject, ICustomerRepository)
  private
    FItems: TObjectList<TCustomer>;
    FNextID: TEntityID;
  public
    constructor Create;
    destructor Destroy; override;
    function GetByID(AID: TEntityID): TCustomer;
    function GetAll: TObjectList<TCustomer>;
    function Save(ACustomer: TCustomer): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  TMockWarehouseRepository = class(TInterfacedObject, IWarehouseRepository)
  private
    FItems: TObjectList<TWarehouse>;
    FNextID: TEntityID;
  public
    constructor Create;
    destructor Destroy; override;
    function GetByID(AID: TEntityID): TWarehouse;
    function GetAll: TObjectList<TWarehouse>;
    function Save(AWarehouse: TWarehouse): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  { Mock Product Repository }
  TMockProductRepository = class(TInterfacedObject, IProductRepository)
  private
    FItems: TObjectList<TProduct>;
    FNextID: TEntityID;
  public
    constructor Create;
    destructor Destroy; override;
    function GetByID(AID: TEntityID): TProduct;
    function GetBySKU(const ASKU: string): TProduct;
    function GetAll(AOnlyActive: Boolean = True): TObjectList<TProduct>;
    function GetLowStockProducts: TObjectList<TProduct>;
    function Search(const AQuery: string): TObjectList<TProduct>;
    function Save(AProduct: TProduct): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  { Mock Stock Repository }
  TMockStockRepository = class(TInterfacedObject, IStockRepository)
  private
    FStockItems: TObjectList<TStockItem>;
    FMovements: TObjectList<TStockMovement>;
    FNextStockID: TEntityID;
    FNextMoveID: TEntityID;
  public
    constructor Create;
    destructor Destroy; override;
    function GetStockItem(AProductID, AWarehouseID: TEntityID): TStockItem;
    function GetStockByProduct(AProductID: TEntityID): TObjectList<TStockItem>;
    function GetStockByWarehouse(AWarehouseID: TEntityID): TObjectList<TStockItem>;
    function GetAllStockItems: TObjectList<TStockItem>;
    procedure SaveStockItem(AStockItem: TStockItem);
    procedure AddStockMovement(AMovement: TStockMovement);
    function GetMovementsByProduct(AProductID: TEntityID; ALimit: Integer = 100): TObjectList<TStockMovement>;
    function GetAllMovements(ALimit: Integer = 500): TObjectList<TStockMovement>;
  end;

  { Mock Orders Repositories }
  TMockPurchaseOrderRepository = class(TInterfacedObject, IPurchaseOrderRepository)
  private
    FItems: TObjectList<TPurchaseOrder>;
    FNextID: TEntityID;
    FOrderSeq: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function GetByID(AID: TEntityID): TPurchaseOrder;
    function GetByOrderNumber(const ANumber: string): TPurchaseOrder;
    function GetAll: TObjectList<TPurchaseOrder>;
    function GetByStatus(AStatus: TPurchaseOrderStatus): TObjectList<TPurchaseOrder>;
    function Save(AOrder: TPurchaseOrder): TEntityID;
    function Delete(AID: TEntityID): Boolean;
    function GenerateNextOrderNumber: string;
  end;

  TMockSalesOrderRepository = class(TInterfacedObject, ISalesOrderRepository)
  private
    FItems: TObjectList<TSalesOrder>;
    FNextID: TEntityID;
    FOrderSeq: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function GetByID(AID: TEntityID): TSalesOrder;
    function GetByOrderNumber(const ANumber: string): TSalesOrder;
    function GetAll: TObjectList<TSalesOrder>;
    function GetByStatus(AStatus: TSalesOrderStatus): TObjectList<TSalesOrder>;
    function Save(AOrder: TSalesOrder): TEntityID;
    function Delete(AID: TEntityID): Boolean;
    function GenerateNextOrderNumber: string;
  end;

  { Mock Audit Repository }
  TMockAuditRepository = class(TInterfacedObject, IAuditRepository)
  private
    FItems: TObjectList<TAuditLog>;
    FNextID: TEntityID;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddLog(ALog: TAuditLog);
    function GetAll(ALimit: Integer = 500): TObjectList<TAuditLog>;
    function GetByEntity(const AEntityName: string; AEntityID: TEntityID): TObjectList<TAuditLog>;
  end;

implementation

{ TMockUnitOfWork }

constructor TMockUnitOfWork.Create;
begin
  inherited Create;
  FInTx := False;
end;

procedure TMockUnitOfWork.BeginTransaction;
begin
  FInTx := True;
end;

procedure TMockUnitOfWork.Commit;
begin
  FInTx := False;
end;

procedure TMockUnitOfWork.Rollback;
begin
  FInTx := False;
end;

function TMockUnitOfWork.InTransaction: Boolean;
begin
  Result := FInTx;
end;

{ TMockUserRepository }

constructor TMockUserRepository.Create;
begin
  inherited Create;
  FItems := TObjectList<TUser>.Create(True);
  FNextID := 1;
end;

destructor TMockUserRepository.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMockUserRepository.GetByID(AID: TEntityID): TUser;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then Exit(FItems[I]);
end;

function TMockUserRepository.GetByUsername(const AUsername: string): TUser;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if SameText(FItems[I].Username, AUsername) then Exit(FItems[I]);
end;

function TMockUserRepository.GetAll: TObjectList<TUser>;
var
  I: Integer;
  CopyUser: TUser;
begin
  Result := TObjectList<TUser>.Create(False);
  for I := 0 to FItems.Count - 1 do
    Result.Add(FItems[I]);
end;

function TMockUserRepository.Save(AUser: TUser): TEntityID;
var
  Existing: TUser;
begin
  if AUser.ID <= 0 then
  begin
    AUser.ID := FNextID;
    Inc(FNextID);
    FItems.Add(AUser);
    Result := AUser.ID;
  end
  else
  begin
    Existing := GetByID(AUser.ID);
    if (Existing <> nil) and (Existing <> AUser) then
    begin
      Existing.Username := AUser.Username;
      Existing.PasswordHash := AUser.PasswordHash;
      Existing.PasswordSalt := AUser.PasswordSalt;
      Existing.FullName := AUser.FullName;
      Existing.Email := AUser.Email;
      Existing.Role := AUser.Role;
      Existing.IsActive := AUser.IsActive;
      Existing.LastLoginAt := AUser.LastLoginAt;
    end
    else if Existing = nil then
      FItems.Add(AUser);
    Result := AUser.ID;
  end;
end;

function TMockUserRepository.Delete(AID: TEntityID): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then
    begin
      FItems.Delete(I);
      Exit(True);
    end;
end;

{ TMockCategoryRepository }

constructor TMockCategoryRepository.Create;
begin
  inherited Create;
  FItems := TObjectList<TCategory>.Create(True);
  FNextID := 1;
end;

destructor TMockCategoryRepository.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMockCategoryRepository.GetByID(AID: TEntityID): TCategory;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then Exit(FItems[I]);
end;

function TMockCategoryRepository.GetAll: TObjectList<TCategory>;
var
  I: Integer;
begin
  Result := TObjectList<TCategory>.Create(False);
  for I := 0 to FItems.Count - 1 do
    Result.Add(FItems[I]);
end;

function TMockCategoryRepository.Save(ACategory: TCategory): TEntityID;
var
  Existing: TCategory;
begin
  if ACategory.ID <= 0 then
  begin
    ACategory.ID := FNextID;
    Inc(FNextID);
    FItems.Add(ACategory);
    Result := ACategory.ID;
  end
  else
  begin
    Existing := GetByID(ACategory.ID);
    if (Existing <> nil) and (Existing <> ACategory) then
    begin
      Existing.Code := ACategory.Code;
      Existing.Name := ACategory.Name;
      Existing.Description := ACategory.Description;
      Existing.IsActive := ACategory.IsActive;
    end
    else if Existing = nil then
      FItems.Add(ACategory);
    Result := ACategory.ID;
  end;
end;

function TMockCategoryRepository.Delete(AID: TEntityID): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then
    begin
      FItems.Delete(I);
      Exit(True);
    end;
end;

{ TMockSupplierRepository }

constructor TMockSupplierRepository.Create;
begin
  inherited Create;
  FItems := TObjectList<TSupplier>.Create(True);
  FNextID := 1;
end;

destructor TMockSupplierRepository.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMockSupplierRepository.GetByID(AID: TEntityID): TSupplier;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then Exit(FItems[I]);
end;

function TMockSupplierRepository.GetAll: TObjectList<TSupplier>;
var
  I: Integer;
begin
  Result := TObjectList<TSupplier>.Create(False);
  for I := 0 to FItems.Count - 1 do
    Result.Add(FItems[I]);
end;

function TMockSupplierRepository.Save(ASupplier: TSupplier): TEntityID;
var
  Existing: TSupplier;
begin
  if ASupplier.ID <= 0 then
  begin
    ASupplier.ID := FNextID;
    Inc(FNextID);
    FItems.Add(ASupplier);
    Result := ASupplier.ID;
  end
  else
  begin
    Existing := GetByID(ASupplier.ID);
    if (Existing <> nil) and (Existing <> ASupplier) then
    begin
      Existing.Code := ASupplier.Code;
      Existing.CompanyName := ASupplier.CompanyName;
      Existing.ContactPerson := ASupplier.ContactPerson;
      Existing.Email := ASupplier.Email;
      Existing.Phone := ASupplier.Phone;
      Existing.Address := ASupplier.Address;
      Existing.City := ASupplier.City;
      Existing.PostalCode := ASupplier.PostalCode;
      Existing.Country := ASupplier.Country;
      Existing.IsActive := ASupplier.IsActive;
    end
    else if Existing = nil then
      FItems.Add(ASupplier);
    Result := ASupplier.ID;
  end;
end;

function TMockSupplierRepository.Delete(AID: TEntityID): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then
    begin
      FItems.Delete(I);
      Exit(True);
    end;
end;

{ TMockCustomerRepository }

constructor TMockCustomerRepository.Create;
begin
  inherited Create;
  FItems := TObjectList<TCustomer>.Create(True);
  FNextID := 1;
end;

destructor TMockCustomerRepository.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMockCustomerRepository.GetByID(AID: TEntityID): TCustomer;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then Exit(FItems[I]);
end;

function TMockCustomerRepository.GetAll: TObjectList<TCustomer>;
var
  I: Integer;
begin
  Result := TObjectList<TCustomer>.Create(False);
  for I := 0 to FItems.Count - 1 do
    Result.Add(FItems[I]);
end;

function TMockCustomerRepository.Save(ACustomer: TCustomer): TEntityID;
var
  Existing: TCustomer;
begin
  if ACustomer.ID <= 0 then
  begin
    ACustomer.ID := FNextID;
    Inc(FNextID);
    FItems.Add(ACustomer);
    Result := ACustomer.ID;
  end
  else
  begin
    Existing := GetByID(ACustomer.ID);
    if (Existing <> nil) and (Existing <> ACustomer) then
    begin
      Existing.Code := ACustomer.Code;
      Existing.CompanyName := ACustomer.CompanyName;
      Existing.ContactPerson := ACustomer.ContactPerson;
      Existing.Email := ACustomer.Email;
      Existing.Phone := ACustomer.Phone;
      Existing.Address := ACustomer.Address;
      Existing.City := ACustomer.City;
      Existing.PostalCode := ACustomer.PostalCode;
      Existing.Country := ACustomer.Country;
      Existing.CreditLimit := ACustomer.CreditLimit;
      Existing.OutstandingBalance := ACustomer.OutstandingBalance;
      Existing.IsActive := ACustomer.IsActive;
    end
    else if Existing = nil then
      FItems.Add(ACustomer);
    Result := ACustomer.ID;
  end;
end;

function TMockCustomerRepository.Delete(AID: TEntityID): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then
    begin
      FItems.Delete(I);
      Exit(True);
    end;
end;

{ TMockWarehouseRepository }

constructor TMockWarehouseRepository.Create;
begin
  inherited Create;
  FItems := TObjectList<TWarehouse>.Create(True);
  FNextID := 1;
end;

destructor TMockWarehouseRepository.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMockWarehouseRepository.GetByID(AID: TEntityID): TWarehouse;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then Exit(FItems[I]);
end;

function TMockWarehouseRepository.GetAll: TObjectList<TWarehouse>;
var
  I: Integer;
begin
  Result := TObjectList<TWarehouse>.Create(False);
  for I := 0 to FItems.Count - 1 do
    Result.Add(FItems[I]);
end;

function TMockWarehouseRepository.Save(AWarehouse: TWarehouse): TEntityID;
var
  Existing: TWarehouse;
begin
  if AWarehouse.ID <= 0 then
  begin
    AWarehouse.ID := FNextID;
    Inc(FNextID);
    FItems.Add(AWarehouse);
    Result := AWarehouse.ID;
  end
  else
  begin
    Existing := GetByID(AWarehouse.ID);
    if (Existing <> nil) and (Existing <> AWarehouse) then
    begin
      Existing.Code := AWarehouse.Code;
      Existing.Name := AWarehouse.Name;
      Existing.Location := AWarehouse.Location;
      Existing.IsActive := AWarehouse.IsActive;
    end
    else if Existing = nil then
      FItems.Add(AWarehouse);
    Result := AWarehouse.ID;
  end;
end;

function TMockWarehouseRepository.Delete(AID: TEntityID): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then
    begin
      FItems.Delete(I);
      Exit(True);
    end;
end;

{ TMockProductRepository }

constructor TMockProductRepository.Create;
begin
  inherited Create;
  FItems := TObjectList<TProduct>.Create(True);
  FNextID := 1;
end;

destructor TMockProductRepository.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMockProductRepository.GetByID(AID: TEntityID): TProduct;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then Exit(FItems[I]);
end;

function TMockProductRepository.GetBySKU(const ASKU: string): TProduct;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if SameText(FItems[I].SKU, ASKU) then Exit(FItems[I]);
end;

function TMockProductRepository.GetAll(AOnlyActive: Boolean): TObjectList<TProduct>;
var
  I: Integer;
begin
  Result := TObjectList<TProduct>.Create(False);
  for I := 0 to FItems.Count - 1 do
    if (not AOnlyActive) or FItems[I].IsActive then
      Result.Add(FItems[I]);
end;

function TMockProductRepository.GetLowStockProducts: TObjectList<TProduct>;
var
  I: Integer;
begin
  Result := TObjectList<TProduct>.Create(False);
  for I := 0 to FItems.Count - 1 do
    if FItems[I].IsActive and FItems[I].IsLowStock then
      Result.Add(FItems[I]);
end;

function TMockProductRepository.Search(const AQuery: string): TObjectList<TProduct>;
var
  I: Integer;
  Q: string;
begin
  Result := TObjectList<TProduct>.Create(False);
  Q := UpperCase(Trim(AQuery));
  for I := 0 to FItems.Count - 1 do
    if (Q = '') or (Pos(Q, UpperCase(FItems[I].Name)) > 0) or (Pos(Q, UpperCase(FItems[I].SKU)) > 0) or (Pos(Q, UpperCase(FItems[I].Barcode)) > 0) then
      Result.Add(FItems[I]);
end;

function TMockProductRepository.Save(AProduct: TProduct): TEntityID;
var
  Existing: TProduct;
begin
  if AProduct.ID <= 0 then
  begin
    AProduct.ID := FNextID;
    Inc(FNextID);
    FItems.Add(AProduct);
    Result := AProduct.ID;
  end
  else
  begin
    Existing := GetByID(AProduct.ID);
    if (Existing <> nil) and (Existing <> AProduct) then
    begin
      Existing.SKU := AProduct.SKU;
      Existing.Barcode := AProduct.Barcode;
      Existing.Name := AProduct.Name;
      Existing.Description := AProduct.Description;
      Existing.CategoryID := AProduct.CategoryID;
      Existing.CostPrice := AProduct.CostPrice;
      Existing.UnitPrice := AProduct.UnitPrice;
      Existing.CurrentStockTotal := AProduct.CurrentStockTotal;
      Existing.MinStockLevel := AProduct.MinStockLevel;
      Existing.MaxStockLevel := AProduct.MaxStockLevel;
      Existing.UnitType := AProduct.UnitType;
      Existing.IsActive := AProduct.IsActive;
      Existing.UpdatedAt := Now;
    end
    else if Existing = nil then
      FItems.Add(AProduct);
    Result := AProduct.ID;
  end;
end;

function TMockProductRepository.Delete(AID: TEntityID): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then
    begin
      FItems.Delete(I);
      Exit(True);
    end;
end;

{ TMockStockRepository }

constructor TMockStockRepository.Create;
begin
  inherited Create;
  FStockItems := TObjectList<TStockItem>.Create(True);
  FMovements := TObjectList<TStockMovement>.Create(True);
  FNextStockID := 1;
  FNextMoveID := 1;
end;

destructor TMockStockRepository.Destroy;
begin
  FStockItems.Free;
  FMovements.Free;
  inherited Destroy;
end;

function TMockStockRepository.GetStockItem(AProductID, AWarehouseID: TEntityID): TStockItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FStockItems.Count - 1 do
    if (FStockItems[I].ProductID = AProductID) and (FStockItems[I].WarehouseID = AWarehouseID) then
      Exit(FStockItems[I]);
end;

function TMockStockRepository.GetStockByProduct(AProductID: TEntityID): TObjectList<TStockItem>;
var
  I: Integer;
begin
  Result := TObjectList<TStockItem>.Create(False);
  for I := 0 to FStockItems.Count - 1 do
    if FStockItems[I].ProductID = AProductID then
      Result.Add(FStockItems[I]);
end;

function TMockStockRepository.GetStockByWarehouse(AWarehouseID: TEntityID): TObjectList<TStockItem>;
var
  I: Integer;
begin
  Result := TObjectList<TStockItem>.Create(False);
  for I := 0 to FStockItems.Count - 1 do
    if FStockItems[I].WarehouseID = AWarehouseID then
      Result.Add(FStockItems[I]);
end;

function TMockStockRepository.GetAllStockItems: TObjectList<TStockItem>;
var
  I: Integer;
begin
  Result := TObjectList<TStockItem>.Create(False);
  for I := 0 to FStockItems.Count - 1 do
    Result.Add(FStockItems[I]);
end;

procedure TMockStockRepository.SaveStockItem(AStockItem: TStockItem);
var
  Existing: TStockItem;
begin
  Existing := GetStockItem(AStockItem.ProductID, AStockItem.WarehouseID);
  if Existing = nil then
  begin
    AStockItem.ID := FNextStockID;
    Inc(FNextStockID);
    FStockItems.Add(AStockItem);
  end
  else if Existing <> AStockItem then
  begin
    Existing.Quantity := AStockItem.Quantity;
    Existing.ReservedQuantity := AStockItem.ReservedQuantity;
  end;
end;

procedure TMockStockRepository.AddStockMovement(AMovement: TStockMovement);
var
  CopyMove: TStockMovement;
begin
  CopyMove := TStockMovement.Create;
  CopyMove.ID := FNextMoveID;
  Inc(FNextMoveID);
  CopyMove.MovementType := AMovement.MovementType;
  CopyMove.ProductID := AMovement.ProductID;
  CopyMove.WarehouseID := AMovement.WarehouseID;
  CopyMove.TargetWarehouseID := AMovement.TargetWarehouseID;
  CopyMove.Quantity := AMovement.Quantity;
  CopyMove.ReferenceType := AMovement.ReferenceType;
  CopyMove.ReferenceID := AMovement.ReferenceID;
  CopyMove.UnitCost := AMovement.UnitCost;
  CopyMove.Reason := AMovement.Reason;
  CopyMove.UserID := AMovement.UserID;
  CopyMove.Timestamp := AMovement.Timestamp;
  FMovements.Add(CopyMove);
end;

function TMockStockRepository.GetMovementsByProduct(AProductID: TEntityID; ALimit: Integer): TObjectList<TStockMovement>;
var
  I: Integer;
begin
  Result := TObjectList<TStockMovement>.Create(False);
  for I := FMovements.Count - 1 downto 0 do
  begin
    if (FMovements[I].ProductID = AProductID) then
    begin
      Result.Add(FMovements[I]);
      if Result.Count >= ALimit then Break;
    end;
  end;
end;

function TMockStockRepository.GetAllMovements(ALimit: Integer): TObjectList<TStockMovement>;
var
  I: Integer;
begin
  Result := TObjectList<TStockMovement>.Create(False);
  for I := FMovements.Count - 1 downto 0 do
  begin
    Result.Add(FMovements[I]);
    if Result.Count >= ALimit then Break;
  end;
end;

{ TMockPurchaseOrderRepository }

constructor TMockPurchaseOrderRepository.Create;
begin
  inherited Create;
  FItems := TObjectList<TPurchaseOrder>.Create(True);
  FNextID := 1;
  FOrderSeq := 100;
end;

destructor TMockPurchaseOrderRepository.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMockPurchaseOrderRepository.GetByID(AID: TEntityID): TPurchaseOrder;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then Exit(FItems[I]);
end;

function TMockPurchaseOrderRepository.GetByOrderNumber(const ANumber: string): TPurchaseOrder;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if SameText(FItems[I].OrderNumber, ANumber) then Exit(FItems[I]);
end;

function TMockPurchaseOrderRepository.GetAll: TObjectList<TPurchaseOrder>;
var
  I: Integer;
begin
  Result := TObjectList<TPurchaseOrder>.Create(False);
  for I := 0 to FItems.Count - 1 do
    Result.Add(FItems[I]);
end;

function TMockPurchaseOrderRepository.GetByStatus(AStatus: TPurchaseOrderStatus): TObjectList<TPurchaseOrder>;
var
  I: Integer;
begin
  Result := TObjectList<TPurchaseOrder>.Create(False);
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Status = AStatus then
      Result.Add(FItems[I]);
end;

function TMockPurchaseOrderRepository.Save(AOrder: TPurchaseOrder): TEntityID;
var
  Existing: TPurchaseOrder;
  I: Integer;
begin
  if AOrder.ID <= 0 then
  begin
    AOrder.ID := FNextID;
    Inc(FNextID);
    for I := 0 to AOrder.Lines.Count - 1 do
      AOrder.Lines[I].PurchaseOrderID := AOrder.ID;
    FItems.Add(AOrder);
    Result := AOrder.ID;
  end
  else
  begin
    Existing := GetByID(AOrder.ID);
    if (Existing <> nil) and (Existing <> AOrder) then
    begin
      Existing.Status := AOrder.Status;
      Existing.TotalAmount := AOrder.TotalAmount;
      Existing.Notes := AOrder.Notes;
    end
    else if Existing = nil then
      FItems.Add(AOrder);
    Result := AOrder.ID;
  end;
end;

function TMockPurchaseOrderRepository.Delete(AID: TEntityID): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then
    begin
      FItems.Delete(I);
      Exit(True);
    end;
end;

function TMockPurchaseOrderRepository.GenerateNextOrderNumber: string;
begin
  Inc(FOrderSeq);
  Result := Format('PO-%s-%04d', [FormatDateTime('yyyy', Now), FOrderSeq]);
end;

{ TMockSalesOrderRepository }

constructor TMockSalesOrderRepository.Create;
begin
  inherited Create;
  FItems := TObjectList<TSalesOrder>.Create(True);
  FNextID := 1;
  FOrderSeq := 100;
end;

destructor TMockSalesOrderRepository.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMockSalesOrderRepository.GetByID(AID: TEntityID): TSalesOrder;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then Exit(FItems[I]);
end;

function TMockSalesOrderRepository.GetByOrderNumber(const ANumber: string): TSalesOrder;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if SameText(FItems[I].OrderNumber, ANumber) then Exit(FItems[I]);
end;

function TMockSalesOrderRepository.GetAll: TObjectList<TSalesOrder>;
var
  I: Integer;
begin
  Result := TObjectList<TSalesOrder>.Create(False);
  for I := 0 to FItems.Count - 1 do
    Result.Add(FItems[I]);
end;

function TMockSalesOrderRepository.GetByStatus(AStatus: TSalesOrderStatus): TObjectList<TSalesOrder>;
var
  I: Integer;
begin
  Result := TObjectList<TSalesOrder>.Create(False);
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Status = AStatus then
      Result.Add(FItems[I]);
end;

function TMockSalesOrderRepository.Save(AOrder: TSalesOrder): TEntityID;
var
  Existing: TSalesOrder;
  I: Integer;
begin
  if AOrder.ID <= 0 then
  begin
    AOrder.ID := FNextID;
    Inc(FNextID);
    for I := 0 to AOrder.Lines.Count - 1 do
      AOrder.Lines[I].SalesOrderID := AOrder.ID;
    FItems.Add(AOrder);
    Result := AOrder.ID;
  end
  else
  begin
    Existing := GetByID(AOrder.ID);
    if (Existing <> nil) and (Existing <> AOrder) then
    begin
      Existing.Status := AOrder.Status;
      Existing.SubTotal := AOrder.SubTotal;
      Existing.TaxAmount := AOrder.TaxAmount;
      Existing.TotalAmount := AOrder.TotalAmount;
      Existing.Notes := AOrder.Notes;
    end
    else if Existing = nil then
      FItems.Add(AOrder);
    Result := AOrder.ID;
  end;
end;

function TMockSalesOrderRepository.Delete(AID: TEntityID): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].ID = AID then
    begin
      FItems.Delete(I);
      Exit(True);
    end;
end;

function TMockSalesOrderRepository.GenerateNextOrderNumber: string;
begin
  Inc(FOrderSeq);
  Result := Format('SO-%s-%04d', [FormatDateTime('yyyy', Now), FOrderSeq]);
end;

{ TMockAuditRepository }

constructor TMockAuditRepository.Create;
begin
  inherited Create;
  FItems := TObjectList<TAuditLog>.Create(True);
  FNextID := 1;
end;

destructor TMockAuditRepository.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TMockAuditRepository.AddLog(ALog: TAuditLog);
var
  CopyLog: TAuditLog;
begin
  CopyLog := TAuditLog.Create;
  CopyLog.ID := FNextID;
  Inc(FNextID);
  CopyLog.Timestamp := ALog.Timestamp;
  CopyLog.UserID := ALog.UserID;
  CopyLog.Username := ALog.Username;
  CopyLog.Action := ALog.Action;
  CopyLog.EntityName := ALog.EntityName;
  CopyLog.EntityID := ALog.EntityID;
  CopyLog.Details := ALog.Details;
  CopyLog.ClientIP := ALog.ClientIP;
  FItems.Add(CopyLog);
end;

function TMockAuditRepository.GetAll(ALimit: Integer): TObjectList<TAuditLog>;
var
  I: Integer;
begin
  Result := TObjectList<TAuditLog>.Create(False);
  for I := FItems.Count - 1 downto 0 do
  begin
    Result.Add(FItems[I]);
    if Result.Count >= ALimit then Break;
  end;
end;

function TMockAuditRepository.GetByEntity(const AEntityName: string; AEntityID: TEntityID): TObjectList<TAuditLog>;
var
  I: Integer;
begin
  Result := TObjectList<TAuditLog>.Create(False);
  for I := FItems.Count - 1 downto 0 do
  begin
    if SameText(FItems[I].EntityName, AEntityName) and (FItems[I].EntityID = AEntityID) then
      Result.Add(FItems[I]);
  end;
end;

end.
