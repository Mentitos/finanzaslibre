import 'package:flutter/services.dart';

class SignedThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    if (newValue.text == '-') {
      return newValue;
    }

    String text = newValue.text.replaceAll('.', '');

    if (!RegExp(r'^-?\d*$').hasMatch(text)) {
      return oldValue;
    }

    bool isNegative = text.startsWith('-');
    String numericText = isNegative ? text.substring(1) : text;

    if (numericText.isEmpty) {
      return newValue; // can be empty or just "-"
    }

    // Count valid characters (digits and minus sign) before the cursor
    int charsBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.end; i++) {
      if (i < newValue.text.length &&
          (RegExp(r'\d').hasMatch(newValue.text[i]) ||
              newValue.text[i] == '-')) {
        charsBeforeCursor++;
      }
    }

    String formatted = _formatWithThousands(numericText);
    if (isNegative) {
      formatted = '-$formatted';
    }

    // Restore cursor position based on valid characters count
    int newCursorOffset = 0;
    int charsFound = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (charsFound >= charsBeforeCursor) {
        break;
      }
      if (RegExp(r'\d').hasMatch(formatted[i]) || formatted[i] == '-') {
        charsFound++;
      }
      newCursorOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }

  String _formatWithThousands(String text) {
    if (text.isEmpty) return text;

    String reversed = text.split('').reversed.join();
    String formatted = '';

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }

    return formatted.split('').reversed.join();
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text.replaceAll('.', '');

    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return oldValue;
    }

    String formatted = _formatWithThousands(text);

    // Count valid characters (digits) before the cursor
    int digitsBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.end; i++) {
      if (i < newValue.text.length &&
          RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    // Restore cursor position based on digits count
    int newCursorOffset = 0;
    int digitsFound = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (digitsFound >= digitsBeforeCursor) {
        break;
      }
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitsFound++;
      }
      newCursorOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }

  String _formatWithThousands(String text) {
    if (text.isEmpty) return text;

    String reversed = text.split('').reversed.join();
    String formatted = '';

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }

    return formatted.split('').reversed.join();
  }
}
