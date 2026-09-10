unit Warenfluss.ORM.DataSeeder;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  Warenfluss.Types,
  Warenfluss.Security,
  Warenfluss.Interfaces.Repositories;

type
  TDataSeeder = class
  public
    class procedure SeedDefaultData(
      AUserRepo: IUserRepository;
      ACategoryRepo: ICategoryRepository;
      ASupplierRepo: ISupplierRepository;
      ACustomerRepo: ICustomerRepository;
      AWarehouseRepo: IWarehouseRepository;
      AProductRepo: IProductRepository;
      AStockRepo: IStockRepository
    );
  end;

implementation

uses
  Warenfluss.Domain.User,
  Warenfluss.Domain.Category,
  Warenfluss.Domain.Supplier,
  Warenfluss.Domain.Customer,
  Warenfluss.Domain.Warehouse,
  Warenfluss.Domain.Product,
  Warenfluss.Domain.StockMovement;

class procedure TDataSeeder.SeedDefaultData(
  AUserRepo: IUserRepository;
  ACategoryRepo: ICategoryRepository;
  ASupplierRepo: ISupplierRepository;
  ACustomerRepo: ICustomerRepository;
  AWarehouseRepo: IWarehouseRepository;
  AProductRepo: IProductRepository;
  AStockRepo: IStockRepository);
var
  AdminUser: TUser;
  Salt, Hash: string;
  CatElectronics, CatTools, CatPackaging: TCategory;
  CatElecID, CatToolsID, CatPackID: TEntityID;
  WhMain, WhSecondary: TWarehouse;
  WhMainID, WhSecID: TEntityID;
  SuppTech, SuppParts: TSupplier;
  CustIndustrial, CustRetail: TCustomer;
  P1, P2, P3, P4: TProduct;
  P1ID, P2ID, P3ID, P4ID: TEntityID;
  StockItem: TStockItem;
  Movement: TStockMovement;
