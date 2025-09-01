import 'package:flutter/foundation.dart';
import 'package:registore/services/sound_service.dart';
import '../models/cart_item_model.dart';
import '../models/sale_model.dart';
import '../services/database_service.dart';

class SalesProvider with ChangeNotifier {
  List<Sale> _sales = [];
  bool _isLoading = false;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;

  final SoundService _soundService = SoundService();

  // 販売履歴をDBに保存する
  Future<void> addSale({
    required List<CartItem> items,
    required double totalAmount,
    required double tenderedAmount,
    required String paymentMethod,
  }) async {
    final newSale = Sale(
      totalAmount: totalAmount,
      tenderedAmount: tenderedAmount,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );
    await DatabaseService.instance.insertSale(
      newSale,
      items,
    );
    _soundService.playCheckoutSound();
    // 保存後、リストを再読み込みする
    await loadSalesHistory();
  }

  // DBから販売履歴を読み込む
  Future<void> loadSalesHistory() async {
    _isLoading = true;
    notifyListeners();
    _sales = await DatabaseService.instance
        .getSalesHistory();
    _isLoading = false;
    notifyListeners();
  }

  /// すべての販売履歴をクリアする
  Future<void> clearAllSalesHistory() async {
    await DatabaseService.instance.deleteAllSalesHistory();
    // メモリ上のリストも空にする
    _sales.clear();
    // UIに変更を通知
    notifyListeners();
  }

  /// 販売のキャンセル状態をトグルする
  Future<void> toggleSaleCancellation(Sale sale) async {
    final newStatus = !sale.isCancelled;
    await DatabaseService.instance
        .updateSaleCancellationStatus(sale.id!, newStatus);

    // Providerが保持しているメモリ上のリストも更新する
    final index = _sales.indexWhere((s) => s.id == sale.id);
    if (index != -1) {
      _sales[index] = sale.copyWith(isCancelled: newStatus);
      notifyListeners();
    }
  }
}
