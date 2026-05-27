import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../domain/expense.dart';
import '../domain/expense_category.dart';

class ExpenseLocalDataSource {
  ExpenseLocalDataSource(this._db);

  final AppDatabase _db;

  Stream<List<Expense>> watchAllExpenses() {
    final query = _db.select(_db.expenses)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_mapToExpense).toList());
  }

  Stream<List<Expense>> watchExpensesByMonth(int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    final query = _db.select(_db.expenses)
      ..where(
        (t) =>
            t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_mapToExpense).toList());
  }

  Future<void> insertExpense(Expense expense) {
    return _db
        .into(_db.expenses)
        .insert(
          ExpensesCompanion.insert(
            id: expense.id,
            title: expense.title,
            amount: expense.amount,
            category: expense.category.name,
            date: expense.date,
            notes: Value(expense.notes),
          ),
        );
  }

  Future<void> deleteExpense(String id) {
    return (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();
  }

  Expense _mapToExpense(ExpenseRow row) {
    return Expense(
      id: row.id,
      title: row.title,
      amount: row.amount,
      category: ExpenseCategory.values.firstWhere(
        (c) => c.name == row.category,
        orElse: () => ExpenseCategory.other,
      ),
      date: row.date,
      notes: row.notes,
      createdAt: row.createdAt,
    );
  }
}