begin
  CatElecID := 0;
  CatToolsID := 0;
  CatPackID := 0;
  WhMainID := 0;
  WhSecID := 0;
  P1ID := 0;
  P2ID := 0;
  P3ID := 0;
  P4ID := 0;

  // 1. Seed Admin User
  if (AUserRepo <> nil) and (AUserRepo.GetByUsername('admin') = nil) then
  begin
    Salt := TSecurityHelper.GenerateSalt(16);
    Hash := TSecurityHelper.HashPassword('admin123', Salt);

    AdminUser := TUser.Create;
    AdminUser.Username := 'admin';
    AdminUser.FullName := 'System Administrator';
    AdminUser.Email := 'admin@warenfluss.enterprise';
    AdminUser.Role := roleAdmin;
    AdminUser.PasswordSalt := Salt;
    AdminUser.PasswordHash := Hash;
    AdminUser.IsActive := True;
    AdminUser.CreatedAt := Now;
    AUserRepo.Save(AdminUser);

    // Additional standard clerk user
    Salt := TSecurityHelper.GenerateSalt(16);
    Hash := TSecurityHelper.HashPassword('user123', Salt);
    AdminUser := TUser.Create;
    AdminUser.Username := 'clerk';
    AdminUser.FullName := 'Max Mustermann';
    AdminUser.Email := 'm.mustermann@warenfluss.enterprise';
    AdminUser.Role := roleWarehouseClerk;
    AdminUser.PasswordSalt := Salt;
    AdminUser.PasswordHash := Hash;
    AdminUser.IsActive := True;
    AdminUser.CreatedAt := Now;
    AUserRepo.Save(AdminUser);
  end;

  // 2. Seed Warehouses
  if AWarehouseRepo <> nil then
  begin
    WhMain := TWarehouse.Create;
    WhMain.Code := 'WH-CENTRAL';
    WhMain.Name := 'Hauptlager Frankfurt';
    WhMain.Location := 'Halle 1A, Frankfurt am Main';
    WhMain.IsActive := True;
    WhMainID := AWarehouseRepo.Save(WhMain);

    WhSecondary := TWarehouse.Create;
    WhSecondary.Code := 'WH-NORTH';
    WhSecondary.Name := 'Regionallager Hamburg';
    WhSecondary.Location := 'Hafenstr. 42, Hamburg';
    WhSecondary.IsActive := True;
    WhSecID := AWarehouseRepo.Save(WhSecondary);
  end;

  // 3. Seed Categories
  if ACategoryRepo <> nil then
  begin
    CatElectronics := TCategory.Create;
    CatElectronics.Code := 'CAT-ELEC';
    CatElectronics.Name := 'Elektronik & Sensoren';
    CatElectronics.Description := 'Industriesensoren, Steuerungen und Komponenten';
    CatElecID := ACategoryRepo.Save(CatElectronics);

    CatTools := TCategory.Create;
    CatTools.Code := 'CAT-TOOL';
    CatTools.Name := 'Werkzeuge & Montage';
    CatTools.Description := 'Präzisionswerkzeuge und Montagezubehör';
    CatToolsID := ACategoryRepo.Save(CatTools);

    CatPackaging := TCategory.Create;
    CatPackaging.Code := 'CAT-PACK';
    CatPackaging.Name := 'Verpackung & Logistik';
    CatPackaging.Description := 'Kartons, Paletten und Polstermaterial';
    CatPackID := ACategoryRepo.Save(CatPackaging);
  end;

  // 4. Seed Suppliers
  if ASupplierRepo <> nil then
  begin
    SuppTech := TSupplier.Create;
    SuppTech.Code := 'SUPP-001';
    SuppTech.CompanyName := 'Siemens AG Industriebedarf';
    SuppTech.ContactPerson := 'Klaus Richter';
    SuppTech.Email := 'orders@siemens-industry.example';
    SuppTech.Phone := '+49 89 63600';
    SuppTech.Address := 'Werner-von-Siemens-Str. 1';
    SuppTech.City := 'München';
    SuppTech.PostalCode := '80333';
    ASupplierRepo.Save(SuppTech);

    SuppParts := TSupplier.Create;
    SuppParts.Code := 'SUPP-002';
    SuppParts.CompanyName := 'Bosch Rexroth Automation';
    SuppParts.ContactPerson := 'Sabine Weber';
    SuppParts.Email := 'vertrieb@boschrexroth.example';
    SuppParts.Phone := '+49 711 8110';
    SuppParts.Address := 'Robert-Bosch-Platz 1';
    SuppParts.City := 'Gerlingen';
    SuppParts.PostalCode := '70839';
    ASupplierRepo.Save(SuppParts);
  end;

  // 5. Seed Customers
  if ACustomerRepo <> nil then
  begin
    CustIndustrial := TCustomer.Create;
    CustIndustrial.Code := 'CUST-1001';
    CustIndustrial.CompanyName := 'BMW Group Fertigungswerk';
    CustIndustrial.ContactPerson := 'Thomas Müller';
    CustIndustrial.Email := 'einkauf@bmwgroup.example';
    CustIndustrial.Phone := '+49 89 3820';
    CustIndustrial.Address := 'Petuelring 130';
    CustIndustrial.City := 'München';
    CustIndustrial.PostalCode := '80788';
    CustIndustrial.CreditLimit := 150000;
    ACustomerRepo.Save(CustIndustrial);

    CustRetail := TCustomer.Create;
    CustRetail.Code := 'CUST-1002';
    CustRetail.CompanyName := 'Daimler Truck Parts & Logistics';
    CustRetail.ContactPerson := 'Andrea Schmid';
    CustRetail.Email := 'logistics@daimlertruck.example';
    CustRetail.Phone := '+49 711 170';
    CustRetail.Address := 'Mercedesstraße 120';
    CustRetail.City := 'Stuttgart';
    CustRetail.PostalCode := '70372';
    CustRetail.CreditLimit := 100000;
    ACustomerRepo.Save(CustRetail);
  end;

  // 6. Seed Products & Stock Levels
  if (AProductRepo <> nil) and (AProductRepo.GetBySKU('IND-SENS-400') = nil) then
  begin
    P1 := TProduct.Create;
    P1.SKU := 'IND-SENS-400';
    P1.Barcode := '4012345678901';
    P1.Name := 'Optischer Distanzsensor 400mm';
    P1.Description := 'Präzisions-Lasersensor IP67 für Förderbänder';
    P1.CategoryID := CatElecID;
    P1.CostPrice := 145.50;
    P1.UnitPrice := 289.00;
    P1.CurrentStockTotal := 45;
    P1.MinStockLevel := 10;
    P1.MaxStockLevel := 200;
    P1.UnitType := puPiece;
    P1ID := AProductRepo.Save(P1);

    P2 := TProduct.Create;
    P2.SKU := 'IND-CTRL-PLC2';
    P2.Barcode := '4012345678902';
    P2.Name := 'SPS Steuerungsmodul 24V';
    P2.Description := 'Kompakt-SPS mit Ethernet und 16 digitalen I/Os';
    P2.CategoryID := CatElecID;
    P2.CostPrice := 320.00;
    P2.UnitPrice := 599.00;
    P2.CurrentStockTotal := 18;
    P2.MinStockLevel := 5;
    P2.MaxStockLevel := 50;
    P2.UnitType := puPiece;
    P2ID := AProductRepo.Save(P2);

    P3 := TProduct.Create;
    P3.SKU := 'TOOL-TORQ-PRO';
    P3.Barcode := '4012345678903';
    P3.Name := 'Digitaler Drehmomentschlüssel 10-100 Nm';
    P3.Description := 'Kalibrierter Drehmomentschlüssel mit Bluetooth';
    P3.CategoryID := CatToolsID;
    P3.CostPrice := 85.00;
    P3.UnitPrice := 169.90;
    P3.CurrentStockTotal := 25;
    P3.MinStockLevel := 8;
    P3.MaxStockLevel := 100;
    P3.UnitType := puPiece;
    P3ID := AProductRepo.Save(P3);

    P4 := TProduct.Create;
    P4.SKU := 'PACK-BOX-EU1';
    P4.Barcode := '4012345678904';
    P4.Name := 'Euro-Faltkarton 600x400x400 mm';
    P4.Description := '2-wellige Wellpappe Schwergutkartonage';
    P4.CategoryID := CatPackID;
    P4.CostPrice := 1.80;
    P4.UnitPrice := 4.50;
    P4.CurrentStockTotal := 500;
    P4.MinStockLevel := 100;
    P4.MaxStockLevel := 2000;
    P4.UnitType := puPiece;
    P4ID := AProductRepo.Save(P4);

    // Seed initial stock items & movements
    if AStockRepo <> nil then
    begin
      StockItem := TStockItem.Create;
      StockItem.ProductID := P1ID;
      StockItem.WarehouseID := WhMainID;
      StockItem.Quantity := 35;
      AStockRepo.SaveStockItem(StockItem);

      StockItem := TStockItem.Create;
      StockItem.ProductID := P1ID;
      StockItem.WarehouseID := WhSecID;
      StockItem.Quantity := 10;
      AStockRepo.SaveStockItem(StockItem);

      StockItem := TStockItem.Create;
      StockItem.ProductID := P2ID;
      StockItem.WarehouseID := WhMainID;
      StockItem.Quantity := 18;
      AStockRepo.SaveStockItem(StockItem);

      StockItem := TStockItem.Create;
      StockItem.ProductID := P3ID;
      StockItem.WarehouseID := WhMainID;
      StockItem.Quantity := 25;
      AStockRepo.SaveStockItem(StockItem);

      StockItem := TStockItem.Create;
      StockItem.ProductID := P4ID;
      StockItem.WarehouseID := WhMainID;
      StockItem.Quantity := 500;
      AStockRepo.SaveStockItem(StockItem);

      // Seed movement records (AddStockMovement creates an internal copy)
      Movement := TStockMovement.Create;
      try
        Movement.MovementType := smtInitialStock;
        Movement.ProductID := P1ID;
        Movement.WarehouseID := WhMainID;
        Movement.Quantity := 35;
        Movement.ReferenceType := 'INITIAL_SEED';
        Movement.UnitCost := 145.50;
        Movement.Reason := 'Initial master stock import';
        Movement.UserID := 1;
        Movement.Timestamp := Now;
        AStockRepo.AddStockMovement(Movement);
      finally
        Movement.Free;
      end;
    end;
  end;
end;

end.
