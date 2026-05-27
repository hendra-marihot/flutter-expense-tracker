import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../settings/presentation/settings_providers.dart';

class MonthlySummaryCard extends ConsumerWidget {
  const MonthlySummaryCard({
    required this.totalSpent,
    required this.monthLabel,
    super.key,
  });

  final double totalSpent;
  final String monthLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(monthLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              totalSpent.formattedAs(currency),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total spent',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
