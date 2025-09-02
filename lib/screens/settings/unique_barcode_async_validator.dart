import 'package:reactive_forms/reactive_forms.dart';
import '../../services/database_service.dart';

/// バーコードがデータベースで一意であるかを非同期で検証するバリデーター
class UniqueBarcodeAsyncValidator
    extends AsyncValidator<dynamic> {
  @override
  Future<Map<String, dynamic>?> validate(
    AbstractControl<dynamic> control,
  ) async {
    final barcode = control.value as String?;

    // 値がnullまたは空の場合は、ここではエラーとしない（`Validators.required`に任せる）
    if (barcode == null || barcode.isEmpty) {
      return null;
    }

    // データベースに問い合わせ
    final exists = await DatabaseService.instance
        .productExists(barcode);

    // もしバーコードが存在すれば、'unique'というキーでエラー情報を返す
    // このキーはvalidationMessagesで参照される
    if (exists) {
      // 既存の値を無効にする
      control.markAsTouched();
      return {'unique': true};
    }

    // 問題なければnull（エラーなし）を返す
    return null;
  }
}
