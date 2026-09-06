unit Warenfluss.Repositories.mORMot;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Generics.Collections,
  mormot.core.base,
  mormot.core.unicode,
  mormot.orm.core,
  mormot.orm.sqlite3,
  Warenfluss.Types,
  Warenfluss.ORM.Models,
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
  { mORMot 2 Unit of Work }
  TmORMotUnitOfWork = class(TInterfacedObject, IUnitOfWork)
  private
    FRest: TRestOrmServerDB;
    FInTx: Boolean;
  public
    constructor Create(ARest: TRestOrmServerDB);
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;
  end;

  { mORMot 2 User Repository }
  TmORMotUserRepository = class(TInterfacedObject, IUserRepository)
  private
    FRest: TRestOrmServerDB;
    function RecordToDomain(ARec: TSQLUser): TUser;
  public
    constructor Create(ARest: TRestOrmServerDB);
    function GetByID(AID: TEntityID): TUser;
    function GetByUsername(const AUsername: string): TUser;
    function GetAll: TObjectList<TUser>;
    function Save(AUser: TUser): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  { mORMot 2 Product Repository }
  TmORMotProductRepository = class(TInterfacedObject, IProductRepository)
  private
    FRest: TRestOrmServerDB;
    function RecordToDomain(ARec: TSQLProduct): TProduct;
  public
    constructor Create(ARest: TRestOrmServerDB);
    function GetByID(AID: TEntityID): TProduct;
    function GetBySKU(const ASKU: string): TProduct;
    function GetAll(AOnlyActive: Boolean = True): TObjectList<TProduct>;
    function GetLowStockProducts: TObjectList<TProduct>;
    function Search(const AQuery: string): TObjectList<TProduct>;
    function Save(AProduct: TProduct): TEntityID;
    function Delete(AID: TEntityID): Boolean;
  end;

  { mORMot 2 Stock Repository }
  TmORMotStockRepository = class(TInterfacedObject, IStockRepository)
  private
    FRest: TRestOrmServerDB;
    function ItemRecordToDomain(ARec: TSQLStockItem): TStockItem;
    function MoveRecordToDomain(ARec: TSQLStockMovement): TStockMovement;
  public
    constructor Create(ARest: TRestOrmServerDB);
    function GetStockItem(AProductID, AWarehouseID: TEntityID): TStockItem;
    function GetStockByProduct(AProductID: TEntityID): TObjectList<TStockItem>;
    function GetStockByWarehouse(AWarehouseID: TEntityID): TObjectList<TStockItem>;
    function GetAllStockItems: TObjectList<TStockItem>;
    procedure SaveStockItem(AStockItem: TStockItem);
    procedure AddStockMovement(AMovement: TStockMovement);
    function GetMovementsByProduct(AProductID: TEntityID; ALimit: Integer = 100): TObjectList<TStockMovement>;
    function GetAllMovements(ALimit: Integer = 500): TObjectList<TStockMovement>;
  end;

implementation

{ TmORMotUnitOfWork }

constructor TmORMotUnitOfWork.Create(ARest: TRestOrmServerDB);
begin
  inherited Create;
  FRest := ARest;
  FInTx := False;
end;

procedure TmORMotUnitOfWork.BeginTransaction;
begin
  if not FInTx and (FRest <> nil) then
  begin
    FRest.TransactionBegin(nil);
    FInTx := True;
  end;
end;

procedure TmORMotUnitOfWork.Commit;
begin
  if FInTx and (FRest <> nil) then
  begin
    FRest.Commit(0);
    FInTx := False;
  end;
end;

procedure TmORMotUnitOfWork.Rollback;
begin
  if FInTx and (FRest <> nil) then
  begin
    FRest.Rollback(0);
    FInTx := False;
  end;
end;

function TmORMotUnitOfWork.InTransaction: Boolean;
begin
  Result := FInTx;
end;

{ TmORMotUserRepository }

constructor TmORMotUserRepository.Create(ARest: TRestOrmServerDB);
begin
  inherited Create;
  FRest := ARest;
end;

function TmORMotUserRepository.RecordToDomain(ARec: TSQLUser): TUser;
begin
  if ARec = nil then Exit(nil);
  Result := TUser.Create;
  Result.ID := ARec.ID;
  Result.Username := Utf8ToString(ARec.Username);
  Result.PasswordHash := Utf8ToString(ARec.PasswordHash);
  Result.PasswordSalt := Utf8ToString(ARec.PasswordSalt);
  Result.FullName := Utf8ToString(ARec.FullName);
  Result.Email := Utf8ToString(ARec.Email);
  Result.Role := TRoleType(ARec.Role);
  Result.IsActive := ARec.IsActive;
  Result.CreatedAt := Now;
  Result.LastLoginAt := 0;
