unit Warenfluss.DTOs.Product;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TProductDTO = record
    ID: TEntityID;
    SKU: string;
    Barcode: string;
    Name: string;
    Description: string;
    CategoryID: TEntityID;
    CategoryName: string;
    CostPrice: Currency;
    UnitPrice: Currency;
    CurrentStockTotal: Double;
    MinStockLevel: Double;
    MaxStockLevel: Double;
    UnitType: TProductUnit;
    UnitName: string;
    IsActive: Boolean;
    IsLowStock: Boolean;
  end;

  TProductCreateDTO = record
    SKU: string;
    Barcode: string;
    Name: string;
    Description: string;
    CategoryID: TEntityID;
    CostPrice: Currency;
    UnitPrice: Currency;
    MinStockLevel: Double;
    MaxStockLevel: Double;
    UnitType: TProductUnit;
  end;

  TProductUpdateDTO = record
    ID: TEntityID;
    SKU: string;
    Barcode: string;
    Name: string;
    Description: string;
    CategoryID: TEntityID;
    CostPrice: Currency;
    UnitPrice: Currency;
    MinStockLevel: Double;
    MaxStockLevel: Double;
    UnitType: TProductUnit;
    IsActive: Boolean;
  end;

  TCategoryDTO = record
    ID: TEntityID;
    Code: string;
    Name: string;
    Description: string;
    IsActive: Boolean;
  end;

  TSupplierDTO = record
    ID: TEntityID;
    Code: string;
    CompanyName: string;
    ContactPerson: string;
    Email: string;
    Phone: string;
    Address: string;
    City: string;
    PostalCode: string;
    Country: string;
    IsActive: Boolean;
  end;

  TCustomerDTO = record
    ID: TEntityID;
    Code: string;
    CompanyName: string;
    ContactPerson: string;
    Email: string;
    Phone: string;
    Address: string;
    City: string;
    PostalCode: string;
    Country: string;
    CreditLimit: Currency;
    OutstandingBalance: Currency;
    IsActive: Boolean;
  end;

  TWarehouseDTO = record
    ID: TEntityID;
    Code: string;
    Name: string;
    Location: string;
    IsActive: Boolean;
  end;

implementation

end.
