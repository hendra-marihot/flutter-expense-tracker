import 'budget.dart';

abstract class BudgetRepository {
  Stream<List<Budget>> watchBudgets(int year, int month);
  Future<void> setBudget(Budget budget);
  Future<void> deleteBudget(String id);
}