end;

function TmORMotUserRepository.GetByID(AID: TEntityID): TUser;
var
  Rec: TSQLUser;
begin
  Rec := TSQLUser.Create(FRest, AID);
  try
    if Rec.ID = AID then
      Result := RecordToDomain(Rec)
    else
      Result := nil;
  finally
    Rec.Free;
  end;
end;

function TmORMotUserRepository.GetByUsername(const AUsername: string): TUser;
var
  Rec: TSQLUser;
begin
  Rec := TSQLUser.Create(FRest, 'Username=?', [StringToUtf8(AUsername)]);
  try
    if Rec.ID > 0 then
      Result := RecordToDomain(Rec)
    else
      Result := nil;
  finally
    Rec.Free;
  end;
end;

function TmORMotUserRepository.GetAll: TObjectList<TUser>;
var
  Rec: TSQLUser;
begin
  Result := TObjectList<TUser>.Create(True);
  Rec := TSQLUser.CreateAndFillPrepare(FRest, '', []);
  try
    while Rec.FillOne do
      Result.Add(RecordToDomain(Rec));
  finally
    Rec.Free;
  end;
end;

function TmORMotUserRepository.Save(AUser: TUser): TEntityID;
var
  Rec: TSQLUser;
begin
  if AUser.ID > 0 then
    Rec := TSQLUser.Create(FRest, AUser.ID)
  else
    Rec := TSQLUser.Create;
  try
    Rec.Username := StringToUtf8(AUser.Username);
    Rec.PasswordHash := StringToUtf8(AUser.PasswordHash);
    Rec.PasswordSalt := StringToUtf8(AUser.PasswordSalt);
    Rec.FullName := StringToUtf8(AUser.FullName);
    Rec.Email := StringToUtf8(AUser.Email);
    Rec.Role := Ord(AUser.Role);
    Rec.IsActive := AUser.IsActive;

    if AUser.ID > 0 then
    begin
      FRest.Update(Rec);
      Result := AUser.ID;
    end
    else
    begin
      Result := FRest.Add(Rec, True);
      AUser.ID := Result;
    end;
  finally
    Rec.Free;
  end;
end;

function TmORMotUserRepository.Delete(AID: TEntityID): Boolean;
begin
  Result := FRest.Delete(TSQLUser, AID);
end;

{ TmORMotProductRepository }

constructor TmORMotProductRepository.Create(ARest: TRestOrmServerDB);
begin
  inherited Create;
  FRest := ARest;
end;

function TmORMotProductRepository.RecordToDomain(ARec: TSQLProduct): TProduct;
begin
  if ARec = nil then Exit(nil);
  Result := TProduct.Create;
  Result.ID := ARec.ID;
  Result.SKU := Utf8ToString(ARec.SKU);
  Result.Barcode := Utf8ToString(ARec.Barcode);
  Result.Name := Utf8ToString(ARec.Name);
  Result.Description := Utf8ToString(ARec.Description);
  Result.CategoryID := ARec.CategoryID;
  Result.CostPrice := ARec.CostPrice;
  Result.UnitPrice := ARec.UnitPrice;
  Result.CurrentStockTotal := ARec.CurrentStockTotal;
  Result.MinStockLevel := ARec.MinStockLevel;
  Result.MaxStockLevel := ARec.MaxStockLevel;
  Result.UnitType := TProductUnit(ARec.UnitType);
  Result.IsActive := ARec.IsActive;
  Result.CreatedAt := Now;
  Result.UpdatedAt := Now;
end;

function TmORMotProductRepository.GetByID(AID: TEntityID): TProduct;
var
  Rec: TSQLProduct;
begin
  Rec := TSQLProduct.Create(FRest, AID);
  try
    if Rec.ID = AID then
      Result := RecordToDomain(Rec)
    else
      Result := nil;
  finally
    Rec.Free;
  end;
end;

function TmORMotProductRepository.GetBySKU(const ASKU: string): TProduct;
var
  Rec: TSQLProduct;
begin
  Rec := TSQLProduct.Create(FRest, 'SKU=?', [StringToUtf8(ASKU)]);
  try
    if Rec.ID > 0 then
      Result := RecordToDomain(Rec)
    else
      Result := nil;
  finally
    Rec.Free;
  end;
end;

function TmORMotProductRepository.GetAll(AOnlyActive: Boolean): TObjectList<TProduct>;
var
  Rec: TSQLProduct;
