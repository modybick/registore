import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BarcodeScanType {
  oneD, // 1次元バーコードのみ
  twoD, // 2次元バーコードのみ
  both, // 両方
}

class SettingsProvider with ChangeNotifier {
  // スキャン間隔
  double _scanInterval = 2.0;
  double get scanInterval => _scanInterval;
  static const String _scanIntervalKey = 'scan_interval';

  // バーコード種別
  BarcodeScanType _barcodeScanType =
      BarcodeScanType.both; // デフォルトは「両方」
  BarcodeScanType get barcodeScanType => _barcodeScanType;
  static const String _barcodeTypeKey = 'barcode_scan_type';

  // 商品名表示行数設定
  bool _showFullName = false;
  bool get showFullName => _showFullName;
  static const String _showFullNameKey = 'show_full_name';

  int _productNameMaxLines = 1; // デフォルトは1行
  int get productNameMaxLines => _productNameMaxLines;
  static const String _productNameMaxLinesKey =
      'product_name_max_lines';

  SettingsProvider() {
    // Providerが作成されたときに、保存された設定値をロードする
    loadSettings();
  }

  /// アプリ起動時に保存された設定値を読み込む
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // スキャン間隔
    _scanInterval =
        prefs.getDouble(_scanIntervalKey) ?? 2.0;

    // バーコード種別
    final savedTypeIndex =
        prefs.getInt(_barcodeTypeKey) ??
        BarcodeScanType.both.index;
    _barcodeScanType =
        BarcodeScanType.values[savedTypeIndex];

    // 商品名表示行数設定
    _showFullName =
        prefs.getBool(_showFullNameKey) ?? false;
    _productNameMaxLines =
        prefs.getInt(_productNameMaxLinesKey) ?? 1;

    notifyListeners();
  }

  /// スキャン間隔を更新し、デバイスに保存する
  Future<void> updateScanInterval(
    double newInterval,
  ) async {
    _scanInterval = newInterval;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_scanIntervalKey, newInterval);
  }

  // バーコード種別を更新し保存
  Future<void> updateBarcodeScanType(
    BarcodeScanType newType,
  ) async {
    _barcodeScanType = newType;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    // enumのindex(整数)を保存する
    await prefs.setInt(_barcodeTypeKey, newType.index);
  }

  /// MobileScannerに渡すための、有効なバーコードフォーマットのリストを生成するゲッター
  List<BarcodeFormat> get activeBarcodeFormats {
    switch (_barcodeScanType) {
      case BarcodeScanType.oneD:
        // 主要な1次元バーコードフォーマットを列挙
        return [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.itf,
        ];
      case BarcodeScanType.twoD:
        // 主要な2次元バーコードフォーマットを列挙
        return [
          BarcodeFormat.qrCode,
          BarcodeFormat.dataMatrix,
          BarcodeFormat.aztec,
          BarcodeFormat.pdf417,
        ];
      case BarcodeScanType.both:
        // すべてのフォーマットを対象
        return [BarcodeFormat.all];
    }
  }

  // 商品名省略設定を更新する
  Future<void> updateShowFullName(bool newValue) async {
    _showFullName = newValue;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showFullNameKey, newValue);
  }

  // 商品名表示行数を更新する
  Future<void> updateProductNameMaxLines(
    int newMaxLines,
  ) async {
    _productNameMaxLines = newMaxLines;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _productNameMaxLinesKey,
      newMaxLines,
    );
  }
}
