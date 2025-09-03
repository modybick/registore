import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/sale_detail_model.dart';
import '../models/sale_model.dart';
import '../models/payment_method_model.dart';

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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT UNIQUE,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        category TEXT,
        imagePath TEXT
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
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        price INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (saleId) REFERENCES sales (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE payment_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    _insertDefaultPaymentMethods(db); //デフォルトの決済方法を挿入
  }

  // --- 商品関連のメソッド ---

  // 商品をDBに追加
  Future<void> addProduct(Product product) async {
    final db = await instance.database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // 商品DBを更新
  Future<void> updateProduct(Product product) async {
    final db = await instance.database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // 商品をDBから削除
  Future<void> deleteProduct(int id) async {
    final db = await instance.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

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

  /// 指定されたバーコードの商品が既に存在するかをチェックする
  Future<bool> productExists(String barcode) async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      columns: ['barcode'],
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1, // 1件見つかれば十分なので、検索を効率化
    );
    return maps.isNotEmpty;
  }

  /// 指定されたID以外の商品で、そのバーコードが既に使用されているかをチェックする
  Future<bool> isBarcodeTakenByAnotherProduct(
    String barcode,
    int currentId,
  ) async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      columns: ['id'],
      // barcodeが一致し、かつidが異なるレコードを探す
      where: 'barcode = ? AND id != ?',
      whereArgs: [barcode, currentId],
      limit: 1,
    );
    return maps.isNotEmpty;
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
          productId: item.id,
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

  // --- 決済方法関連 ---

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final db = await instance.database;
    final maps = await db.query(
      'payment_methods',
      orderBy: 'id ASC',
    );
    return List.generate(
      maps.length,
      (i) => PaymentMethod.fromMap(maps[i]),
    );
  }

  Future<void> addPaymentMethod(String name) async {
    final db = await instance.database;
    await db.insert(
      'payment_methods',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePaymentMethod(
    int id,
    String newName,
  ) async {
    final db = await instance.database;
    await db.update(
      'payment_methods',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePaymentMethod(int id) async {
    final db = await instance.database;
    await db.delete(
      'payment_methods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //デフォルトの決済方法を挿入
  void _insertDefaultPaymentMethods(Database db) {
    final defaultMethods = ['現金', 'クレジットカード', 'QRコード'];
    for (var name in defaultMethods) {
      db.insert(
        'payment_methods',
        {'name': name},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
