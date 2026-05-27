import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String get formatted => DateFormat.yMMMd().format(this);
  String get monthYear => DateFormat.yMMM().format(this);
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
