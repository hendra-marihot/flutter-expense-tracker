import 'package:expense_tracker/features/budgets/domain/budget_calculations.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required ExpenseCategory category,
  required double amount,
  String id = 'e',
}) {
  return Expense(
    id: id,
    title: 'test',
    amount: amount,
    category: category,
    date: DateTime(2025, 5, 15),
    createdAt: DateTime(2025, 5, 15),
  );
}

void main() {
  group('spendingByCategory', () {
    test('returns an empty map for no expenses', () {
      expect(spendingByCategory(const []), isEmpty);
    });

    test('sums amounts within the same category', () {
      final result = spendingByCategory([
        _expense(category: ExpenseCategory.food, amount: 10, id: 'a'),
        _expense(category: ExpenseCategory.food, amount: 5.5, id: 'b'),
      ]);

      expect(result, {ExpenseCategory.food: 15.5});
    });

    test('keeps categories separate', () {
      final result = spendingByCategory([
        _expense(category: ExpenseCategory.food, amount: 10, id: 'a'),
        _expense(category: ExpenseCategory.transport, amount: 7, id: 'b'),
        _expense(category: ExpenseCategory.food, amount: 3, id: 'c'),
      ]);

      expect(result, {ExpenseCategory.food: 13, ExpenseCategory.transport: 7});
    });
  });
}
