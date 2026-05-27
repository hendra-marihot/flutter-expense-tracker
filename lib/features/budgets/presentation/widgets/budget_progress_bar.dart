import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../expenses/domain/expense_category.dart';
import '../../../settings/presentation/settings_providers.dart';

class BudgetProgressBar extends ConsumerWidget {
  const BudgetProgressBar({
    required this.category,
    required this.spent,
    required this.limit,
    super.key,
  });

  final ExpenseCategory category;
  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > limit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category.icon, color: category.color),
                const SizedBox(width: 8),
                Text(category.label, style: theme.textTheme.titleSmall),
                const Spacer(),
                Text(
                  '${spent.formattedAs(currency)} / ${limit.formattedAs(currency)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverBudget
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: category.color.withValues(alpha: 0.1),
              color: isOverBudget ? theme.colorScheme.error : category.color,
            ),
          ],
        ),
      ),
    );
  }
}
