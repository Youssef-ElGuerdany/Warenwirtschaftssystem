unit Warenfluss.Types;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes;

type
  { Unique Identifier Types }
  TEntityID = Int64;

  { Security & Roles }
  TRoleType = (
    roleAdmin,
    roleManager,
    roleWarehouseClerk,
    roleSalesClerk,
    roleAuditor
  );

  TPermissionType = (
    permUserRead,
    permUserWrite,
    permProductRead,
    permProductWrite,
    permStockRead,
    permStockAdjust,
    permStockTransfer,
    permSalesCreate,
    permSalesConfirm,
    permSalesComplete,
    permSalesCancel,
    permPurchaseCreate,
    permPurchaseApprove,
    permPurchaseReceive,
    permPurchaseCancel,
    permReportRead,
    permAuditRead
  );
  TPermissionSet = set of TPermissionType;

  { Inventory & Stock Movement Types }
  TMovementType = (
    smtInitialStock,     // Initial stock loading
    smtPurchaseReceive,  // Incoming goods from purchase order
    smtSalesDispatch,    // Outgoing goods from sales order
    smtTransferOut,      // Stock transfer debit from source warehouse
    smtTransferIn,       // Stock transfer credit to target warehouse
    smtAdjustmentPlus,   // Inventory correction (found stock)
    smtAdjustmentMinus,  // Inventory correction (damaged / lost stock)
    smtReturnIn,         // Customer return
    smtReturnOut         // Return to supplier
  );

  { Order Statuses }
  TPurchaseOrderStatus = (
    posDraft,
    posApproved,
    posPartiallyReceived,
    posCompleted,
    posCancelled
  );

  TSalesOrderStatus = (
    sosDraft,
    sosConfirmed,
    sosCompleted,
    sosCancelled
  );

  { Product Units }
  TProductUnit = (
    puPiece,        // Stück / Pcs
    puKilogram,     // Kilogramm / kg
    puGram,         // Gramm / g
    puMeter,        // Meter / m
    puLiter,        // Liter / l
    puBox,          // Karton / Box
    puPalette       // Palette
  );

  { Generic Operation Result }
  TOperationResult = record
    Success: Boolean;
    ErrorCode: string;
    Message: string;
    AffectedID: TEntityID;
    class function Ok(const AMsg: string = ''; AAffectedID: TEntityID = 0): TOperationResult; static;
    class function Fail(const AErrorCode, AMsg: string; AAffectedID: TEntityID = 0): TOperationResult; static;
  end;

  { Language / Localization }
  TLanguage = (
    langGerman,
    langEnglish
  );

{ Helper conversion functions }
function RoleTypeToString(ARole: TRoleType): string;
function StringToRoleType(const AStr: string): TRoleType;

function MovementTypeToString(AType: TMovementType): string;
function StringToMovementType(const AStr: string): TMovementType;

function PurchaseStatusToString(AStatus: TPurchaseOrderStatus): string;
function StringToPurchaseStatus(const AStr: string): TPurchaseOrderStatus;

function SalesStatusToString(AStatus: TSalesOrderStatus): string;
function StringToSalesStatus(const AStr: string): TSalesOrderStatus;

function ProductUnitToString(AUnit: TProductUnit): string;
function StringToProductUnit(const AStr: string): TProductUnit;

implementation

{ TOperationResult }

class function TOperationResult.Ok(const AMsg: string; AAffectedID: TEntityID): TOperationResult;
begin
  Result.Success := True;
  Result.ErrorCode := '';
  Result.Message := AMsg;
  Result.AffectedID := AAffectedID;
end;

class function TOperationResult.Fail(const AErrorCode, AMsg: string; AAffectedID: TEntityID): TOperationResult;
begin
  Result.Success := False;
  Result.ErrorCode := AErrorCode;
  Result.Message := AMsg;
  Result.AffectedID := AAffectedID;
end;

{ Helper conversion functions }

function RoleTypeToString(ARole: TRoleType): string;
begin
  case ARole of
    roleAdmin:          Result := 'Admin';
    roleManager:        Result := 'Manager';
    roleWarehouseClerk: Result := 'WarehouseClerk';
    roleSalesClerk:     Result := 'SalesClerk';
    roleAuditor:        Result := 'Auditor';
  else
    Result := 'WarehouseClerk';
  end;
end;

function StringToRoleType(const AStr: string): TRoleType;
var
  S: string;
begin
  S := UpperCase(Trim(AStr));
  if S = 'ADMIN' then Result := roleAdmin
  else if S = 'MANAGER' then Result := roleManager
  else if (S = 'WAREHOUSECLERK') or (S = 'WAREHOUSE') then Result := roleWarehouseClerk
  else if (S = 'SALESCLERK') or (S = 'SALES') then Result := roleSalesClerk
  else if S = 'AUDITOR' then Result := roleAuditor
  else Result := roleWarehouseClerk;
