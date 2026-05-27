# Expense Tracker — Claude Code Project Instructions

## Project Overview

A personal expense tracker Flutter app demonstrating modern Flutter development practices.
Package name: `com.hendramarihot.expense_tracker`
App name: `expense_tracker` (pubspec)
Entry class: `ExpenseTrackerApp` in `lib/app.dart`

**Tech stack:**
- Flutter + Dart 3.8+
- State management: Riverpod 3 (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`)
- Database: Drift 2.25 + `sqlite3_flutter_libs` (code generation required)
- Navigation: go_router 15 with `StatefulShellRoute.indexedStack` for bottom nav
- Charts: fl_chart 0.70
- Settings persistence: `shared_preferences`
- Utilities: `uuid`, `intl`, `path`, `path_provider`
- Theme: Material 3 with seed color `0xFF1E88E5`

## Build Commands

```bash
# Install dependencies
flutter pub get

# Generate Drift DAOs and Riverpod providers (run after any schema or annotation change)
dart run build_runner build --force-jit

# Run all tests
flutter test

# Static analysis
flutter analyze

# Format all Dart files
dart format .
```

Always run `dart run build_runner build --force-jit` after:
- Modifying `lib/core/database/tables.dart`
- Modifying `lib/core/database/app_database.dart`
- Adding or changing `@riverpod` annotations

## Architecture

### Feature-first Clean Architecture

```
lib/
  app.dart                    # Root widget (ExpenseTrackerApp)
  main.dart                   # Entry point — ProviderScope wraps app
  core/
    constants/                # AppConstants
    database/                 # Drift AppDatabase + tables
    extensions/               # Dart extension methods (DateTime, double)
    router/                   # GoRouter setup + ScaffoldWithNavBar
    theme/                    # AppTheme (light/dark) + AppColors
  features/
    <feature>/
      data/                   # Repositories, data sources, Drift queries
      domain/                 # Pure Dart models and enums — NO Flutter imports
      presentation/           # Screens, providers, widget sub-folders
```

### Layer Rules

- **Domain layer** is pure Dart only. No `flutter/material.dart`, no package imports
  except core Dart libs. `ExpenseCategory` currently violates this (imports Flutter for
  `IconData` and `AppColors`) — keep it as-is until a refactor task explicitly addresses it.
- **Domain layer** defines abstract repository interfaces (`ExpenseRepository`,
  `BudgetRepository`). Concrete implementations (`*Impl`) live in the data layer.
- **Data layer** implements repository interfaces. Data sources and Drift queries live here.
- **Presentation layer** contains screens, Riverpod providers, and widget sub-folders.
  Providers watch repositories directly via `ref.watch`.

### Navigation

`app_router.dart` defines a single `GoRouter` exposed as `routerProvider` (plain `Provider`).
Bottom navigation uses `StatefulShellRoute.indexedStack` with four branches:
- `/dashboard` → `DashboardScreen`
- `/expenses` → `ExpensesScreen`
- `/budgets` → `BudgetsScreen`
- `/settings` → `SettingsScreen`

`/add-expense` is a full-screen modal route attached to `_rootNavigatorKey`
(not inside the shell), so it pushes over the nav bar.

`ScaffoldWithNavBar` renders the shell body, the `NavigationBar`, and the global
`FloatingActionButton` that navigates to `/add-expense`.

### Riverpod Provider Patterns

- `databaseProvider` → `Provider<AppDatabase>` (disposes DB on ref dispose)
- `expenseLocalDataSourceProvider` → `Provider<ExpenseLocalDataSource>`
- `expenseRepositoryProvider` → `Provider<ExpenseRepository>`
- `budgetRepositoryProvider` → `Provider<BudgetRepository>`
- `allExpensesProvider` → `StreamProvider<List<Expense>>`
- `monthlyExpensesProvider` → `StreamProvider.family<List<Expense>, ({int year, int month})>`
- `currentMonthProvider` → `NotifierProvider<CurrentMonthNotifier, MonthYear>`
- `dashboardSummaryProvider` → `Provider<AsyncValue<ExpenseSummary>>` (derives from `monthlyExpensesProvider`)
- `currentBudgetsProvider` → `StreamProvider<List<Budget>>`
- `settingsRepositoryProvider` → `Provider<SettingsRepository>`
- `settingsProvider` → `NotifierProvider<SettingsNotifier, AppSettings>`

Prefer `StreamProvider` for data that streams from Drift. Use `NotifierProvider` for
mutable state. Avoid wrapping `AsyncValue` inside a plain `Provider`.

### Drift Database

Tables are defined in `lib/core/database/tables.dart`:
- `Expenses` — id (PK), title, amount, category (text/enum name), date, notes (nullable), createdAt
- `Budgets` — id (PK, deterministic: `{category}_{year}_{month}`), category (text/enum name),
  limit_ (stored as `budget_limit`), month, year. Deterministic IDs enable upsert via
  `insertOnConflictUpdate`.

Tables use `@DataClassName` annotations to avoid collisions with domain models:
`Expenses` → `ExpenseRow`, `Budgets` → `BudgetRow`. Use these names in data source
mapping functions (e.g., `_mapToExpense(ExpenseRow row)`).

`AppDatabase.forTesting(NativeDatabase.memory())` — named constructor for unit tests
with in-memory databases.

`AppDatabase` in `lib/core/database/app_database.dart` uses `part 'app_database.g.dart'`
(generated). Schema version is `1`. The DB file is `expense_tracker.db` in the app documents
directory.

Run `build_runner` after any table change. Increment `schemaVersion` and add a `migration`
override when making breaking schema changes.

## Code Conventions

These match `analysis_options.yaml` (`flutter_lints` + custom rules):

- **Strings**: single quotes always (`prefer_single_quotes: true`)
- **const**: use `const` constructors everywhere possible (`prefer_const_constructors: true`)
- **final**: all local variables must be `final` unless reassignment is required
  (`prefer_final_locals: true`)
- **super.key**: use the `super.key` pattern in widget constructors, not `Key? key`
- **No print()**: `avoid_print: true`. Use a logger package if logging is needed.
- **Constructors first**: `sort_constructors_first: true`
- **Unawaited futures**: `unawaited_futures: true` — always `await` or explicitly ignore
- **mounted check**: always check `mounted` before using `context` after any `await`
- **Colors**: always use `Theme.of(context).colorScheme.*` — never hardcode colors.
  `AppColors` is only used for chart/category palette where semantic tokens don't apply.
- **Dispose**: dispose all `TextEditingController`, `AnimationController`, etc. in `dispose()`
- **Build method length**: keep `build()` under 40 lines; extract sub-widgets
- **Extensions**: currency formatting via `CurrencyX` on `double`
  (`.formattedAs(currencyCode)`, `.compactFormattedAs(currencyCode)`,
  `CurrencyX.symbolFor(currencyCode)`); date formatting via `DateTimeX` on `DateTime`
  (`.formatted`, `.monthYear`, `.isToday`)
- **No hardcoded sizes**: use `SizedBox` with named constants or theme spacing

## Feature Map

| Feature | Data | Domain | Presentation |
|---|---|---|---|
| expenses | `ExpenseLocalDataSource`, `ExpenseRepository` | `Expense`, `ExpenseCategory` | `ExpensesScreen`, `AddExpenseScreen`, `expense_providers.dart`, `CategoryChip`, `ExpenseListTile` |
| budgets | `BudgetRepository` | `Budget` | `BudgetsScreen`, `budget_providers.dart`, `BudgetProgressBar` |
| dashboard | — | `ExpenseSummary` | `DashboardScreen`, `dashboard_providers.dart`, `MonthlySummaryCard`, `SpendingChart`, `CategoryBreakdown` |
| settings | `SettingsRepository` | `AppSettings` | `SettingsScreen`, `settings_providers.dart` |

## Testing

- Test files mirror source: `test/features/expenses/...` mirrors `lib/features/expenses/...`
- Use `mocktail` (already in dev dependencies) for mocking
- ViewModel/provider tests use `ProviderContainer` directly with overrides
- Widget tests use `createComposeRule` equivalent: `WidgetTester` with `ProviderScope`
- Run `flutter test` before every commit
- Every bug fix must include a regression test
- Testing `StreamProvider`: use `container.listen(provider, ...)` to activate the
  stream subscription before awaiting values. `container.read(provider.future)` alone
  does NOT activate the subscription and will hang.
- Testing `Provider<AsyncValue<T>>`: listen for `AsyncData` state via `container.listen`.
- Budget integration tests use `AppDatabase.forTesting(NativeDatabase.memory())`.

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs on push to `main` and PRs:
`pub get` → `build_runner` → `flutter analyze --fatal-infos` → `flutter test` → `dart format --set-exit-if-changed`
Flutter version pinned to `3.38.x` stable.

## Known Debt

- `collection` package declared in pubspec.yaml but unused — safe to remove
