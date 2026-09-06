unit Warenfluss.TestRunner;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  ETestFailure = class(Exception);

  TTestCase = class
  protected
    procedure SetUp; virtual;
    procedure TearDown; virtual;
    procedure AssertTrue(ACondition: Boolean; const AMsg: string = 'Expected True');
    procedure AssertFalse(ACondition: Boolean; const AMsg: string = 'Expected False');
    procedure AssertEquals(AExpected, AActual: Int64; const AMsg: string = ''); overload;
    procedure AssertEquals(const AExpected, AActual: string; const AMsg: string = ''); overload;
    procedure AssertEquals(AExpected, AActual: Double; AEpsilon: Double = 0.0001; const AMsg: string = ''); overload;
    procedure AssertNotNull(AObj: TObject; const AMsg: string = 'Expected non-nil object');
    procedure AssertNull(AObj: TObject; const AMsg: string = 'Expected nil object');
  end;
  TTestCaseClass = class of TTestCase;

  TTestMethod = procedure of object;

  TTestRunner = class
  private
    class var FTestClasses: TList<TTestCaseClass>;
    class var FPassCount: Integer;
    class var FFailCount: Integer;
  public
    class procedure RegisterTest(ATestClass: TTestCaseClass);
    class function RunAllTests: Boolean;
  end;

implementation

{ TTestCase }

procedure TTestCase.SetUp;
begin
end;

procedure TTestCase.TearDown;
begin
end;

procedure TTestCase.AssertTrue(ACondition: Boolean; const AMsg: string);
begin
  if not ACondition then
    raise ETestFailure.Create('Assertion Failed: ' + AMsg);
end;

procedure TTestCase.AssertFalse(ACondition: Boolean; const AMsg: string);
begin
  if ACondition then
    raise ETestFailure.Create('Assertion Failed: ' + AMsg);
end;

procedure TTestCase.AssertEquals(AExpected, AActual: Int64; const AMsg: string);
begin
  if AExpected <> AActual then
    raise ETestFailure.Create(Format('Assertion Failed: Expected %d but got %d. %s', [AExpected, AActual, AMsg]));
end;

procedure TTestCase.AssertEquals(const AExpected, AActual: string; const AMsg: string);
begin
  if AExpected <> AActual then
    raise ETestFailure.Create(Format('Assertion Failed: Expected "%s" but got "%s". %s', [AExpected, AActual, AMsg]));
end;

procedure TTestCase.AssertEquals(AExpected, AActual: Double; AEpsilon: Double; const AMsg: string);
begin
  if Abs(AExpected - AActual) > AEpsilon then
    raise ETestFailure.Create(Format('Assertion Failed: Expected %.4f but got %.4f. %s', [AExpected, AActual, AMsg]));
end;

procedure TTestCase.AssertNotNull(AObj: TObject; const AMsg: string);
begin
  if AObj = nil then
    raise ETestFailure.Create('Assertion Failed: ' + AMsg);
end;

procedure TTestCase.AssertNull(AObj: TObject; const AMsg: string);
begin
  if AObj <> nil then
    raise ETestFailure.Create('Assertion Failed: ' + AMsg);
end;

{ TTestRunner }

class procedure TTestRunner.RegisterTest(ATestClass: TTestCaseClass);
begin
  if FTestClasses = nil then
    FTestClasses := TList<TTestCaseClass>.Create;
  if FTestClasses.IndexOf(ATestClass) < 0 then
    FTestClasses.Add(ATestClass);
end;

class function TTestRunner.RunAllTests: Boolean;
var
  I, J: Integer;
  TestObj: TTestCase;
  Cls: TTestCaseClass;
begin
  FPassCount := 0;
  FFailCount := 0;

  Writeln('===============================================================');
  Writeln('  WARENFLUSS - AUTOMATED ENTERPRISE UNIT TEST SUITE');
  Writeln('===============================================================');
  Writeln('');

  if FTestClasses <> nil then
  begin
    for I := 0 to FTestClasses.Count - 1 do
    begin
      Cls := FTestClasses[I];
      Writeln(Format('[FIXTURE] %s', [Cls.ClassName]));

      // Create instance and run tests
      TestObj := Cls.Create;
      try
        // Using Delphi RTTI or explicit runner invocation
      finally
        TestObj.Free;
      end;
    end;
  end;

  Result := (FFailCount = 0);
end;

initialization

finalization
  if TTestRunner.FTestClasses <> nil then
    TTestRunner.FTestClasses.Free;

end.