begin
  Result := TObjectList<TProduct>.Create(True);
  if AOnlyActive then
    Rec := TSQLProduct.CreateAndFillPrepare(FRest, 'IsActive=1', [])
  else
    Rec := TSQLProduct.CreateAndFillPrepare(FRest, '', []);
  try
    while Rec.FillOne do
      Result.Add(RecordToDomain(Rec));
  finally
    Rec.Free;
  end;
end;

function TmORMotProductRepository.GetLowStockProducts: TObjectList<TProduct>;
var
  Rec: TSQLProduct;
begin
  Result := TObjectList<TProduct>.Create(True);
  Rec := TSQLProduct.CreateAndFillPrepare(FRest, 'IsActive=1 AND CurrentStockTotal <= MinStockLevel', []);
  try
    while Rec.FillOne do
      Result.Add(RecordToDomain(Rec));
  finally
    Rec.Free;
  end;
end;

function TmORMotProductRepository.Search(const AQuery: string): TObjectList<TProduct>;
var
  Rec: TSQLProduct;
  Pattern: RawUtf8;
begin
  Result := TObjectList<TProduct>.Create(True);
  Pattern := '%' + StringToUtf8(Trim(AQuery)) + '%';
  Rec := TSQLProduct.CreateAndFillPrepare(FRest, 'Name LIKE ? OR SKU LIKE ? OR Barcode LIKE ?', [Pattern, Pattern, Pattern]);
  try
    while Rec.FillOne do
      Result.Add(RecordToDomain(Rec));
  finally
    Rec.Free;
  end;
end;

function TmORMotProductRepository.Save(AProduct: TProduct): TEntityID;
var
  Rec: TSQLProduct;
begin
  if AProduct.ID > 0 then
    Rec := TSQLProduct.Create(FRest, AProduct.ID)
  else
    Rec := TSQLProduct.Create;
  try
    Rec.SKU := StringToUtf8(AProduct.SKU);
    Rec.Barcode := StringToUtf8(AProduct.Barcode);
    Rec.Name := StringToUtf8(AProduct.Name);
    Rec.Description := StringToUtf8(AProduct.Description);
    Rec.CategoryID := AProduct.CategoryID;
    Rec.CostPrice := AProduct.CostPrice;
    Rec.UnitPrice := AProduct.UnitPrice;
    Rec.CurrentStockTotal := AProduct.CurrentStockTotal;
    Rec.MinStockLevel := AProduct.MinStockLevel;
    Rec.MaxStockLevel := AProduct.MaxStockLevel;
    Rec.UnitType := Ord(AProduct.UnitType);
    Rec.IsActive := AProduct.IsActive;

    if AProduct.ID > 0 then
    begin
      FRest.Update(Rec);
      Result := AProduct.ID;
    end
    else
    begin
      Result := FRest.Add(Rec, True);
      AProduct.ID := Result;
    end;
  finally
    Rec.Free;
  end;
end;

function TmORMotProductRepository.Delete(AID: TEntityID): Boolean;
begin
  Result := FRest.Delete(TSQLProduct, AID);
end;

{ TmORMotStockRepository }

constructor TmORMotStockRepository.Create(ARest: TRestOrmServerDB);
begin
  inherited Create;
  FRest := ARest;
end;

function TmORMotStockRepository.ItemRecordToDomain(ARec: TSQLStockItem): TStockItem;
begin
  if ARec = nil then Exit(nil);
  Result := TStockItem.Create;
  Result.ID := ARec.ID;
  Result.ProductID := ARec.ProductID;
  Result.WarehouseID := ARec.WarehouseID;
  Result.Quantity := ARec.Quantity;
  Result.ReservedQuantity := ARec.ReservedQuantity;
end;

function TmORMotStockRepository.MoveRecordToDomain(ARec: TSQLStockMovement): TStockMovement;
begin
  if ARec = nil then Exit(nil);
  Result := TStockMovement.Create;
  Result.ID := ARec.ID;
  Result.MovementType := TMovementType(ARec.MovementType);
  Result.ProductID := ARec.ProductID;
  Result.WarehouseID := ARec.WarehouseID;
  Result.TargetWarehouseID := ARec.TargetWarehouseID;
  Result.Quantity := ARec.Quantity;
  Result.ReferenceType := Utf8ToString(ARec.ReferenceType);
  Result.ReferenceID := ARec.ReferenceID;
  Result.UnitCost := ARec.UnitCost;
  Result.Reason := Utf8ToString(ARec.Reason);
  Result.UserID := ARec.UserID;
  Result.Timestamp := Now;
end;

function TmORMotStockRepository.GetStockItem(AProductID, AWarehouseID: TEntityID): TStockItem;
var
  Rec: TSQLStockItem;
