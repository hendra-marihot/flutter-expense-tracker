import '../../expenses/domain/expense_category.dart';

class ExpenseSummary {
  const ExpenseSummary({
    required this.totalSpent,
    required this.categoryBreakdown,
    required this.dailySpending,
  });

  final double totalSpent;
  final Map<ExpenseCategory, double> categoryBreakdown;
  final Map<DateTime, double> dailySpending;
}
