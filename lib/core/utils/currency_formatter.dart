import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String numericOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (numericOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    String formatted = '';
    int length = numericOnly.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        formatted += '.';
      }
      formatted += numericOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String formatString(String value) {
    String numericOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numericOnly.isEmpty) return '';
    String formatted = '';
    int length = numericOnly.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        formatted += '.';
      }
      formatted += numericOnly[i];
    }
    return formatted;
  }
}
