import 'package:reactive_forms/reactive_forms.dart';
import '../../services/database_service.dart';

/// 【編集用】バーコードが他の商品で使われていないかを非同期で検証するバリデーター
class EditUniqueBarcodeAsyncValidator
    extends AsyncValidator<dynamic> {
  final int currentProductId;

  // 編集中の商品のIDをコンストラクタで受け取る
  EditUniqueBarcodeAsyncValidator(this.currentProductId);

  @override
  Future<Map<String, dynamic>?> validate(
    AbstractControl<dynamic> control,
  ) async {
    final barcode = control.value as String?;

    if (barcode == null || barcode.isEmpty) {
      return null;
    }

    // データベースに、自分以外のIDでこのバーコードが使われているか問い合わせる
    final isTaken = await DatabaseService.instance
        .isBarcodeTakenByAnotherProduct(
          barcode,
          currentProductId,
        );

    if (isTaken) {
      control.markAsTouched();
      return {'unique': true}; // 'unique'エラーを返す
    }

    return null; // 問題なければnullを返す
  }
}
