import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../dashboard/presentation/widgets/month_selector.dart';
import '../../expenses/domain/expense_category.dart';
import '../../expenses/presentation/expense_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';
import '../domain/budget_calculations.dart';
import 'budget_providers.dart';
import 'widgets/budget_progress_bar.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(currentMonthProvider);
    final budgetsAsync = ref.watch(currentBudgetsProvider);
    final expensesAsync = ref.watch(monthlyExpensesProvider(month));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Budget',
            onPressed: () => _showAddBudgetDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          const MonthSelector(),
          Expanded(
            child: budgetsAsync.when(
              data: (budgets) {
                if (budgets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        const Text('No budgets set'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _showAddBudgetDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Budget'),
                        ),
                      ],
                    ),
                  );
                }
                return expensesAsync.when(
                  data: (expenses) {
                    final spending = spendingByCategory(expenses);
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: budgets.length,
                      itemBuilder: (context, index) {
                        final budget = budgets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BudgetProgressBar(
                            category: budget.category,
                            spent: spending[budget.category] ?? 0,
                            limit: budget.limit,
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    final month = ref.read(currentMonthProvider);
    final currency = ref.read(currencyProvider);
    final currencySymbol = CurrencyX.symbolFor(currency);
    final limitController = TextEditingController();
    var selectedCategory = ExpenseCategory.food;
    String? limitError;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Set Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ExpenseCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon, color: c.color, size: 20),
                            const SizedBox(width: 8),
                            Text(c.label),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: limitController,
                decoration: InputDecoration(
                  labelText: 'Budget Limit',
                  prefixText: '$currencySymbol ',
                  errorText: limitError,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final limit = double.tryParse(limitController.text);
                if (limit == null || limit <= 0) {
                  setState(() => limitError = 'Please enter a valid amount');
                  return;
                }

                final budget = Budget(
                  id: '${selectedCategory.name}_${month.year}_${month.month}',
                  category: selectedCategory,
                  limit: limit,
                  month: month.month,
                  year: month.year,
                );
                try {
                  await ref.read(budgetRepositoryProvider).setBudget(budget);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } on Exception catch (e) {
                  if (dialogContext.mounted) {
                    setState(() => limitError = 'Failed to save: $e');
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ).then((_) => limitController.dispose());
  }
}
