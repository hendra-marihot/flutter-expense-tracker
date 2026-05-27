import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';

final currentBudgetsProvider = StreamProvider<List<Budget>>((ref) {
  final month = ref.watch(currentMonthProvider);
  return ref
      .watch(budgetRepositoryProvider)
      .watchBudgets(month.year, month.month);
});
