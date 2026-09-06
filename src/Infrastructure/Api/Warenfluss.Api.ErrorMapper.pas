unit Warenfluss.Api.ErrorMapper;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  mormot.core.base,
  mormot.core.unicode,
  mormot.core.text,
  Warenfluss.Exceptions;

type
  TApiErrorResponse = record
    Success: Boolean;
    StatusCode: Integer;
    ErrorCode: string;
    Message: string;
    function ToJson: RawUtf8;
  end;

  TApiErrorMapper = class
  public
    class function MapException(E: Exception): TApiErrorResponse;
  end;

implementation

{ TApiErrorResponse }

function TApiErrorResponse.ToJson: RawUtf8;
begin
  Result := FormatUtf8(
    '{"success":false,"statusCode":%,"errorCode":"%","message":"%"}',
    [StatusCode, StringToUtf8(ErrorCode), StringToUtf8(Message)]
  );
end;

{ TApiErrorMapper }

class function TApiErrorMapper.MapException(E: Exception): TApiErrorResponse;
begin
  Result.Success := False;
  if E is EEntityNotFoundException then
  begin
    Result.StatusCode := 404;
    Result.ErrorCode := EEntityNotFoundException(E).ErrorCode;
    Result.Message := E.Message;
  end
  else if E is EValidationException then
  begin
    Result.StatusCode := 422; // Unprocessable Entity
    Result.ErrorCode := EValidationException(E).ErrorCode;
    Result.Message := E.Message;
  end
  else if E is EInsufficientStockException then
  begin
    Result.StatusCode := 409; // Conflict / Insufficient stock
    Result.ErrorCode := EInsufficientStockException(E).ErrorCode;
    Result.Message := E.Message;
  end
  else if E is EInvalidOrderStatusException then
  begin
    Result.StatusCode := 400; // Bad Request
    Result.ErrorCode := EInvalidOrderStatusException(E).ErrorCode;
    Result.Message := E.Message;
  end
  else if E is EUnauthorizedException then
  begin
    Result.StatusCode := 401; // Unauthorized
    Result.ErrorCode := EUnauthorizedException(E).ErrorCode;
    Result.Message := E.Message;
  end
  else if E is EConflictException then
  begin
    Result.StatusCode := 409; // Conflict
    Result.ErrorCode := EConflictException(E).ErrorCode;
    Result.Message := E.Message;
  end
  else
  begin
    Result.StatusCode := 500; // Internal Server Error
    Result.ErrorCode := 'INTERNAL_SERVER_ERROR';
    Result.Message := E.Message;
  end;
end;

end.
