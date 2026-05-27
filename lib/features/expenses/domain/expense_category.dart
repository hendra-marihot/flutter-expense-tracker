import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum ExpenseCategory {
  food('Food', Icons.restaurant, 0),
  transport('Transport', Icons.directions_car, 1),
  shopping('Shopping', Icons.shopping_bag, 2),
  entertainment('Entertainment', Icons.movie, 3),
  health('Health', Icons.medical_services, 4),
  bills('Bills', Icons.receipt, 5),
  education('Education', Icons.school, 6),
  other('Other', Icons.more_horiz, 7);

  const ExpenseCategory(this.label, this.icon, this.colorIndex);

  final String label;
  final IconData icon;
  final int colorIndex;

  Color get color => AppColors.categoryColors[colorIndex];
}
