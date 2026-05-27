import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../expenses/domain/expense_category.dart';
import '../domain/budget.dart';
import '../domain/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Budget>> watchBudgets(int year, int month) {
    final query = _db.select(_db.budgets)
      ..where((t) => t.year.equals(year) & t.month.equals(month));
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => Budget(
              id: row.id,
              category: ExpenseCategory.values.firstWhere(
                (c) => c.name == row.category,
                orElse: () => ExpenseCategory.other,
              ),
              limit: row.limit_,
              month: row.month,
              year: row.year,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> setBudget(Budget budget) {
    return _db
        .into(_db.budgets)
        .insertOnConflictUpdate(
          BudgetsCompanion.insert(
            id: budget.id,
            category: budget.category.name,
            limit_: budget.limit,
            month: budget.month,
            year: budget.year,
          ),
        );
  }

  @override
  Future<void> deleteBudget(String id) {
    return (_db.delete(_db.budgets)..where((t) => t.id.equals(id))).go();
  }
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(databaseProvider));
});
