program Warenfluss.Tests;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Warenfluss.Types in '..\src\Common\Warenfluss.Types.pas',
  Warenfluss.Exceptions in '..\src\Common\Warenfluss.Exceptions.pas',
  Warenfluss.Localization in '..\src\Common\Warenfluss.Localization.pas',
  Warenfluss.Security in '..\src\Common\Warenfluss.Security.pas',
  Warenfluss.Events in '..\src\Common\Warenfluss.Events.pas',
  Warenfluss.Domain.User in '..\src\Domain\Entities\Warenfluss.Domain.User.pas',
  Warenfluss.Domain.Category in '..\src\Domain\Entities\Warenfluss.Domain.Category.pas',
  Warenfluss.Domain.Supplier in '..\src\Domain\Entities\Warenfluss.Domain.Supplier.pas',
  Warenfluss.Domain.Customer in '..\src\Domain\Entities\Warenfluss.Domain.Customer.pas',
  Warenfluss.Domain.Warehouse in '..\src\Domain\Entities\Warenfluss.Domain.Warehouse.pas',
  Warenfluss.Domain.Product in '..\src\Domain\Entities\Warenfluss.Domain.Product.pas',
  Warenfluss.Domain.StockMovement in '..\src\Domain\Entities\Warenfluss.Domain.StockMovement.pas',
  Warenfluss.Domain.PurchaseOrder in '..\src\Domain\Entities\Warenfluss.Domain.PurchaseOrder.pas',
  Warenfluss.Domain.SalesOrder in '..\src\Domain\Entities\Warenfluss.Domain.SalesOrder.pas',
  Warenfluss.Domain.AuditLog in '..\src\Domain\Entities\Warenfluss.Domain.AuditLog.pas',
  Warenfluss.Domain.ProductValidator in '..\src\Domain\Validation\Warenfluss.Domain.ProductValidator.pas',
  Warenfluss.Domain.OrderValidator in '..\src\Domain\Validation\Warenfluss.Domain.OrderValidator.pas',
  Warenfluss.Domain.StockValidator in '..\src\Domain\Validation\Warenfluss.Domain.StockValidator.pas',
  Warenfluss.DTOs.Auth in '..\src\Application\DTOs\Warenfluss.DTOs.Auth.pas',
  Warenfluss.DTOs.Product in '..\src\Application\DTOs\Warenfluss.DTOs.Product.pas',
  Warenfluss.DTOs.Inventory in '..\src\Application\DTOs\Warenfluss.DTOs.Inventory.pas',
  Warenfluss.DTOs.Order in '..\src\Application\DTOs\Warenfluss.DTOs.Order.pas',
  Warenfluss.DTOs.Report in '..\src\Application\DTOs\Warenfluss.DTOs.Report.pas',
  Warenfluss.Interfaces.Repositories in '..\src\Application\Interfaces\Warenfluss.Interfaces.Repositories.pas',
  Warenfluss.Interfaces.Services in '..\src\Application\Interfaces\Warenfluss.Interfaces.Services.pas',
  Warenfluss.Services.Authentication in '..\src\Application\Services\Warenfluss.Services.Authentication.pas',
  Warenfluss.Services.User in '..\src\Application\Services\Warenfluss.Services.User.pas',
  Warenfluss.Services.Product in '..\src\Application\Services\Warenfluss.Services.Product.pas',
  Warenfluss.Services.Category in '..\src\Application\Services\Warenfluss.Services.Category.pas',
  Warenfluss.Services.Supplier in '..\src\Application\Services\Warenfluss.Services.Supplier.pas',
  Warenfluss.Services.Customer in '..\src\Application\Services\Warenfluss.Services.Customer.pas',
  Warenfluss.Services.Warehouse in '..\src\Application\Services\Warenfluss.Services.Warehouse.pas',
  Warenfluss.Services.Inventory in '..\src\Application\Services\Warenfluss.Services.Inventory.pas',
  Warenfluss.Services.StockTransfer in '..\src\Application\Services\Warenfluss.Services.StockTransfer.pas',
  Warenfluss.Services.PurchaseOrder in '..\src\Application\Services\Warenfluss.Services.PurchaseOrder.pas',
  Warenfluss.Services.SalesOrder in '..\src\Application\Services\Warenfluss.Services.SalesOrder.pas',
  Warenfluss.Services.Report in '..\src\Application\Services\Warenfluss.Services.Report.pas',
  Warenfluss.Services.Audit in '..\src\Application\Services\Warenfluss.Services.Audit.pas',
  Warenfluss.Repositories.Mock in '..\src\Infrastructure\Repositories\Warenfluss.Repositories.Mock.pas',
  Warenfluss.ViewModel.Base in '..\src\Presentation\ViewModels\Warenfluss.ViewModel.Base.pas',
  Warenfluss.ViewModel.Inventory in '..\src\Presentation\ViewModels\Warenfluss.ViewModel.Inventory.pas',
  Test.AuthenticationService in 'Test.AuthenticationService.pas',
  Test.InventoryService in 'Test.InventoryService.pas',
  Test.InventoryViewModel in 'Test.InventoryViewModel.pas',
  Test.StockTransferService in 'Test.StockTransferService.pas',
  Test.SalesOrderService in 'Test.SalesOrderService.pas';

