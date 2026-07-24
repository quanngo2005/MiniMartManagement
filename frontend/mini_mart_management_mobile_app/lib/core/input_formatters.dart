import 'package:flutter/services.dart';

class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleanText = newValue.text.replaceAll(',', '');

    if (cleanText.isNotEmpty && int.tryParse(cleanText) == null) {
      return oldValue;
    }

    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final formatted = _formatNumber(cleanText);

    int cleanPos = 0;
    for (int i = 0;
        i < newValue.selection.baseOffset && i < newValue.text.length;
        i++) {
      if (newValue.text[i] != ',') cleanPos++;
    }

    int formattedPos = 0;
    int cleanIdx = 0;
    while (formattedPos < formatted.length && cleanIdx < cleanPos) {
      if (formatted[formattedPos] != ',') cleanIdx++;
      formattedPos++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formattedPos),
    );
  }

  String _formatNumber(String digits) {
    final sb = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        sb.write(',');
      }
      sb.write(digits[i]);
      count++;
    }
    return sb.toString().split('').reversed.join();
  }
}