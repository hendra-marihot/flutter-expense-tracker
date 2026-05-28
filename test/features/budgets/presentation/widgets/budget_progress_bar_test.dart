import 'package:expense_tracker/features/budgets/presentation/widgets/budget_progress_bar.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  required double spent,
  required double limit,
}) {
  return tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: BudgetProgressBar(
            category: ExpenseCategory.food,
            spent: spent,
            limit: limit,
          ),
        ),
      ),
    ),
  );
}

LinearProgressIndicator _progressBar(WidgetTester tester) {
  return tester.widget<LinearProgressIndicator>(
    find.byType(LinearProgressIndicator),
  );
}

void main() {
  group('BudgetProgressBar', () {
    testWidgets('clamps progress to 1.0 when over budget', (tester) async {
      await _pump(tester, spent: 120, limit: 100);

      expect(_progressBar(tester).value, 1.0);
    });

    testWidgets('shows fractional progress when under budget', (tester) async {
      await _pump(tester, spent: 25, limit: 100);

      expect(_progressBar(tester).value, 0.25);
    });

    testWidgets('renders zero progress without crashing when limit is 0', (
      tester,
    ) async {
      await _pump(tester, spent: 50, limit: 0);

      expect(_progressBar(tester).value, 0.0);
      expect(tester.takeException(), isNull);
    });
  });
}