procedure RunSuite;
var
  AuthTests: TTestAuthenticationService;
  InvTests: TTestInventoryService;
  InvVMTests: TTestInventoryViewModel;
  XferTests: TTestStockTransferService;
  SalesTests: TTestSalesOrderService;
  Passed: Integer;
  Failed: Integer;

  procedure RunTest(const AName: string; AProc: TProc);
  begin
    Write(Format('  - %-48s ', [AName]));
    try
      AProc();
      Writeln('[PASS]');
      Inc(Passed);
    except
      on E: Exception do
      begin
        Writeln('[FAIL]: ' + E.Message);
        Inc(Failed);
      end;
    end;
  end;

begin
  Passed := 0;
  Failed := 0;

  Writeln('================================================================');
  Writeln('  WARENFLUSS - ENTERPRISE AUTOMATED UNIT TEST SUITE');
  Writeln('================================================================');
  Writeln('');

  // 1. Auth Service Tests
  Writeln('[FIXTURE] TTestAuthenticationService');
  AuthTests := TTestAuthenticationService.Create;
  try
    AuthTests.SetUp;
    RunTest('TestSuccessfulLogin', procedure begin AuthTests.TestSuccessfulLogin; end);
    RunTest('TestInvalidPassword', procedure begin AuthTests.TestInvalidPassword; end);
    RunTest('TestUserNotFound', procedure begin AuthTests.TestUserNotFound; end);
    RunTest('TestInactiveUser', procedure begin AuthTests.TestInactiveUser; end);
    RunTest('TestValidateToken', procedure begin AuthTests.TestValidateToken; end);
    RunTest('TestSeededDefaultUsers', procedure begin AuthTests.TestSeededDefaultUsers; end);
  finally
    AuthTests.Free;
  end;
  Writeln('');

  // 2. Inventory Service Tests
  Writeln('[FIXTURE] TTestInventoryService');
  InvTests := TTestInventoryService.Create;
  try
    InvTests.SetUp;
    RunTest('TestPositiveAdjustment', procedure begin InvTests.TestPositiveAdjustment; end);
    InvTests.SetUp;
    RunTest('TestNegativeAdjustment', procedure begin InvTests.TestNegativeAdjustment; end);
    InvTests.SetUp;
    RunTest('TestPreventNegativeStock', procedure begin InvTests.TestPreventNegativeStock; end);
    InvTests.SetUp;
    RunTest('TestStockMovementRecorded', procedure begin InvTests.TestStockMovementRecorded; end);
  finally
    InvTests.Free;
  end;
  Writeln('');

  // 3. Inventory ViewModel Tests
  Writeln('[FIXTURE] TTestInventoryViewModel');
  InvVMTests := TTestInventoryViewModel.Create;
  try
    InvVMTests.SetUp;
    RunTest('TestLoadStockPopulatesItems', procedure begin InvVMTests.TestLoadStockPopulatesItems; end);
    InvVMTests.SetUp;
    RunTest('TestSearchFiltering', procedure begin InvVMTests.TestSearchFiltering; end);
    InvVMTests.SetUp;
    RunTest('TestWarehouseFiltering', procedure begin InvVMTests.TestWarehouseFiltering; end);
    InvVMTests.SetUp;
    RunTest('TestCalculations', procedure begin InvVMTests.TestCalculations; end);
    InvVMTests.SetUp;
    RunTest('TestAdjustStockThroughViewModel', procedure begin InvVMTests.TestAdjustStockThroughViewModel; end);
    InvVMTests.SetUp;
    RunTest('TestTransferStockThroughViewModel', procedure begin InvVMTests.TestTransferStockThroughViewModel; end);
  finally
    InvVMTests.Free;
  end;
  Writeln('');

  // 3. Stock Transfer Service Tests
  Writeln('[FIXTURE] TTestStockTransferService');
  XferTests := TTestStockTransferService.Create;
  try
    XferTests.SetUp;
    RunTest('TestSuccessfulTransfer', procedure begin XferTests.TestSuccessfulTransfer; end);
    XferTests.SetUp;
    RunTest('TestTransferInsufficientStock', procedure begin XferTests.TestTransferInsufficientStock; end);
    XferTests.SetUp;
    RunTest('TestTransferSameWarehouseFails', procedure begin XferTests.TestTransferSameWarehouseFails; end);
  finally
    XferTests.Free;
  end;
  Writeln('');

  // 4. Sales Order Service Tests
  Writeln('[FIXTURE] TTestSalesOrderService');
  SalesTests := TTestSalesOrderService.Create;
  try
    SalesTests.SetUp;
    RunTest('TestCreateSalesOrderCalculations', procedure begin SalesTests.TestCreateSalesOrderCalculations; end);
    SalesTests.SetUp;
    RunTest('TestConfirmAndCompleteOrderWorkflow', procedure begin SalesTests.TestConfirmAndCompleteOrderWorkflow; end);
    SalesTests.SetUp;
    RunTest('TestCompleteOrderInsufficientStockFails', procedure begin SalesTests.TestCompleteOrderInsufficientStockFails; end);
  finally
    SalesTests.Free;
  end;
  Writeln('');

  Writeln('================================================================');
  Writeln(Format('  SUMMARY: %d passed, %d failed across %d assertions.', [Passed, Failed, Passed + Failed]));
  Writeln('================================================================');

  if Failed > 0 then
    ExitCode := 1
  else
    ExitCode := 0;
end;

begin
  try
    RunSuite;
  except
    on E: Exception do
    begin
      Writeln('FATAL ERROR: ', E.ClassName, ': ', E.Message);
      ExitCode := 2;
    end;
  end;
end.
