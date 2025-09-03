// cart_item_model.dart
// ショッピングカート内の個々の商品のデータ構造を定義するクラス

class CartItem {
  // 商品のバーコード (Productモデルと共通)
  final int id;
  // 商品名
  final String name;
  // 商品の単価
  final int price;
  // カートに入っている数量
  final int quantity;

  // コンストラクタ
  // CartItemオブジェクトを作成する際に、全てのプロパティを必須とする
  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}
