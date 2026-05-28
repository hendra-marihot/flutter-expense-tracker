import '../../expenses/domain/expense.dart';
import '../../expenses/domain/expense_category.dart';

/// Aggregates total spending per category for the given expenses.
Map<ExpenseCategory, double> spendingByCategory(List<Expense> expenses) {
  final result = <ExpenseCategory, double>{};
  for (final expense in expenses) {
    result.update(
      expense.category,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return result;
}
