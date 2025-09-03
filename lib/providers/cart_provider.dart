import 'package:flutter/foundation.dart';
import 'package:registore/models/sale_detail_model.dart';
import 'package:registore/services/sound_service.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

// ChangeNotifierをミックスインして、変更通知機能を持つクラスを作成
class CartProvider with ChangeNotifier {
  final SoundService _soundService = SoundService();
  // カート内の商品を管理するMap。キーはバーコード(String)、値はCartItem。
  // プライベート変数(_items)として外部から直接変更できないようにする。
  final Map<int, CartItem> _items = {};

  // 外部からカート内の商品リストを取得するためのゲッター。
  // スプレッド演算子({...})を使って_itemsのコピーを返すことで、
  // Providerの外からリストが直接変更されるのを防ぐ。
  Map<int, CartItem> get items => {..._items};

  // カート内のユニークな商品数を返すゲッター。
  int get itemCount => _items.length;

  // カート内の全商品の合計金額を計算するゲッター。
  double get totalAmount {
    var total = 0.0;
    // forEachで各カートアイテムをループし、価格 * 数量を合計に加算する。
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // 商品をカートに追加するメソッド（バーコードスキャン時に使用）。
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // もし商品が既にカートにあれば、数量を1増やす。
      // updateメソッドで既存のアイテムを新しいCartItemインスタンスで更新する。
      _items.update(
        product.id!,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // もし商品がカートになければ、新しいアイテムとして追加する。
      _items.putIfAbsent(
        product.id!,
        () => CartItem(
          id: product.id!,
          name: product.name,
          price: product.price,
          quantity: 1, // 最初の数量は1
        ),
      );
    }
    _soundService.playSuccessSound();
    // 状態が変更されたことをリスナー（UIなど）に通知する。
    notifyListeners();
  }

  // 特定の商品の数量を1増やすメソッド（カート画面の「+」ボタン用）。
  void incrementItem(int id) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
        ),
      );
      _soundService.playSuccessSound();
      notifyListeners();
    }
  }

  // 特定の商品の数量を1減らすメソッド（カート画面の「-」ボタン用）。
  void decrementItem(int id) {
    // カートにない商品の場合は何もしない。
    if (!_items.containsKey(id)) return;

    if (_items[id]!.quantity > 1) {
      // 商品の数量が1より大きい場合は、数量を1減らす。
      _items.update(
        id,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      // 商品の数量が1の場合は、カートからその商品を削除する。
      _items.remove(id);
    }
    _soundService.playDecrementSound();
    notifyListeners();
  }

  /// 販売履歴の詳細リストを使って、現在のカートを完全に上書きする
  void overwriteCartWithDetails(List<SaleDetail> details) {
    // 1. 現在のカートを空にする
    _items.clear();

    // 2. 履歴の各商品を新しいカートアイテムとして追加する
    int count = 0;
    for (final detail in details) {
      // CartItemを直接生成し、Mapに追加する
      _items[count] = CartItem(
        id: detail.productId,
        name: detail.productName,
        price: detail.price,
        quantity: detail.quantity, // 履歴の数量をそのまま設定
      );

      count++;
    }

    // 3. 処理完了後、UIに変更を一度だけ通知する
    notifyListeners();
  }

  // カートから特定の商品を完全に削除するメソッド。
  void removeItem(int id) {
    _items.remove(id);
    notifyListeners();
  }

  // カート内のすべての商品を削除するメソッド。
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
