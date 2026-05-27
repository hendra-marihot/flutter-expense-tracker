import 'expense.dart';

abstract class ExpenseRepository {
  Stream<List<Expense>> watchAllExpenses();
  Stream<List<Expense>> watchExpensesByMonth(int year, int month);
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
}
