import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/date_extensions.dart';
import 'dashboard_providers.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/month_selector.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/spending_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(currentMonthProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final monthLabel = DateTime(month.year, month.month).monthYear;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        children: [
          const MonthSelector(),
          Expanded(
            child: summaryAsync.when(
              data: (summary) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  MonthlySummaryCard(
                    totalSpent: summary.totalSpent,
                    monthLabel: monthLabel,
                  ),
                  const SizedBox(height: 16),
                  SpendingChart(dailySpending: summary.dailySpending),
                  const SizedBox(height: 16),
                  CategoryBreakdown(
                    breakdown: summary.categoryBreakdown,
                    total: summary.totalSpent,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
