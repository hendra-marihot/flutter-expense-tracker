import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../expenses/domain/expense.dart';
import '../../expenses/domain/expense_category.dart';
import '../../expenses/presentation/expense_providers.dart';
import '../domain/expense_summary.dart';

typedef MonthYear = ({int year, int month});

class CurrentMonthNotifier extends Notifier<MonthYear> {
  @override
  MonthYear build() {
    final now = DateTime.now();
    return (year: now.year, month: now.month);
  }

  void setMonth({required int year, required int month}) {
    state = (year: year, month: month);
  }
}

final currentMonthProvider = NotifierProvider<CurrentMonthNotifier, MonthYear>(
  CurrentMonthNotifier.new,
);

final dashboardSummaryProvider = Provider<AsyncValue<ExpenseSummary>>((ref) {
  final month = ref.watch(currentMonthProvider);
  final expensesAsync = ref.watch(monthlyExpensesProvider(month));
  return expensesAsync.whenData(_buildSummary);
});

ExpenseSummary _buildSummary(List<Expense> expenses) {
  var totalSpent = 0.0;
  final categoryBreakdown = <ExpenseCategory, double>{};
  final dailySpending = <DateTime, double>{};

  for (final expense in expenses) {
    totalSpent += expense.amount;

    categoryBreakdown.update(
      expense.category,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );

    final day = DateTime(
      expense.date.year,
      expense.date.month,
      expense.date.day,
    );
    dailySpending.update(
      day,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }

  return ExpenseSummary(
    totalSpent: totalSpent,
    categoryBreakdown: categoryBreakdown,
    dailySpending: dailySpending,
  );
}
