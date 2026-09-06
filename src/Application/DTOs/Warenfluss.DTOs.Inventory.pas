unit Warenfluss.DTOs.Inventory;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, Warenfluss.Types;

type
  TStockItemDTO = record
    ID: TEntityID;
    ProductID: TEntityID;
    ProductSKU: string;
    ProductName: string;
    WarehouseID: TEntityID;
    WarehouseCode: string;
    WarehouseName: string;
    Quantity: Double;
    ReservedQuantity: Double;
    AvailableQuantity: Double;
    UnitCost: Currency;
    TotalValue: Currency;
  end;

  TStockMovementDTO = record
    ID: TEntityID;
    MovementType: TMovementType;
    MovementTypeName: string;
    ProductID: TEntityID;
    ProductSKU: string;
    ProductName: string;
    WarehouseID: TEntityID;
    WarehouseName: string;
    TargetWarehouseID: TEntityID;
    TargetWarehouseName: string;
    Quantity: Double;
    ReferenceType: string;
    ReferenceID: TEntityID;
    UnitCost: Currency;
    Reason: string;
    UserID: TEntityID;
    Username: string;
    Timestamp: TDateTime;
  end;

  TStockAdjustmentDTO = record
    ProductID: TEntityID;
    WarehouseID: TEntityID;
    AdjustmentQuantity: Double; // Positive or negative delta
    Reason: string;
  end;

  TStockTransferDTO = record
    ProductID: TEntityID;
    SourceWarehouseID: TEntityID;
    TargetWarehouseID: TEntityID;
    Quantity: Double;
    Reason: string;
  end;

implementation

end.
