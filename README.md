# Warenfluss — Warenwirtschaftssystem

> A clean-architecture Delphi desktop ERP / inventory-management system with an integrated REST server, built on mORMot 2.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Modules](#modules)
- [Getting Started](#getting-started)
- [Running Tests](#running-tests)
- [Technology Stack](#technology-stack)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

**Warenfluss** is a Delphi / RAD Studio application that implements core warehouse and trade-flow operations:

| Feature | Description |
|---|---|
| Authentication | Role-based login with audit logging |
| Product Management | Categories, suppliers, product catalog |
| Inventory Control | Stock levels, warehouse assignments, adjustments |
| Stock Transfers | Inter-warehouse stock movement |
| Sales Orders | Customer order lifecycle management |
| Purchase Orders | Supplier procurement workflow |
| Reporting | Sales, inventory, and activity reports |
| Audit Log | Full audit trail for all critical operations |

The solution ships as **two executables**:

| Project | Description |
|---|---|
| `Warenfluss.exe` | VCL desktop client (the primary UI) |
| `WarenflussServer.exe` | Standalone mORMot REST/JSON API server |

---

## Architecture

The codebase follows **Clean Architecture** (a.k.a. Onion / Layered Architecture), keeping business rules independent of frameworks, databases, and UI.

`
+---------------------------------------------------+
|                   Presentation                    |  <- VCL Views + ViewModels (MVVM)
+---------------------------------------------------+
|                   Application                     |  <- Services, DTOs, Interfaces
+---------------------------------------------------+
|                     Domain                        |  <- Entities, Validators (pure business logic)
+---------------------------------------------------+
|                  Infrastructure                   |  <- ORM, Repositories, REST API
+---------------------------------------------------+
            depends only on inner layers
`

### Dependency Rule
Each layer depends **only inward** - the Domain knows nothing about the database or UI. Interfaces defined in the `Application` layer are implemented in `Infrastructure`, injected at startup (manual IoC/DI in `Warenfluss.dpr`).

---

## Project Structure

`
Warenwirtschaftssystem/
├── src/
│   ├── Application/
│   │   ├── DTOs/               # Data Transfer Objects (Auth, Product, Order, Inventory, Report)
│   │   ├── Interfaces/         # IRepository and IService contracts
│   │   └── Services/           # Business use-case implementations
│   │
│   ├── Common/
│   │   ├── Warenfluss.Events        # Domain event types
│   │   ├── Warenfluss.Exceptions    # Custom exception hierarchy
│   │   ├── Warenfluss.Localization  # i18n helpers
│   │   ├── Warenfluss.Security      # Hashing, token utilities
│   │   └── Warenfluss.Types         # Shared enums and value types
│   │
│   ├── Domain/
│   │   ├── Entities/           # Core domain objects (Product, Order, Warehouse...)
│   │   └── Validation/         # Domain validators (Order, Product, Stock)
│   │
│   ├── Infrastructure/
│   │   ├── Api/                # mORMot REST server and error mapper
│   │   ├── Database/           # ORM setup, models, data seeder
│   │   └── Repositories/       # mORMot and Mock repository implementations
│   │
│   └── Presentation/
│       ├── ViewModels/         # MVVM ViewModels (Main, Product, Inventory, SalesOrder)
│       └── Views/              # VCL Forms (.pas + .dfm): Login, Main
│
├── test/
│   ├── Test.AuthenticationService.pas
│   ├── Test.InventoryService.pas
│   ├── Test.SalesOrderService.pas
│   ├── Test.StockTransferService.pas
│   ├── Warenfluss.TestRunner.pas
│   └── Warenfluss.Tests.dpr    # Test runner project
│
├── Warenfluss.dpr              # Client application entry point
├── WarenflussServer.dpr        # Server application entry point
├── ProjectGroup1.groupproj     # RAD Studio project group
└── .gitignore
`

---

## Modules

### Application Services (`src/Application/Services/`)

| Service | Responsibility |
|---|---|
| TAuthenticationService | Login, logout, session management |
| TUserService | User CRUD, role assignment |
| TProductService | Product catalog, pricing |
| TCategoryService | Product categorisation |
| TSupplierService | Supplier master data |
| TCustomerService | Customer master data |
| TWarehouseService | Warehouse locations |
| TInventoryService | Stock queries, adjustments |
| TStockTransferService | Inter-warehouse transfers (Unit-of-Work) |
| TPurchaseOrderService | Procurement workflow (Unit-of-Work) |
| TSalesOrderService | Sales workflow (Unit-of-Work) |
| TReportService | Aggregated reporting queries |
| TAuditService | Audit log writes |

### Domain Entities (`src/Domain/Entities/`)

Product, Category, Supplier, Customer, Warehouse, StockMovement, SalesOrder, PurchaseOrder, User, AuditLog

### Infrastructure Repositories (`src/Infrastructure/Repositories/`)

| Implementation | Backend |
|---|---|
| TMock*Repository | In-memory (fast testing / demo) |
| TmORMot*Repository | mORMot 2 ORM -> SQLite / any SQL backend |

---

## Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| RAD Studio / Delphi | 11 Alexandria or later |
| mORMot 2 | Latest (libs/mORMot2/) |
| Windows | 10 / 11 (64-bit recommended) |

### Build Steps

1. **Clone the repository**
   `ash
   git clone https://github.com/<your-org>/Warenwirtschaftssystem.git
   `

2. **Open the project group** in RAD Studio:
   `
   File -> Open -> ProjectGroup1.groupproj
   `

3. **Build All** (Ctrl+Shift+F9) or build projects individually:
   - `Warenfluss.dproj` - desktop client
   - `WarenflussServer.dproj` - REST server

4. **Run the client** - a login dialog appears on startup.
   Default seed credentials are configured in `Warenfluss.ORM.DataSeeder`.

### Configuration

The current build uses **in-memory mock repositories** for instant startup with seeded demo data.
To switch to a persistent SQLite database, replace the `TMock*` factories in `Warenfluss.dpr`
with the `TmORMot*` equivalents and configure the connection in `Warenfluss.ORM.Database`.

---

## Running Tests

Open `test/Warenfluss.Tests.dpr` in RAD Studio and run the project.
The DUnit-compatible test runner executes all registered test suites:

- TAuthenticationServiceTests
- TInventoryServiceTests
- TSalesOrderServiceTests
- TStockTransferServiceTests

---

## Technology Stack

| Layer | Technology |
|---|---|
| Language | Object Pascal (Delphi) |
| UI Framework | VCL (Visual Component Library) |
| Pattern | MVVM + Clean Architecture |
| ORM / REST | mORMot 2 |
| Database | SQLite (via mORMot) / In-Memory for tests |
| Testing | DUnit / custom test runner |

---

## Contributing

1. Fork the repository and create a feature branch from `main`:
   `ash
   git checkout -b feat/my-new-feature
   `
2. Write clear, scoped commits using the convention below.
3. Open a Pull Request against `main` with a descriptive title and summary.

### Commit Message Convention

This project follows Conventional Commits (https://www.conventionalcommits.org/):

`
<type>(<scope>): <short summary>

[optional body - what changed and why]
[optional footer - breaking changes, issue refs]
`

| Type | When to use |
|---|---|
| feat | New feature |
| fix | Bug fix |
| refactor | Code change without behaviour change |
| chore | Build, CI, tooling |
| docs | Documentation only |
| test | Adding or updating tests |
| style | Formatting, whitespace |
| perf | Performance improvement |

---

## License

Distributed under the MIT License. See LICENSE for details.
