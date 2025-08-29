import '../models/product_model.dart';
import 'dart:async'; // Future.delayed を使うためにインポート

// データベース関連の処理をまとめたサービスクラス
class DatabaseService {
  // シングルトンパターン: アプリ内でこのクラスのインスタンスが1つだけ生成されることを保証する
  static final DatabaseService instance =
      DatabaseService._init();
  DatabaseService._init();

  // --- ▼▼▼ ダミーデータ ▼▼▼ ---
  // 本来はsqfliteデータベースから取得するが、現段階ではテスト用に固定リストを使用する。
  // 商品DBインポート機能を実装する際に、実際のDB処理に置き換える。
  final List<Product> _dummyProducts = [
    const Product(
      barcode: '4901881289521',
      name: 'ノート',
      price: 180,
      category: '文具',
    ),
    const Product(
      barcode: '4902102132279',
      name: '綾鷹 525ml',
      price: 150,
      category: '飲料',
    ),
    const Product(
      barcode: '4902102072124',
      name: 'コカ・コーラ 500ml',
      price: 160,
      category: '飲料',
    ),
    const Product(
      barcode: '4901005100829',
      name: '江崎グリコ ポッキーチョコレート',
      price: 162,
      category: '菓子',
    ),
    const Product(
      barcode: '4902777026197',
      name: '明治 きのこの山',
      price: 216,
      category: '菓子',
    ),
  ];
  // --- ▲▲▲ ダミーデータ ▲▲▲ ---

  /// バーコードを元に商品を検索する (現在はダミーデータを検索)
  ///
  /// [barcode] 検索したい商品のバーコード
  /// 戻り値: 見つかった場合はProductオブジェクト、見つからない場合はnullをFutureで返す
  Future<Product?> getProductByBarcode(
    String barcode,
  ) async {
    // 実際のデータベースアクセスの待ち時間をシミュレートする
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // ダミー商品リストから、バーコードが一致する最初の要素を検索する
      // firstWhereは要素が見つからない場合に例外をスローする
      final product = _dummyProducts.firstWhere(
        (p) => p.barcode == barcode,
      );
      return product;
    } catch (e) {
      // firstWhereで例外が発生した場合 (商品が見つからなかった場合) はnullを返す
      return null;
    }
  }

  /// すべての商品リストを取得する (現在はダミーデータを返す)
  Future<List<Product>> getAllProducts() async {
    // 実際のDBアクセスの待ち時間をシミュレート
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyProducts;
  }

  // --- 以下は将来のsqflite実装のためのプレースホルダ ---
  /*
  import 'package:sqflite/sqflite.dart';
  import 'package:path/path.dart';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos.db');
    return _database!;
  }

  // ... ここに _initDB, _createDB などのメソッドを実装 ...
  
  // sqfliteを使った実際のgetProductByBarcodeの実装例
  Future<Product?> getProductByBarcodeFromDb(String barcode) async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      columns: ['barcode', 'name', 'price', 'category'],
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    } else {
      return null;
    }
  }
  */
}
