/// Formats a numeric currency amount into an Indian rupee format string.
/// E.g. 125450.0 -> "₹1,25,450"
///      48500.0  -> "₹48,500"
///      0.0      -> "₹0"
///      125450.5 -> "₹1,25,450.50"
String formatCurrency(double amount, {bool showDecimals = false}) {
  final isInt = !showDecimals && amount == amount.truncateToDouble();
  final fixedStr =
      isInt ? amount.toInt().toString() : amount.toStringAsFixed(2);

  final parts = fixedStr.split('.');
  String integerPart = parts[0];
  final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

  bool isNegative = false;
  if (integerPart.startsWith('-')) {
    isNegative = true;
    integerPart = integerPart.substring(1);
  }

  if (integerPart.length > 3) {
    final last3 = integerPart.substring(integerPart.length - 3);
    String remaining = integerPart.substring(0, integerPart.length - 3);
    final regExp = RegExp(r'\B(?=(\d{2})+(?!\d))');
    remaining = remaining.replaceAll(regExp, ',');
    integerPart = '$remaining,$last3';
  }

  return '₹${isNegative ? '-' : ''}$integerPart$decimalPart';
}
