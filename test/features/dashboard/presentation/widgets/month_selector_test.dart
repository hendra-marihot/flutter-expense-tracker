import 'package:expense_tracker/core/extensions/date_extensions.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/month_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester) {
  return tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(home: Scaffold(body: MonthSelector())),
    ),
  );
}

void main() {
  group('MonthSelector', () {
    testWidgets('shows the current month and advances on next tap', (
      tester,
    ) async {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month).monthYear;
      final nextMonth = DateTime(now.year, now.month + 1).monthYear;

      await _pump(tester);
      expect(find.text(thisMonth), findsOneWidget);

      await tester.tap(find.byTooltip('Next month'));
      await tester.pump();

      expect(find.text(nextMonth), findsOneWidget);
    });

    testWidgets('steps back on previous tap', (tester) async {
      final now = DateTime.now();
      final previousMonth = DateTime(now.year, now.month - 1).monthYear;

      await _pump(tester);

      await tester.tap(find.byTooltip('Previous month'));
      await tester.pump();

      expect(find.text(previousMonth), findsOneWidget);
    });
  });
}
