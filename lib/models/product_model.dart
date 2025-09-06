// product_model.dart
// 商品のデータ構造を定義するクラス (データモデル)

class Product {
  // id
  final int? id;
  // バーコード
  final String? barcode;
  // 商品名
  final String name;
  // 価格 (小数点を含まない整数で管理することを推奨)
  final int price;
  // 商品カテゴリ
  final String? category;
  // 商品画像
  final String? imagePath;

  // コンストラクタ
  const Product({
    this.id,
    this.barcode,
    required this.name,
    required this.price,
    this.category,
    this.imagePath,
  });

  /// MapからProductオブジェクトを生成するためのファクトリコンストラクタ。
  /// データベースから読み取ったデータをオブジェクトに変換する際に使用する。
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      barcode: map['barcode'] as String?,
      name: map['name'] as String,
      price: map['price'] as int,
      category: map['category'] as String?,
      imagePath: map['imagePath'] as String?,
    );
  }

  /// ProductオブジェクトからMapを生成するメソッド。
  /// オブジェクトをデータベースに保存・更新する際に使用する。
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'price': price,
      'category': category,
      'imagePath': imagePath,
    };
  }
}
