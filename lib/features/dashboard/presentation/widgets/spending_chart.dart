import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingChart extends StatelessWidget {
  const SpendingChart({required this.dailySpending, super.key});

  final Map<DateTime, double> dailySpending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (dailySpending.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = dailySpending.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = <FlSpot>[];
    for (final entry in sortedEntries) {
      spots.add(FlSpot(entry.key.day.toDouble(), entry.value));
    }

    final firstDate = sortedEntries.first.key;
    final lastDayOfMonth = DateTime(
      firstDate.year,
      firstDate.month + 1,
      0,
    ).day.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Spending', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            RepaintBoundary(
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minX: 1,
                    maxX: lastDayOfMonth,
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: theme.colorScheme.primary,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
