import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/expense_repository.dart';
import '../domain/expense.dart';

final allExpensesProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAllExpenses();
});

final monthlyExpensesProvider =
    StreamProvider.family<List<Expense>, ({int year, int month})>((
      ref,
      params,
    ) {
      return ref
          .watch(expenseRepositoryProvider)
          .watchExpensesByMonth(params.year, params.month);
    });
