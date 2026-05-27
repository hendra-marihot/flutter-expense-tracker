import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../domain/expense.dart';
import '../domain/expense_repository.dart';
import 'expense_local_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._localDataSource);

  final ExpenseLocalDataSource _localDataSource;

  @override
  Stream<List<Expense>> watchAllExpenses() =>
      _localDataSource.watchAllExpenses();

  @override
  Stream<List<Expense>> watchExpensesByMonth(int year, int month) =>
      _localDataSource.watchExpensesByMonth(year, month);

  @override
  Future<void> addExpense(Expense expense) =>
      _localDataSource.insertExpense(expense);

  @override
  Future<void> deleteExpense(String id) => _localDataSource.deleteExpense(id);
}

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSource(ref.watch(databaseProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(expenseLocalDataSourceProvider));
});
