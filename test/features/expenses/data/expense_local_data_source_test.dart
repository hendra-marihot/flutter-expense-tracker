import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/expenses/data/expense_local_data_source.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required String id,
  required DateTime date,
  ExpenseCategory category = ExpenseCategory.food,
  double amount = 10,
}) {
  return Expense(
    id: id,
    title: 'test',
    amount: amount,
    category: category,
    date: date,
    createdAt: DateTime(2025),
  );
}

void main() {
  late AppDatabase db;
  late ExpenseLocalDataSource dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ExpenseLocalDataSource(db);
  });

  tearDown(() => db.close());

  group('watchExpensesByMonth', () {
    test('includes the month range and excludes the next month', () async {
      await dataSource.insertExpense(
        _expense(id: 'first', date: DateTime(2025, 5, 1)),
      );
      await dataSource.insertExpense(
        _expense(id: 'last', date: DateTime(2025, 5, 31, 23, 59)),
      );
      await dataSource.insertExpense(
        _expense(id: 'next', date: DateTime(2025, 6)),
      );

      final result = await dataSource.watchExpensesByMonth(2025, 5).first;

      expect(result.map((e) => e.id), containsAll(<String>['first', 'last']));
      expect(result.map((e) => e.id), isNot(contains('next')));
      expect(result, hasLength(2));
    });

    test('handles the December to January boundary', () async {
      await dataSource.insertExpense(
        _expense(id: 'dec', date: DateTime(2025, 12, 15)),
      );
      await dataSource.insertExpense(_expense(id: 'jan', date: DateTime(2026)));

      final result = await dataSource.watchExpensesByMonth(2025, 12).first;

      expect(result.map((e) => e.id), <String>['dec']);
    });
  });

  group('category mapping', () {
    test('falls back to other for an unknown stored category', () async {
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              id: 'x',
              title: 'mystery',
              amount: 5,
              category: 'nonexistent',
              date: DateTime(2025, 5, 10),
            ),
          );

      final result = await dataSource.watchAllExpenses().first;

      expect(result.first.category, ExpenseCategory.other);
    });

    test('round-trips a known category', () async {
      await dataSource.insertExpense(
        _expense(
          id: 'k',
          date: DateTime(2025, 5, 10),
          category: ExpenseCategory.transport,
        ),
      );

      final result = await dataSource.watchAllExpenses().first;

      expect(result.first.category, ExpenseCategory.transport);
    });
  });
}
