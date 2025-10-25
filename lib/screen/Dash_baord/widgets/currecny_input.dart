import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat.decimalPattern();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Prevent recursion
    if (newValue.text == oldValue.text) return newValue;

    // Remove all non-digits except the decimal point
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Handle decimal cases
    if (newText.contains('.')) {
      List<String> parts = newText.split('.');
      String beforeDecimal = formatter.format(int.tryParse(parts[0]) ?? 0);
      String afterDecimal = parts.length > 1 ? parts[1] : '';
      newText = '$beforeDecimal.${afterDecimal}';
    } else {
      newText = formatter.format(int.tryParse(newText) ?? 0);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
