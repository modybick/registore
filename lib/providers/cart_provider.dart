import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

// ChangeNotifierをミックスインして、変更通知機能を持つクラスを作成
class CartProvider with ChangeNotifier {
  // カート内の商品を管理するMap。キーはバーコード(String)、値はCartItem。
  // プライベート変数(_items)として外部から直接変更できないようにする。
  final Map<String, CartItem> _items = {};

  // 外部からカート内の商品リストを取得するためのゲッター。
  // スプレッド演算子({...})を使って_itemsのコピーを返すことで、
  // Providerの外からリストが直接変更されるのを防ぐ。
  Map<String, CartItem> get items => {..._items};

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
    if (_items.containsKey(product.barcode)) {
      // もし商品が既にカートにあれば、数量を1増やす。
      // updateメソッドで既存のアイテムを新しいCartItemインスタンスで更新する。
      _items.update(
        product.barcode,
        (existingCartItem) => CartItem(
          barcode: existingCartItem.barcode,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // もし商品がカートになければ、新しいアイテムとして追加する。
      _items.putIfAbsent(
        product.barcode,
        () => CartItem(
          barcode: product.barcode,
          name: product.name,
          price: product.price,
          quantity: 1, // 最初の数量は1
        ),
      );
    }
    // 状態が変更されたことをリスナー（UIなど）に通知する。
    notifyListeners();
  }

  // 特定の商品の数量を1増やすメソッド（カート画面の「+」ボタン用）。
  void incrementItem(String barcode) {
    if (_items.containsKey(barcode)) {
      _items.update(
        barcode,
        (existing) => CartItem(
          barcode: existing.barcode,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
        ),
      );
      notifyListeners();
    }
  }

  // 特定の商品の数量を1減らすメソッド（カート画面の「-」ボタン用）。
  void decrementItem(String barcode) {
    // カートにない商品の場合は何もしない。
    if (!_items.containsKey(barcode)) return;

    if (_items[barcode]!.quantity > 1) {
      // 商品の数量が1より大きい場合は、数量を1減らす。
      _items.update(
        barcode,
        (existing) => CartItem(
          barcode: existing.barcode,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      // 商品の数量が1の場合は、カートからその商品を削除する。
      _items.remove(barcode);
    }
    notifyListeners();
  }

  // カートから特定の商品を完全に削除するメソッド。
  void removeItem(String barcode) {
    _items.remove(barcode);
    notifyListeners();
  }

  // カート内のすべての商品を削除するメソッド。
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
