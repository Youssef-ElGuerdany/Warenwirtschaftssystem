unit Warenfluss.Exceptions;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils;

type
  { Base Domain Exception }
  EDomainException = class(Exception)
  private
    FErrorCode: string;
  public
    constructor Create(const AErrorCode, AMessage: string); reintroduce;
    property ErrorCode: string read FErrorCode;
  end;

  { Entity Not Found }
  EEntityNotFoundException = class(EDomainException)
  public
    constructor Create(const AEntityName: string; const AIdentifier: string); reintroduce;
  end;

  { Business Rule Validation Failed }
  EValidationException = class(EDomainException)
  public
    constructor Create(const AMessage: string); reintroduce;
  end;

  { Insufficient Stock }
  EInsufficientStockException = class(EDomainException)
  private
    FProductID: Int64;
    FWarehouseID: Int64;
    FRequestedQuantity: Double;
    FAvailableQuantity: Double;
  public
    constructor Create(AProductID, AWarehouseID: Int64; AReqQty, AAvailQty: Double; const AMessage: string); reintroduce;
    property ProductID: Int64 read FProductID;
    property WarehouseID: Int64 read FWarehouseID;
    property RequestedQuantity: Double read FRequestedQuantity;
    property AvailableQuantity: Double read FAvailableQuantity;
  end;

  { Invalid Order State Transition }
  EInvalidOrderStatusException = class(EDomainException)
  public
    constructor Create(const AMessage: string); reintroduce;
  end;

  { Security / Authorization / Authentication }
  EUnauthorizedException = class(EDomainException)
  public
    constructor Create(const AMessage: string = 'Access denied / Unauthorized'); reintroduce;
  end;

  { Conflict / Duplicate Key / SKU already exists }
  EConflictException = class(EDomainException)
  public
    constructor Create(const AMessage: string); reintroduce;
  end;

  { Concurrency / Stale Data }
  EConcurrencyException = class(EDomainException)
  public
    constructor Create(const AMessage: string = 'Data has been modified by another transaction.'); reintroduce;
  end;

implementation

{ EDomainException }

constructor EDomainException.Create(const AErrorCode, AMessage: string);
begin
  inherited Create(AMessage);
  FErrorCode := AErrorCode;
end;

{ EEntityNotFoundException }

constructor EEntityNotFoundException.Create(const AEntityName, AIdentifier: string);
begin
  inherited Create('ENTITY_NOT_FOUND', Format('%s not found with identifier "%s"', [AEntityName, AIdentifier]));
end;

{ EValidationException }

constructor EValidationException.Create(const AMessage: string);
begin
  inherited Create('VALIDATION_ERROR', AMessage);
end;

{ EInsufficientStockException }

constructor EInsufficientStockException.Create(AProductID, AWarehouseID: Int64; AReqQty, AAvailQty: Double;
  const AMessage: string);
begin
  inherited Create('INSUFFICIENT_STOCK', AMessage);
  FProductID := AProductID;
  FWarehouseID := AWarehouseID;
  FRequestedQuantity := AReqQty;
  FAvailableQuantity := AAvailQty;
end;

{ EInvalidOrderStatusException }

constructor EInvalidOrderStatusException.Create(const AMessage: string);
begin
  inherited Create('INVALID_ORDER_STATUS', AMessage);
end;

{ EUnauthorizedException }

constructor EUnauthorizedException.Create(const AMessage: string);
begin
  inherited Create('UNAUTHORIZED', AMessage);
end;

{ EConflictException }

constructor EConflictException.Create(const AMessage: string);
begin
  inherited Create('CONFLICT_ERROR', AMessage);
end;

{ EConcurrencyException }

constructor EConcurrencyException.Create(const AMessage: string);
begin
  inherited Create('CONCURRENCY_ERROR', AMessage);
end;

end.
