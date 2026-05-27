import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../settings/presentation/settings_providers.dart';
import '../../domain/expense.dart';

class ExpenseListTile extends ConsumerWidget {
  const ExpenseListTile({required this.expense, this.onDismissed, super.key});

  final Expense expense;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: expense.category.color.withValues(alpha: 0.2),
          child: Icon(expense.category.icon, color: expense.category.color),
        ),
        title: Text(expense.title),
        subtitle: Text(expense.date.formatted),
        trailing: Text(
          expense.amount.formattedAs(currency),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
