import 'package:intl/intl.dart';

extension CurrencyX on double {
  static const _symbols = {
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'IDR': 'Rp',
  };

  String formattedAs(String currencyCode) {
    final symbol = _symbols[currencyCode] ?? currencyCode;
    final decimals = currencyCode == 'JPY' ? 0 : 2;
    return NumberFormat.currency(symbol: symbol, decimalDigits: decimals)
        .format(this);
  }

  String compactFormattedAs(String currencyCode) {
    final symbol = _symbols[currencyCode] ?? currencyCode;
    return NumberFormat.compactCurrency(symbol: symbol).format(this);
  }

  static String symbolFor(String currencyCode) =>
      _symbols[currencyCode] ?? currencyCode;
}
