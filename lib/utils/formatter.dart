import 'package:intl/intl.dart';

// アプリ全体で使うための、カンマ区切りの数値フォーマッタ
// "ja_JP"を指定することで、日本の書式（3桁区切り）を保証する
// この変数は一度だけ生成され、再利用されるため効率的
final _currencyFormatter = NumberFormat("#,##0", "ja_JP");

/// 数値をカンマ区切りの円表示文字列に変換する
/// 例: 12345 -> "¥12,345"
String formatCurrency(num amount) {
  return '¥${_currencyFormatter.format(amount)}';
}
