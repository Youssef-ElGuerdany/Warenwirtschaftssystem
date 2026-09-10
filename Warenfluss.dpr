program Warenfluss;

uses
  System.SysUtils,
  Vcl.Forms,
  Vcl.Controls,
  Warenfluss.Repositories.mORMot in 'src\Infrastructure\Repositories\Warenfluss.Repositories.mORMot.pas',
  Warenfluss.Repositories.Mock in 'src\Infrastructure\Repositories\Warenfluss.Repositories.Mock.pas',
  Warenfluss.DTOs.Auth in 'src\Application\DTOs\Warenfluss.DTOs.Auth.pas',
  Warenfluss.DTOs.Inventory in 'src\Application\DTOs\Warenfluss.DTOs.Inventory.pas',
  Warenfluss.DTOs.Order in 'src\Application\DTOs\Warenfluss.DTOs.Order.pas',
  Warenfluss.DTOs.Product in 'src\Application\DTOs\Warenfluss.DTOs.Product.pas',
  Warenfluss.DTOs.Report in 'src\Application\DTOs\Warenfluss.DTOs.Report.pas',
  Warenfluss.Interfaces.Repositories in 'src\Application\Interfaces\Warenfluss.Interfaces.Repositories.pas',
  Warenfluss.Interfaces.Services in 'src\Application\Interfaces\Warenfluss.Interfaces.Services.pas',
  Warenfluss.Services.Audit in 'src\Application\Services\Warenfluss.Services.Audit.pas',
  Warenfluss.Services.Authentication in 'src\Application\Services\Warenfluss.Services.Authentication.pas',
  Warenfluss.Services.Category in 'src\Application\Services\Warenfluss.Services.Category.pas',
  Warenfluss.Services.Customer in 'src\Application\Services\Warenfluss.Services.Customer.pas',
  Warenfluss.Services.Inventory in 'src\Application\Services\Warenfluss.Services.Inventory.pas',
  Warenfluss.Services.Product in 'src\Application\Services\Warenfluss.Services.Product.pas',
  Warenfluss.Services.PurchaseOrder in 'src\Application\Services\Warenfluss.Services.PurchaseOrder.pas',
  Warenfluss.Services.Report in 'src\Application\Services\Warenfluss.Services.Report.pas',
  Warenfluss.Services.SalesOrder in 'src\Application\Services\Warenfluss.Services.SalesOrder.pas',
  Warenfluss.Services.StockTransfer in 'src\Application\Services\Warenfluss.Services.StockTransfer.pas',
  Warenfluss.Services.Supplier in 'src\Application\Services\Warenfluss.Services.Supplier.pas',
  Warenfluss.Services.User in 'src\Application\Services\Warenfluss.Services.User.pas',
  Warenfluss.Services.Warehouse in 'src\Application\Services\Warenfluss.Services.Warehouse.pas',
  Warenfluss.Events in 'src\Common\Warenfluss.Events.pas',
  Warenfluss.Exceptions in 'src\Common\Warenfluss.Exceptions.pas',
  Warenfluss.Localization in 'src\Common\Warenfluss.Localization.pas',
  Warenfluss.Security in 'src\Common\Warenfluss.Security.pas',
  Warenfluss.Types in 'src\Common\Warenfluss.Types.pas',
  Warenfluss.Domain.AuditLog in 'src\Domain\Entities\Warenfluss.Domain.AuditLog.pas',
  Warenfluss.Domain.Category in 'src\Domain\Entities\Warenfluss.Domain.Category.pas',
  Warenfluss.Domain.Customer in 'src\Domain\Entities\Warenfluss.Domain.Customer.pas',
  Warenfluss.Domain.Product in 'src\Domain\Entities\Warenfluss.Domain.Product.pas',
  Warenfluss.Domain.PurchaseOrder in 'src\Domain\Entities\Warenfluss.Domain.PurchaseOrder.pas',
  Warenfluss.Domain.SalesOrder in 'src\Domain\Entities\Warenfluss.Domain.SalesOrder.pas',
  Warenfluss.Domain.StockMovement in 'src\Domain\Entities\Warenfluss.Domain.StockMovement.pas',
  Warenfluss.Domain.Supplier in 'src\Domain\Entities\Warenfluss.Domain.Supplier.pas',
  Warenfluss.Domain.User in 'src\Domain\Entities\Warenfluss.Domain.User.pas',
  Warenfluss.Domain.Warehouse in 'src\Domain\Entities\Warenfluss.Domain.Warehouse.pas',
  Warenfluss.Domain.OrderValidator in 'src\Domain\Validation\Warenfluss.Domain.OrderValidator.pas',
  Warenfluss.Domain.ProductValidator in 'src\Domain\Validation\Warenfluss.Domain.ProductValidator.pas',
  Warenfluss.Domain.StockValidator in 'src\Domain\Validation\Warenfluss.Domain.StockValidator.pas',
  Warenfluss.Api.ErrorMapper in 'src\Infrastructure\Api\Warenfluss.Api.ErrorMapper.pas',
  Warenfluss.Api.RestServer in 'src\Infrastructure\Api\Warenfluss.Api.RestServer.pas',
  Warenfluss.ORM.Database in 'src\Infrastructure\Database\Warenfluss.ORM.Database.pas',
  Warenfluss.ORM.DataSeeder in 'src\Infrastructure\Database\Warenfluss.ORM.DataSeeder.pas',
  Warenfluss.ORM.Models in 'src\Infrastructure\Database\Warenfluss.ORM.Models.pas',
  Warenfluss.ViewModel.Base in 'src\Presentation\ViewModels\Warenfluss.ViewModel.Base.pas',
  Warenfluss.ViewModel.Inventory in 'src\Presentation\ViewModels\Warenfluss.ViewModel.Inventory.pas',
  Warenfluss.ViewModel.Main in 'src\Presentation\ViewModels\Warenfluss.ViewModel.Main.pas',
  Warenfluss.ViewModel.Product in 'src\Presentation\ViewModels\Warenfluss.ViewModel.Product.pas',
  Warenfluss.ViewModel.SalesOrder in 'src\Presentation\ViewModels\Warenfluss.ViewModel.SalesOrder.pas',
  Warenfluss.View.Login in 'src\Presentation\Views\Warenfluss.View.Login.pas' {frmLogin},
  Warenfluss.View.Main in 'src\Presentation\Views\Warenfluss.View.Main.pas' {frmMain},
  Warenfluss.View.Products in 'src\Presentation\Views\Warenfluss.View.Products.pas' {frmProducts},
  Warenfluss.View.Inventory in 'src\Presentation\Views\Warenfluss.View.Inventory.pas' {frmInventory};

