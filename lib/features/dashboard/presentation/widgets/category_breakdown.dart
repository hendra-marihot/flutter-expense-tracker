import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../expenses/domain/expense_category.dart';
import '../../../settings/presentation/settings_providers.dart';

class CategoryBreakdown extends ConsumerWidget {
  const CategoryBreakdown({
    required this.breakdown,
    required this.total,
    super.key,
  });

  final Map<ExpenseCategory, double> breakdown;
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...sorted.map((entry) {
              final percentage = total > 0 ? entry.value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(entry.key.icon, color: entry.key.color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key.label),
                              Text(entry.value.formattedAs(currency)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: entry.key.color.withValues(
                              alpha: 0.1,
                            ),
                            color: entry.key.color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
