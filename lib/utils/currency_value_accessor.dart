import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// FormControlの`int`値と、TextFieldのカンマ区切り`String`値を相互に変換する。
class CurrencyValueAccessor
    extends ControlValueAccessor<int, String> {
  final NumberFormat _formatter = NumberFormat(
    "#,##0",
    "ja_JP",
  );

  @override
  String modelToViewValue(int? modelValue) {
    // モデル(int)からビュー(String)への変換
    // 値がnullでなければ、カンマ区切りにフォーマットする
    return modelValue == null
        ? ''
        : _formatter.format(modelValue);
  }

  @override
  int? viewToModelValue(String? viewValue) {
    // ビュー(String)からモデル(int)への変換
    if (viewValue == null || viewValue.isEmpty) {
      return null;
    }
    // カンマを削除してから、intにパースする
    return int.tryParse(viewValue.replaceAll(',', ''));
  }
}
