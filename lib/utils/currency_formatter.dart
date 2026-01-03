import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If empty, return empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digits
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // If result is empty (e.g. user typed only non-digits), return empty
    if (cleanedText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse and format
    final double value = double.parse(cleanedText);
    final formatter = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
    final String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
