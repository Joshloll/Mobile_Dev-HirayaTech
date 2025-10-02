import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If the new value is empty, return it as is
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Unformat the text to a clean number string
    String newText = newValue.text.replaceAll(',', '');

    // If the text is not a valid number, return the old value
    if (int.tryParse(newText) == null) {
      return oldValue;
    }

    // Format the number with commas
    final number = int.parse(newText);
    final formatter = NumberFormat('#,###');
    final formattedText = formatter.format(number);

    // Return the new TextEditingValue with the formatted text and adjusted cursor position
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}