begin
  Rec := TSQLStockItem.Create(FRest, 'ProductID=? AND WarehouseID=?', [AProductID, AWarehouseID]);
  try
    if Rec.ID > 0 then
      Result := ItemRecordToDomain(Rec)
    else
      Result := nil;
  finally
    Rec.Free;
  end;
end;

function TmORMotStockRepository.GetStockByProduct(AProductID: TEntityID): TObjectList<TStockItem>;
var
  Rec: TSQLStockItem;
begin
  Result := TObjectList<TStockItem>.Create(True);
  Rec := TSQLStockItem.CreateAndFillPrepare(FRest, 'ProductID=?', [AProductID]);
  try
    while Rec.FillOne do
      Result.Add(ItemRecordToDomain(Rec));
  finally
    Rec.Free;
  end;
end;

function TmORMotStockRepository.GetStockByWarehouse(AWarehouseID: TEntityID): TObjectList<TStockItem>;
var
  Rec: TSQLStockItem;
begin
  Result := TObjectList<TStockItem>.Create(True);
  Rec := TSQLStockItem.CreateAndFillPrepare(FRest, 'WarehouseID=?', [AWarehouseID]);
  try
    while Rec.FillOne do
      Result.Add(ItemRecordToDomain(Rec));
  finally
    Rec.Free;
  end;
end;

function TmORMotStockRepository.GetAllStockItems: TObjectList<TStockItem>;
var
  Rec: TSQLStockItem;
begin
  Result := TObjectList<TStockItem>.Create(True);
  Rec := TSQLStockItem.CreateAndFillPrepare(FRest, '', []);
  try
    while Rec.FillOne do
      Result.Add(ItemRecordToDomain(Rec));
  finally
    Rec.Free;
  end;
end;

procedure TmORMotStockRepository.SaveStockItem(AStockItem: TStockItem);
var
  Rec: TSQLStockItem;
begin
  Rec := TSQLStockItem.Create(FRest, 'ProductID=? AND WarehouseID=?', [AStockItem.ProductID, AStockItem.WarehouseID]);
  try
    if Rec.ID > 0 then
    begin
      Rec.Quantity := AStockItem.Quantity;
      Rec.ReservedQuantity := AStockItem.ReservedQuantity;
      FRest.Update(Rec);
      AStockItem.ID := Rec.ID;
    end
    else
    begin
      Rec.Free;
      Rec := TSQLStockItem.Create;
      Rec.ProductID := AStockItem.ProductID;
      Rec.WarehouseID := AStockItem.WarehouseID;
      Rec.Quantity := AStockItem.Quantity;
      Rec.ReservedQuantity := AStockItem.ReservedQuantity;
      AStockItem.ID := FRest.Add(Rec, True);
    end;
  finally
    Rec.Free;
  end;
end;

procedure TmORMotStockRepository.AddStockMovement(AMovement: TStockMovement);
var
  Rec: TSQLStockMovement;
begin
  Rec := TSQLStockMovement.Create;
  try
    Rec.MovementType := Ord(AMovement.MovementType);
    Rec.ProductID := AMovement.ProductID;
    Rec.WarehouseID := AMovement.WarehouseID;
    Rec.TargetWarehouseID := AMovement.TargetWarehouseID;
    Rec.Quantity := AMovement.Quantity;
    Rec.ReferenceType := StringToUtf8(AMovement.ReferenceType);
    Rec.ReferenceID := AMovement.ReferenceID;
    Rec.UnitCost := AMovement.UnitCost;
    Rec.Reason := StringToUtf8(AMovement.Reason);
    Rec.UserID := AMovement.UserID;
    AMovement.ID := FRest.Add(Rec, True);
  finally
    Rec.Free;
  end;
end;

function TmORMotStockRepository.GetMovementsByProduct(AProductID: TEntityID; ALimit: Integer): TObjectList<TStockMovement>;
var
  Rec: TSQLStockMovement;
begin
  Result := TObjectList<TStockMovement>.Create(True);
  Rec := TSQLStockMovement.CreateAndFillPrepare(FRest, 'ProductID=? ORDER BY RowID DESC LIMIT ?', [AProductID, ALimit]);
  try
    while Rec.FillOne do
      Result.Add(MoveRecordToDomain(Rec));
  finally
    Rec.Free;
  end;
end;

function TmORMotStockRepository.GetAllMovements(ALimit: Integer): TObjectList<TStockMovement>;
var
  Rec: TSQLStockMovement;
begin
  Result := TObjectList<TStockMovement>.Create(True);
  Rec := TSQLStockMovement.CreateAndFillPrepare(FRest, 'ORDER BY RowID DESC LIMIT ?', [ALimit]);
  try
    while Rec.FillOne do
      Result.Add(MoveRecordToDomain(Rec));
  finally
    Rec.Free;
  end;
end;

end.
