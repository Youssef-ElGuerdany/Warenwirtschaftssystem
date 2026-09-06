unit Warenfluss.Events;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Warenfluss.Types;

type
  { Base Domain Event }
  TDomainEvent = class
  private
    FEventTimestamp: TDateTime;
    FEventName: string;
  public
    constructor Create(const AName: string); virtual;
    property EventTimestamp: TDateTime read FEventTimestamp;
    property EventName: string read FEventName;
  end;

  { Specific Business Events }
  TStockAdjustedEvent = class(TDomainEvent)
  public
    ProductID: TEntityID;
    WarehouseID: TEntityID;
    PreviousQty: Double;
    NewQty: Double;
    DeltaQty: Double;
    Reason: string;
    UserID: TEntityID;
    constructor Create(AProductID, AWarehouseID: TEntityID; APrev, ANew, ADelta: Double; const AReason: string; AUserID: TEntityID); reintroduce;
  end;

  TStockTransferredEvent = class(TDomainEvent)
  public
    ProductID: TEntityID;
    SourceWarehouseID: TEntityID;
    TargetWarehouseID: TEntityID;
    Quantity: Double;
    UserID: TEntityID;
    constructor Create(AProductID, ASrcWH, ATgtWH: TEntityID; AQty: Double; AUserID: TEntityID); reintroduce;
  end;

  TSalesOrderCompletedEvent = class(TDomainEvent)
  public
    SalesOrderID: TEntityID;
    OrderNumber: string;
    CustomerID: TEntityID;
    WarehouseID: TEntityID;
    TotalAmount: Currency;
    UserID: TEntityID;
    constructor Create(AOrderID: TEntityID; const AOrderNumber: string; ACustID, AWHID: TEntityID; ATotal: Currency; AUserID: TEntityID); reintroduce;
  end;

  TPurchaseReceivedEvent = class(TDomainEvent)
  public
    PurchaseOrderID: TEntityID;
    OrderNumber: string;
    SupplierID: TEntityID;
    WarehouseID: TEntityID;
    UserID: TEntityID;
    constructor Create(APurchaseOrderID: TEntityID; const AOrderNumber: string; ASuppID, AWHID: TEntityID; AUserID: TEntityID); reintroduce;
  end;

  TUserLoggedInEvent = class(TDomainEvent)
  public
    UserID: TEntityID;
    Username: string;
    ClientIP: string;
    constructor Create(AUserID: TEntityID; const AUsername, AClientIP: string); reintroduce;
  end;

  { Event Handler Callback }
  TDomainEventHandler = procedure(AEvent: TDomainEvent) of object;

  { Domain Event Dispatcher / Bus }
  TDomainEventBus = class
  private
    class var FInstance: TDomainEventBus;
    FHandlers: TList<TDomainEventHandler>;
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance: TDomainEventBus;
    class procedure FreeInstance;

    procedure Subscribe(AHandler: TDomainEventHandler);
    procedure Unsubscribe(AHandler: TDomainEventHandler);
    procedure Publish(AEvent: TDomainEvent);
  end;

implementation

{ TDomainEvent }

constructor TDomainEvent.Create(const AName: string);
begin
  inherited Create;
  FEventTimestamp := Now;
  FEventName := AName;
end;

{ TStockAdjustedEvent }

constructor TStockAdjustedEvent.Create(AProductID, AWarehouseID: TEntityID; APrev, ANew, ADelta: Double;
  const AReason: string; AUserID: TEntityID);
begin
  inherited Create('StockAdjusted');
  ProductID := AProductID;
  WarehouseID := AWarehouseID;
  PreviousQty := APrev;
  NewQty := ANew;
  DeltaQty := ADelta;
  Reason := AReason;
  UserID := AUserID;
end;

{ TStockTransferredEvent }

constructor TStockTransferredEvent.Create(AProductID, ASrcWH, ATgtWH: TEntityID; AQty: Double; AUserID: TEntityID);
begin
  inherited Create('StockTransferred');
  ProductID := AProductID;
  SourceWarehouseID := ASrcWH;
  TargetWarehouseID := ATgtWH;
  Quantity := AQty;
  UserID := AUserID;
end;

{ TSalesOrderCompletedEvent }

constructor TSalesOrderCompletedEvent.Create(AOrderID: TEntityID; const AOrderNumber: string; ACustID, AWHID: TEntityID;
  ATotal: Currency; AUserID: TEntityID);
begin
  inherited Create('SalesOrderCompleted');
  SalesOrderID := AOrderID;
  OrderNumber := AOrderNumber;
  CustomerID := ACustID;
  WarehouseID := AWHID;
  TotalAmount := ATotal;
  UserID := AUserID;
end;

{ TPurchaseReceivedEvent }

constructor TPurchaseReceivedEvent.Create(APurchaseOrderID: TEntityID; const AOrderNumber: string; ASuppID,
  AWHID: TEntityID; AUserID: TEntityID);
begin
  inherited Create('PurchaseReceived');
  PurchaseOrderID := APurchaseOrderID;
  OrderNumber := AOrderNumber;
  SupplierID := ASuppID;
  WarehouseID := AWHID;
  UserID := AUserID;
end;

{ TUserLoggedInEvent }

constructor TUserLoggedInEvent.Create(AUserID: TEntityID; const AUsername, AClientIP: string);
begin
  inherited Create('UserLoggedIn');
  UserID := AUserID;
  Username := AUsername;
  ClientIP := AClientIP;
end;

{ TDomainEventBus }

constructor TDomainEventBus.Create;
begin
  inherited Create;
  FHandlers := TList<TDomainEventHandler>.Create;
end;

destructor TDomainEventBus.Destroy;
begin
  FHandlers.Free;
  inherited Destroy;
end;

class function TDomainEventBus.Instance: TDomainEventBus;
begin
  if FInstance = nil then
    FInstance := TDomainEventBus.Create;
  Result := FInstance;
end;

class procedure TDomainEventBus.FreeInstance;
begin
  FreeAndNil(FInstance);
end;

procedure TDomainEventBus.Subscribe(AHandler: TDomainEventHandler);
begin
  if FHandlers.IndexOf(AHandler) < 0 then
    FHandlers.Add(AHandler);
end;

procedure TDomainEventBus.Unsubscribe(AHandler: TDomainEventHandler);
begin
  FHandlers.Remove(AHandler);
end;

procedure TDomainEventBus.Publish(AEvent: TDomainEvent);
var
  Handler: TDomainEventHandler;
  I: Integer;
begin
  if AEvent = nil then Exit;
  try
    for I := 0 to FHandlers.Count - 1 do
    begin
      Handler := FHandlers[I];
      if Assigned(Handler) then
        Handler(AEvent);
    end;
  finally
    AEvent.Free;
  end;
end;

initialization

finalization
  TDomainEventBus.FreeInstance;

end.
