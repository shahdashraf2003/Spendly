# 💸 Spendly

A personal finance iOS app built with **SwiftUI** and **SwiftData** — track your expenses, set budgets, and stay on top of your money.

---

## ✨ Features

### 🏠 Home
- Dashboard overview with balance, income vs. expenses
- Spending overview with budget progress bar
- Spending breakdown by category
- Recent transactions list
- Quick actions: Add Expense, Add Income, Analytics

### 💳 Transactions
- Add, edit, and delete income & expense transactions
- Filter and search transactions by category or date
- Assign each transaction to a custom category

### 📊 Budgets
- Set budgets per category with weekly / monthly / yearly periods
- Visual progress bar per budget (green → orange → red)
- Summary card showing total budget, spent, and remaining
- Long-press any budget card to delete
- Automatic 80% budget alert notification

### 📈 Analytics
- Spending charts and insights over week / month / year

### 🗂 Categories
- Create custom income and expense categories with emoji icons
- Full CRUD support (add, edit, delete)

### 👤 Profile
- Set your name and preferred currency (EGP, USD, EUR, SAR, AED, GBP)
- Appearance: Light / Dark / System
- Language: Arabic 🇸🇦 / English 🇺🇸 (full RTL support)
- **App Lock** — Face ID or device passcode (real device only)
- Notifications:
  - 💳 Payment reminders (daily at 8 PM)
  - 💰 Budget alerts (at 80% spend)
  - 📅 Monthly summary (1st of each month at 9 AM)
- Data backup & restore

---

## 🏗 Architecture

Spendly follows **Clean Architecture** with 3 layers:

```
Spendly/
├── Domain/           # Business logic (pure Swift, no frameworks)
│   ├── Entities/     # Budget, Transaction, Category
│   ├── UseCases/     # Add, Fetch, Update, Delete per entity
│   ├── Enums/        # TransactionType, BudgetPeriod, CategoryType
│   └── RepositoryInterfaces/
│
├── Data/             # Data access
│   ├── DataSources/  # SwiftData local storage
│   ├── Repositories/ # Implement domain interfaces
│   ├── Models/       # SwiftData @Model classes
│   ├── Mappers/      # Domain ↔ SwiftData model mapping
│   ├── Services/     # DataBackupService
│   └── DependencyInjection/  # AppContainer
│
└── Presentation/     # SwiftUI views + ViewModels
    ├── Home/
    ├── Transactions/
    ├── Budgets/
    ├── Categories/
    ├── Analytics/
    ├── Profile/
    └── Core/         # Shared components, theme, localization, settings
```

---

## 🛠 Tech Stack

| Technology | Usage |
|---|---|
| **SwiftUI** | All UI |
| **SwiftData** | Local persistence |
| **LocalAuthentication** | Face ID / passcode app lock |
| **UserNotifications** | Budget alerts & reminders |
| **Observation (`@Observable`)** | ViewModels & state management |
| **Clean Architecture** | Domain / Data / Presentation separation |

---

## 🚀 Requirements

- **iOS 17+**
- **Xcode 15+**
- No external dependencies — 100% Apple frameworks

---

## ▶️ Getting Started

1. Clone the repo
2. Open `Spendly.xcodeproj` in Xcode
3. Select a simulator or real device
4. Build & Run (`⌘R`)

> **Note:** App Lock requires a **real device** — the iOS simulator accepts any passcode so the lock is intentionally bypassed in simulator builds.

---

## 🌍 Localization

Spendly supports **Arabic** and **English** with full RTL layout switching. Language can be changed from the Profile screen at runtime.

---

## 📂 Data & Privacy

All data is stored **locally on device** using SwiftData. No network requests, no servers, no accounts required.
