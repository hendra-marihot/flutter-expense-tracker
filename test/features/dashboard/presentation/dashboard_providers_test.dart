import 'dart:async';

import 'package:expense_tracker/features/dashboard/presentation/dashboard_providers.dart';
import 'package:expense_tracker/features/expenses/data/expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';
import 'package:expense_tracker/features/dashboard/domain/expense_summary.dart';
import 'package:expense_tracker/features/expenses/domain/expense_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  group('CurrentMonthNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('defaults to current month and year', () {
      final now = DateTime.now();
      final month = container.read(currentMonthProvider);

      expect(month.year, now.year);
      expect(month.month, now.month);
    });

    test('setMonth updates state', () {
      container
          .read(currentMonthProvider.notifier)
          .setMonth(year: 2025, month: 3);

      final month = container.read(currentMonthProvider);
      expect(month.year, 2025);
      expect(month.month, 3);
    });

    test('setMonth can go to previous months', () {
      container
          .read(currentMonthProvider.notifier)
          .setMonth(year: 2024, month: 12);

      final month = container.read(currentMonthProvider);
      expect(month.year, 2024);
      expect(month.month, 12);
    });
  });

  group('dashboardSummaryProvider', () {
    late ProviderContainer container;
    late MockExpenseRepository mockRepo;
    final now = DateTime.now();

    setUp(() {
      mockRepo = MockExpenseRepository();
    });

    tearDown(() => container.dispose());

    Future<ExpenseSummary> readSummary(ProviderContainer c) {
      final completer = Completer<ExpenseSummary>();
      final sub = c.listen(dashboardSummaryProvider, (prev, next) {
        if (next is AsyncData<ExpenseSummary>) {
          if (!completer.isCompleted) completer.complete(next.value);
        }
      });
      addTearDown(sub.close);
      return completer.future.timeout(const Duration(seconds: 5));
    }

    ProviderContainer createContainer({List<Expense> expenses = const []}) {
      when(
        () => mockRepo.watchExpensesByMonth(any(), any()),
      ).thenAnswer((_) => Stream.value(expenses));

      container = ProviderContainer(
        overrides: [expenseRepositoryProvider.overrideWithValue(mockRepo)],
      );
      return container;
    }

    test('returns zero totals for empty expenses', () async {
      createContainer(expenses: []);

      final summary = await readSummary(container);

      expect(summary.totalSpent, 0);
      expect(summary.categoryBreakdown, isEmpty);
      expect(summary.dailySpending, isEmpty);
    });

    test('computes total spent correctly', () async {
      final expenses = [
        _expense(amount: 25.0, category: ExpenseCategory.food),
        _expense(amount: 75.0, category: ExpenseCategory.transport),
        _expense(amount: 50.0, category: ExpenseCategory.food),
      ];
      createContainer(expenses: expenses);

      final summary = await readSummary(container);

      expect(summary.totalSpent, 150.0);
    });

    test('computes category breakdown correctly', () async {
      final expenses = [
        _expense(amount: 25.0, category: ExpenseCategory.food),
        _expense(amount: 75.0, category: ExpenseCategory.transport),
        _expense(amount: 50.0, category: ExpenseCategory.food),
      ];
      createContainer(expenses: expenses);

      final summary = await readSummary(container);

      expect(summary.categoryBreakdown[ExpenseCategory.food], 75.0);
      expect(summary.categoryBreakdown[ExpenseCategory.transport], 75.0);
      expect(summary.categoryBreakdown.length, 2);
    });

    test('groups daily spending by date', () async {
      final date1 = DateTime(now.year, now.month, 10);
      final date2 = DateTime(now.year, now.month, 11);
      final expenses = [
        _expense(amount: 10.0, date: date1),
        _expense(amount: 20.0, date: date1),
        _expense(amount: 30.0, date: date2),
      ];
      createContainer(expenses: expenses);

      final summary = await readSummary(container);

      expect(summary.dailySpending[date1], 30.0);
      expect(summary.dailySpending[date2], 30.0);
      expect(summary.dailySpending.length, 2);
    });

    test('handles single expense', () async {
      final expenses = [
        _expense(amount: 42.0, category: ExpenseCategory.health),
      ];
      createContainer(expenses: expenses);

      final summary = await readSummary(container);

      expect(summary.totalSpent, 42.0);
      expect(summary.categoryBreakdown.length, 1);
      expect(summary.categoryBreakdown[ExpenseCategory.health], 42.0);
    });
  });
}

int _counter = 0;

Expense _expense({
  double amount = 10.0,
  ExpenseCategory category = ExpenseCategory.food,
  DateTime? date,
}) {
  final now = DateTime.now();
  return Expense(
    id: 'test-${_counter++}',
    title: 'Test',
    amount: amount,
    category: category,
    date: date ?? DateTime(now.year, now.month, 15),
    createdAt: DateTime.now(),
  );
}
