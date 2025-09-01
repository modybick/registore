import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;

  // 商品を追加
  Future<void> addProduct(Product product) async {
    await DatabaseService.instance.addProduct(product);
    await reloadProducts(); // DB更新後にリストを再読み込み
  }

  // 商品を更新
  Future<void> updateProduct(Product product) async {
    await DatabaseService.instance.updateProduct(product);
    await reloadProducts();
  }

  // 商品を削除
  Future<void> deleteProduct(String barcode) async {
    await DatabaseService.instance.deleteProduct(barcode);
    await reloadProducts();
  }

  // 商品リストからユニークなカテゴリのリストを生成するゲッター
  List<String> get categories {
    if (_products.isEmpty) {
      return [];
    }
    // Setを使って重複を除外し、Listに変換
    final uniqueCategories = _products
        .map((p) => p.category)
        .toSet()
        .toList();
    // 先頭に「すべて」を追加して返す
    return ['すべて', ...uniqueCategories];
  }

  // カテゴリに属する商品を取得するメソッド
  List<Product> getProductsByCategory(String category) {
    // もしカテゴリが「すべて」なら、全商品を返す
    if (category == 'すべて') {
      return _products;
    }
    // それ以外のカテゴリなら、通常通りフィルタリングする
    return _products
        .where((p) => p.category == category)
        .toList();
  }

  // データベースからすべての商品をロードする
  Future<void> loadProducts() async {
    // 既に商品がロードされている場合は何もしない
    if (_products.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    _products = await DatabaseService.instance
        .getAllProducts();

    _isLoading = false;
    notifyListeners();
  }

  /// 商品リストを強制的に再読み込みする
  Future<void> reloadProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await DatabaseService.instance
        .getAllProducts();

    _isLoading = false;
    notifyListeners();
  }
}
