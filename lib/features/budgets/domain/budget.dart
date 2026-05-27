import '../../expenses/domain/expense_category.dart';

class Budget {
  const Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  final String id;
  final ExpenseCategory category;
  final double limit;
  final int month;
  final int year;
}
