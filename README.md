# Expense Tracker

A Flutter expense tracker built to demonstrate architectural patterns I reach for in production: feature-first Clean Architecture, reactive state management with Riverpod, and a type-safe local database layer with Drift. It's a deliberately scoped project — the goal isn't a feature-complete app, it's a clear example of how I structure Flutter code, manage data flow, and make tradeoffs.

<!-- TODO: Add a screenshot or GIF here.
     Capture a ~15-second screen recording showing:
     1. Adding an expense (form → category chip → date picker → save)
     2. Dashboard updating (total, chart, category breakdown)
     3. Budget progress bar crossing the over-budget threshold
     4. Dark mode toggle in settings
     Use an iPhone 15 Pro simulator or Pixel 8 emulator. A GIF works better than static screenshots. -->

## Why these technologies

Every dependency choice has a reason. I could have reached for simpler options — but simpler isn't always better when the goal is demonstrating depth.

**Riverpod over Bloc.** Bloc is fine for event-driven state machines, but the data in this app is fundamentally reactive: expenses stream from SQLite, the dashboard derives from those streams, and settings need to be available synchronously before the first frame. Riverpod handles all three naturally — `StreamProvider` for DB watchers, `Provider<AsyncValue<T>>` for derived state, and `ProviderScope.overrides` for preloading. Bloc would have required more ceremony for the same result.

**Drift over sqflite.** I needed reactive queries (`watch()` that re-emits when rows change), type-safe table definitions, and `insertOnConflictUpdate` for budget upserts. sqflite gives you raw SQL strings and manual change notification — workable, but it pushes type safety and reactivity into your own code. Drift generates it.

**go_router with StatefulShellRoute.** Four-tab apps are straightforward until you need to preserve state across tab switches and push modals *over* the bottom nav bar. `StatefulShellRoute.indexedStack` handles the first; attaching the `/add-expense` route to the root navigator key handles the second.

## Architecture

Feature-first Clean Architecture. Each feature has three layers with strict dependency rules: domain is pure Dart (no Flutter imports), data implements domain interfaces, presentation watches providers.

```
lib/
├── core/
│   ├── database/        # Drift tables, AppDatabase, generated code
│   ├── theme/           # Material 3 light/dark with seed color
│   ├── router/          # GoRouter + StatefulShellRoute
│   └── extensions/      # Currency and date formatting
└── features/
    ├── expenses/        # CRUD, category system, swipe-to-delete
    ├── budgets/         # Per-category monthly limits with upsert
    ├── dashboard/       # Aggregated monthly view, chart, breakdown
    └── settings/        # Currency, dark mode, SharedPreferences
        each with: data/ → domain/ → presentation/
```

Data flows in one direction:

```
┌──────────┐    watch()     ┌──────────────┐   StreamProvider   ┌──────────────┐
│  Drift   │ ──────────────>│  Repository  │ ─────────────────> │   Riverpod   │
│  SQLite  │   reactive     │  (interface) │   reactive stream  │   Provider   │
└──────────┘   stream       └──────────────┘                    └──────┬───────┘
                                                                       │ ref.watch
                                                                ┌──────▼───────┐
                                                                │   Widget UI  │
                                                                └──────────────┘
```

When a row changes in SQLite, Drift's `watch()` emits, the repository stream updates, Riverpod rebuilds only the widgets that depend on that data. No manual `notifyListeners()`, no event bus.

## Decisions worth reading

These are the parts of the codebase that show judgment, not just familiarity with a framework.

**Deterministic budget IDs for upsert.** Budget primary keys are `{category}_{year}_{month}` — not UUIDs. This means `insertOnConflictUpdate()` naturally handles "create or update" without a separate lookup query. Setting a budget for Food in January either creates the row or updates the existing one. The ID *is* the business key. See [`budget_repository.dart:36-48`](lib/features/budgets/data/budget_repository.dart).

**Settings preloading to eliminate async flash.** SharedPreferences is async, but theme and currency need to be available before the first frame renders. I load settings in `main()` before `runApp`, then inject them via `ProviderScope.overrides`. The `SettingsNotifier.build()` reads the override synchronously — no loading spinner, no theme flash on startup. See [`main.dart`](lib/main.dart) and [`settings_providers.dart:9-12`](lib/features/settings/presentation/settings_providers.dart).

**`Provider<AsyncValue<T>>` instead of nested StreamProvider.** The dashboard summary is derived from monthly expenses. The naive approach is a `StreamProvider` that watches another `StreamProvider` — but that double-wraps the async state and makes error handling awkward. Instead, `dashboardSummaryProvider` is a plain `Provider` that reads the upstream `AsyncValue` and transforms it with `whenData()`. One level of async, clean error propagation. See [`dashboard_providers.dart:25-29`](lib/features/dashboard/presentation/dashboard_providers.dart).

**Safe enum mapping from database rows.** Categories are stored as text in SQLite. Parsing them back with `EnumName.byName()` crashes on unknown values — a real problem if you ever add or rename categories. Every mapping uses `firstWhere` with an `orElse` fallback to `ExpenseCategory.other`. See [`expense_local_data_source.dart:48-56`](lib/features/expenses/data/expense_local_data_source.dart).

**Single-pass aggregation.** The dashboard summary (total, per-category breakdown, daily spending) is computed in a single iteration over the expense list — not three separate passes. Small thing, but it reflects a habit. See [`dashboard_providers.dart:31-62`](lib/features/dashboard/presentation/dashboard_providers.dart).

## Testing

33 unit tests covering the layers where bugs actually hide: provider logic, repository contracts, and data transformations.

- **Provider tests** use `ProviderContainer` with overrides — no widget tree needed
- **Repository tests** run against an in-memory Drift database (`AppDatabase.forTesting`)
- **Stream testing** uses `container.listen()` to activate subscriptions (not `container.read()`, which hangs on streams)
- **Mocking** via mocktail for repository interfaces

CI runs on every push: `flutter analyze --fatal-infos` (info-level issues are failures), `flutter test`, and `dart format --set-exit-if-changed`.

**What's not tested:** Widget tests and integration tests are absent. The business logic is covered; the UI layer is not. I'd add widget tests for form validation and screen states next.

## Known limitations and what I'd change

I'd rather be honest about gaps than have a reviewer find them and wonder if I noticed.

- **`ExpenseCategory` violates domain purity.** It imports `IconData` and `AppColors` from Flutter — the domain layer should be pure Dart. A proper fix would move display concerns (icon, color) to a presentation-layer mapping, leaving the enum with only business data.

- **`riverpod_annotation` is unused.** It's in the dependencies, but all providers are hand-written. I'd either adopt generated providers with `@riverpod` annotations or remove the unused dependency.

- **No widget tests.** The business logic has coverage; the UI has none. For a production app, I'd add widget tests for form validation, empty states, and the Dismissible delete flow.

- **Month navigation isn't wired.** `CurrentMonthNotifier.setMonth()` exists and is tested, but the dashboard UI doesn't expose prev/next month buttons yet.

- **No undo on swipe-to-delete.** The Dismissible deletes immediately. A production app needs a SnackBar with an undo action.

## Run it

```bash
flutter pub get
dart run build_runner build --force-jit
flutter run
```

Requires Flutter 3.8+ with Dart 3.8+. Tests: `flutter test`.

## License

<!-- TODO: Add a LICENSE file to the repo root (Apache 2.0). Run:
     curl -o LICENSE https://www.apache.org/licenses/LICENSE-2.0.txt
     Then update the copyright line at the top of the file. -->

Copyright 2026 Hendra Marihot. Licensed under the Apache License 2.0 — see [LICENSE](LICENSE) for details.
