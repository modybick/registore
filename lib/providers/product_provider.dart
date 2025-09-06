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
  Future<void> deleteProduct(int id) async {
    await DatabaseService.instance.deleteProduct(id);
    await reloadProducts();
  }

  // 商品リストからユニークなカテゴリのリストを生成するゲッター
  List<String> get categories {
    if (_products.isEmpty) {
      return ['すべて']; // 商品がない場合は「すべて」タブだけ
    }
    // 1. 全商品からユニークなカテゴリのSetを生成
    final Set<String> uniqueCategoriesSet = _products
        .map((p) => p.category)
        .toSet();

    // 2. 「未分類」カテゴリが存在するか確認し、存在すればSetから一時的に削除
    final bool hasUncategorized = uniqueCategoriesSet
        .remove('未分類');

    // 3. 残りのカテゴリをListに変換し、アルファベット/五十音順にソート
    final List<String> sortedCategories =
        uniqueCategoriesSet.toList();
    sortedCategories.sort();

    // 4. 最終的なタブのリストを構築: まず「すべて」とソート済みカテゴリを追加
    final List<String> finalTabs = [
      'すべて',
      ...sortedCategories,
    ];

    // 5. もし「未分類」カテゴリが存在したら、リストの末尾に追加
    if (hasUncategorized) {
      finalTabs.add('未分類');
    }

    return finalTabs;
  }

  /// 純粋な（「すべて」を含まない）ユニークなカテゴリのリストを返すゲッター
  List<String> get pureCategories {
    if (_products.isEmpty) return [];
    final categories = _products
        .where((p) => p.category != '未分類')
        .map((p) => p.category)
        .toSet()
        .toList();
    categories.sort();

    return categories;
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