{$R *.res}

var
  UserRepo: IUserRepository;
  CatRepo: ICategoryRepository;
  SuppRepo: ISupplierRepository;
  CustRepo: ICustomerRepository;
  WHRepo: IWarehouseRepository;
  ProdRepo: IProductRepository;
  StockRepo: IStockRepository;
  SalesRepo: ISalesOrderRepository;
  PurchRepo: IPurchaseOrderRepository;
  AuditRepo: IAuditRepository;
  UoW: IUnitOfWork;

  AuthSvc: IAuthenticationService;
  UserSvc: IUserService;
  ProdSvc: IProductService;
  CatSvc: ICategoryService;
  SuppSvc: ISupplierService;
  CustSvc: ICustomerService;
  WHSvc: IWarehouseService;
  InvSvc: IInventoryService;
  XferSvc: IStockTransferService;
  PurchSvc: IPurchaseOrderService;
  SalesSvc: ISalesOrderService;
  ReportSvc: IReportService;
  AuditSvc: IAuditService;

  MainVM: TMainViewModel;
  LoginDlg: TfrmLogin;
  AuthResp: TLoginResponseDTO;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  // 1. Initialize In-Memory / mORMot Repositories (IoC Container Setup)
  UoW := TMockUnitOfWork.Create;
  UserRepo := TMockUserRepository.Create;
  CatRepo := TMockCategoryRepository.Create;
  SuppRepo := TMockSupplierRepository.Create;
  CustRepo := TMockCustomerRepository.Create;
  WHRepo := TMockWarehouseRepository.Create;
  ProdRepo := TMockProductRepository.Create;
  StockRepo := TMockStockRepository.Create;
  SalesRepo := TMockSalesOrderRepository.Create;
  PurchRepo := TMockPurchaseOrderRepository.Create;
  AuditRepo := TMockAuditRepository.Create;

  // Seed default master data
  TDataSeeder.SeedDefaultData(UserRepo, CatRepo, SuppRepo, CustRepo, WHRepo, ProdRepo, StockRepo);

  // 2. Initialize Application Services
  AuditSvc := TAuditService.Create(AuditRepo);
  AuthSvc := TAuthenticationService.Create(UserRepo, AuditSvc);
  UserSvc := TUserService.Create(UserRepo, AuditSvc);
  CatSvc := TCategoryService.Create(CatRepo);
  SuppSvc := TSupplierService.Create(SuppRepo);
  CustSvc := TCustomerService.Create(CustRepo);
  WHSvc := TWarehouseService.Create(WHRepo);
  ProdSvc := TProductService.Create(ProdRepo, CatRepo, AuditSvc);
  InvSvc := TInventoryService.Create(StockRepo, ProdRepo, WHRepo, UoW, AuditSvc);
  XferSvc := TStockTransferService.Create(StockRepo, ProdRepo, WHRepo, UoW, AuditSvc);
  PurchSvc := TPurchaseOrderService.Create(PurchRepo, ProdRepo, SuppRepo, WHRepo, StockRepo, UoW, AuditSvc);
  SalesSvc := TSalesOrderService.Create(SalesRepo, ProdRepo, CustRepo, WHRepo, StockRepo, UoW, AuditSvc);
  ReportSvc := TReportService.Create(ProdRepo, CatRepo, WHRepo, StockRepo, SalesRepo, PurchRepo);

  // 3. Authenticate User
  LoginDlg := TfrmLogin.CreateWithService(nil, AuthSvc);
  try
    if LoginDlg.ShowModal <> mrOk then
    begin
      Exit;
    end;
    AuthResp := LoginDlg.AuthenticatedUser;
  finally
    LoginDlg.Free;
  end;

  // 4. Initialize ViewModel and Main Form
  MainVM := TMainViewModel.Create(ReportSvc, AuthSvc);
  if AuthResp.Token <> '' then
    MainVM.SetUser(AuthSvc.GetCurrentUser(AuthResp.Token));
  Application.CreateForm(TfrmMain, frmMain);
  frmMain.InitServices(MainVM, ProdSvc, CatSvc, InvSvc, XferSvc, WHSvc);
  Application.Run;
end.