end;

function MovementTypeToString(AType: TMovementType): string;
begin
  case AType of
    smtInitialStock:    Result := 'InitialStock';
    smtPurchaseReceive: Result := 'PurchaseReceive';
    smtSalesDispatch:   Result := 'SalesDispatch';
    smtTransferOut:     Result := 'TransferOut';
    smtTransferIn:      Result := 'TransferIn';
    smtAdjustmentPlus:  Result := 'AdjustmentPlus';
    smtAdjustmentMinus: Result := 'AdjustmentMinus';
    smtReturnIn:        Result := 'ReturnIn';
    smtReturnOut:       Result := 'ReturnOut';
  else
    Result := 'AdjustmentPlus';
  end;
end;

function StringToMovementType(const AStr: string): TMovementType;
var
  S: string;
begin
  S := UpperCase(Trim(AStr));
  if S = 'INITIALSTOCK' then Result := smtInitialStock
  else if S = 'PURCHASERECEIVE' then Result := smtPurchaseReceive
  else if S = 'SALESDISPATCH' then Result := smtSalesDispatch
  else if S = 'TRANSFEROUT' then Result := smtTransferOut
  else if S = 'TRANSFERIN' then Result := smtTransferIn
  else if S = 'ADJUSTMENTPLUS' then Result := smtAdjustmentPlus
  else if S = 'ADJUSTMENTMINUS' then Result := smtAdjustmentMinus
  else if S = 'RETURNIN' then Result := smtReturnIn
  else if S = 'RETURNOUT' then Result := smtReturnOut
  else Result := smtAdjustmentPlus;
end;

function PurchaseStatusToString(AStatus: TPurchaseOrderStatus): string;
begin
  case AStatus of
    posDraft:             Result := 'Draft';
    posApproved:          Result := 'Approved';
    posPartiallyReceived: Result := 'PartiallyReceived';
    posCompleted:         Result := 'Completed';
    posCancelled:         Result := 'Cancelled';
  else
    Result := 'Draft';
  end;
end;

function StringToPurchaseStatus(const AStr: string): TPurchaseOrderStatus;
var
  S: string;
begin
  S := UpperCase(Trim(AStr));
  if S = 'DRAFT' then Result := posDraft
  else if S = 'APPROVED' then Result := posApproved
  else if S = 'PARTIALLYRECEIVED' then Result := posPartiallyReceived
  else if S = 'COMPLETED' then Result := posCompleted
  else if S = 'CANCELLED' then Result := posCancelled
  else Result := posDraft;
end;

function SalesStatusToString(AStatus: TSalesOrderStatus): string;
begin
  case AStatus of
    sosDraft:     Result := 'Draft';
    sosConfirmed: Result := 'Confirmed';
    sosCompleted: Result := 'Completed';
    sosCancelled: Result := 'Cancelled';
  else
    Result := 'Draft';
  end;
end;

function StringToSalesStatus(const AStr: string): TSalesOrderStatus;
var
  S: string;
begin
  S := UpperCase(Trim(AStr));
  if S = 'DRAFT' then Result := sosDraft
  else if S = 'CONFIRMED' then Result := sosConfirmed
  else if S = 'COMPLETED' then Result := sosCompleted
  else if S = 'CANCELLED' then Result := sosCancelled
  else Result := sosDraft;
end;

function ProductUnitToString(AUnit: TProductUnit): string;
begin
  case AUnit of
    puPiece:    Result := 'PCS';
    puKilogram: Result := 'KG';
    puGram:     Result := 'G';
    puMeter:    Result := 'M';
    puLiter:    Result := 'L';
    puBox:      Result := 'BOX';
    puPalette:  Result := 'PAL';
  else
    Result := 'PCS';
  end;
end;

function StringToProductUnit(const AStr: string): TProductUnit;
var
  S: string;
begin
  S := UpperCase(Trim(AStr));
  if (S = 'PCS') or (S = 'STK') or (S = 'PIECE') then Result := puPiece
  else if (S = 'KG') or (S = 'KILOGRAM') then Result := puKilogram
  else if (S = 'G') or (S = 'GRAM') then Result := puGram
  else if (S = 'M') or (S = 'METER') then Result := puMeter
  else if (S = 'L') or (S = 'LITER') then Result := puLiter
  else if (S = 'BOX') or (S = 'KTN') or (S = 'KARTON') then Result := puBox
  else if (S = 'PAL') or (S = 'PALETTE') then Result := puPalette
  else Result := puPiece;
end;

end.
