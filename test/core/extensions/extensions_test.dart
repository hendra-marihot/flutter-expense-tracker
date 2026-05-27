import 'package:expense_tracker/core/extensions/currency_extensions.dart';
import 'package:expense_tracker/core/extensions/date_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyX', () {
    test('formattedAs USD returns dollar-formatted string', () {
      expect(1234.56.formattedAs('USD'), r'$1,234.56');
    });

    test('formattedAs handles zero', () {
      expect(0.0.formattedAs('USD'), r'$0.00');
    });

    test('formattedAs handles small amounts', () {
      expect(0.99.formattedAs('USD'), r'$0.99');
    });

    test('formattedAs EUR uses euro symbol', () {
      expect(1234.56.formattedAs('EUR'), '€1,234.56');
    });

    test('formattedAs JPY uses no decimal digits', () {
      expect(1234.0.formattedAs('JPY'), '¥1,234');
    });

    test('compactFormattedAs returns compact form for large amounts', () {
      final result = 1500000.0.compactFormattedAs('USD');
      expect(result, contains(r'$'));
      expect(result, contains('M'));
    });

    test('symbolFor returns correct symbols', () {
      expect(CurrencyX.symbolFor('USD'), r'$');
      expect(CurrencyX.symbolFor('EUR'), '€');
      expect(CurrencyX.symbolFor('IDR'), 'Rp');
      expect(CurrencyX.symbolFor('XYZ'), 'XYZ');
    });
  });

  group('DateTimeX', () {
    test('formatted returns readable date string', () {
      final date = DateTime(2025, 5, 15);
      final result = date.formatted;
      expect(result, contains('May'));
      expect(result, contains('15'));
      expect(result, contains('2025'));
    });

    test('monthYear returns month and year', () {
      final date = DateTime(2025, 5);
      final result = date.monthYear;
      expect(result, contains('May'));
      expect(result, contains('2025'));
    });

    test('isToday returns true for today', () {
      expect(DateTime.now().isToday, true);
    });

    test('isToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isToday, false);
    });

    test('isToday returns false for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(tomorrow.isToday, false);
    });
  });
}
