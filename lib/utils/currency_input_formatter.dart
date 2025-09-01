import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// ユーザーの入力をリアルタイムでカンマ区切りの数値形式にフォーマットする。
class CurrencyInputFormatter extends TextInputFormatter {
  // 日本のロケールを指定した、カンマ区切りのフォーマッタ
  final NumberFormat _formatter = NumberFormat(
    "#,##0",
    "ja_JP",
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. 新しい入力値から、数字以外の文字をすべて削除する
    final String digitsOnly = newValue.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    // 2. 数字がなければ、空のテキストとして扱う
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // 3. 数字の文字列を整数に変換し、カンマ区切りにフォーマットする
    final String newText = _formatter.format(
      int.parse(digitsOnly),
    );

    // 4. フォーマット後のテキストで、カーソル位置を末尾に設定して返す
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newText.length,
      ),
    );
  }
}
