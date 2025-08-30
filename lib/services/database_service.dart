import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/sale_detail_model.dart';
import '../models/sale_model.dart';

class DatabaseService {
  static final DatabaseService instance =
      DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // データベースのテーブルを作成
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        barcode TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        category TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        totalAmount REAL NOT NULL,
        tenderedAmount REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isCancelled INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE sale_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saleId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        price INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (saleId) REFERENCES sales (id) ON DELETE CASCADE
      )
    ''');
    // ダミーの商品データを初期登録
    _insertDummyProducts(db);
  }

  void _insertDummyProducts(Database db) {
    final products = [
      // ... (以前のダミーデータ) ...
    ];
    for (var product in products) {
      db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // --- 商品関連のメソッド ---

  /// バーコードで商品をDBから検索する
  Future<Product?> getProductByBarcode(
    String barcode,
  ) async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// すべての商品をDBから取得する
  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      orderBy: 'name ASC',
    );
    return List.generate(
      maps.length,
      (i) => Product.fromMap(maps[i]),
    );
  }

  // --- 販売履歴関連のメソッド ---

  /// 販売履歴と詳細をDBにインサートする
  Future<void> insertSale(
    Sale sale,
    List<CartItem> items,
  ) async {
    final db = await instance.database;
    // トランザクションを使い、処理の整合性を保証する
    await db.transaction((txn) async {
      // 1. salesテーブルに記録を挿入し、そのIDを取得
      final saleId = await txn.insert(
        'sales',
        sale.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. 取得したIDを使って、各商品をsale_detailsに挿入
      for (final item in items) {
        final detail = SaleDetail(
          saleId: saleId,
          productName: item.name,
          price: item.price,
          quantity: item.quantity,
        );
        await txn.insert(
          'sale_details',
          detail.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// すべての販売履歴を取得する
  Future<List<Sale>> getSalesHistory() async {
    final db = await instance.database;
    final maps = await db.query(
      'sales',
      orderBy: 'createdAt DESC',
    );
    return List.generate(
      maps.length,
      (i) => Sale.fromMap(maps[i]),
    );
  }

  /// すべての販売履歴と関連する詳細を削除する
  Future<void> deleteAllSalesHistory() async {
    final db = await instance.database;
    // 'sales'テーブルから全レコードを削除する。
    // 'sale_details'はカスケード削除される。
    await db.delete('sales');
  }

  /// 特定の販売履歴に紐づく詳細を取得する
  Future<List<SaleDetail>> getSaleDetails(
    int saleId,
  ) async {
    final db = await instance.database;
    final maps = await db.query(
      'sale_details',
      where: 'saleId = ?',
      whereArgs: [saleId],
    );
    return List.generate(
      maps.length,
      (i) => SaleDetail.fromMap(maps[i]),
    );
  }

  /// 販売のキャンセル状態を更新する
  Future<void> updateSaleCancellationStatus(
    int saleId,
    bool isCancelled,
  ) async {
    final db = await instance.database;
    await db.update(
      'sales',
      {'isCancelled': isCancelled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }

  /// 商品リストでproductsテーブルを上書きする
  Future<void> importProducts(
    List<Product> products,
  ) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // 既存のデータをすべて削除
      await txn.delete('products');
      // 新しいデータを一括で挿入
      for (final product in products) {
        await txn.insert(
          'products',
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
