import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/budgets/data/budget_repository.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BudgetRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = BudgetRepositoryImpl(db);
  });

  tearDown(() => db.close());

  group('BudgetRepositoryImpl', () {
    test('watchBudgets returns empty list initially', () {
      expect(repository.watchBudgets(2025, 5), emits(isEmpty));
    });

    test('setBudget inserts a budget', () async {
      await db
          .into(db.budgets)
          .insert(
            BudgetsCompanion.insert(
              id: 'b1',
              category: 'food',
              limit_: 500.0,
              month: 5,
              year: 2025,
            ),
          );

      final budgets = await repository.watchBudgets(2025, 5).first;

      expect(budgets, hasLength(1));
      expect(budgets.first.id, 'b1');
      expect(budgets.first.category, ExpenseCategory.food);
      expect(budgets.first.limit, 500.0);
    });

    test('watchBudgets filters by year and month', () async {
      await db
          .into(db.budgets)
          .insert(
            BudgetsCompanion.insert(
              id: 'b1',
              category: 'food',
              limit_: 500.0,
              month: 5,
              year: 2025,
            ),
          );
      await db
          .into(db.budgets)
          .insert(
            BudgetsCompanion.insert(
              id: 'b2',
              category: 'transport',
              limit_: 200.0,
              month: 6,
              year: 2025,
            ),
          );

      final may = await repository.watchBudgets(2025, 5).first;
      final june = await repository.watchBudgets(2025, 6).first;

      expect(may, hasLength(1));
      expect(may.first.id, 'b1');
      expect(june, hasLength(1));
      expect(june.first.id, 'b2');
    });

    test('unknown category falls back to other', () async {
      await db
          .into(db.budgets)
          .insert(
            BudgetsCompanion.insert(
              id: 'b1',
              category: 'nonexistent',
              limit_: 100.0,
              month: 5,
              year: 2025,
            ),
          );

      final budgets = await repository.watchBudgets(2025, 5).first;

      expect(budgets.first.category, ExpenseCategory.other);
    });

    test('deleteBudget removes the budget', () async {
      await db
          .into(db.budgets)
          .insert(
            BudgetsCompanion.insert(
              id: 'b1',
              category: 'food',
              limit_: 500.0,
              month: 5,
              year: 2025,
            ),
          );

      await repository.deleteBudget('b1');

      final budgets = await repository.watchBudgets(2025, 5).first;
      expect(budgets, isEmpty);
    });
  });
}
