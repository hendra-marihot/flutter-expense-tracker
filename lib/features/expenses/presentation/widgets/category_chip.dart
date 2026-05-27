import 'package:flutter/material.dart';
import '../../domain/expense_category.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onSelected,
    super.key,
  });

  final ExpenseCategory category;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      onSelected: onSelected,
      avatar: Icon(category.icon, size: 18),
      label: Text(category.label),
      selectedColor: category.color.withValues(alpha: 0.2),
      checkmarkColor: category.color,
    );
  }
}
