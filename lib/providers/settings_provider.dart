import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // デフォルト値は2.0秒
  double _scanInterval = 2.0;

  double get scanInterval => _scanInterval;

  // SharedPreferencesのキー
  static const String _scanIntervalKey = 'scan_interval';

  SettingsProvider() {
    // Providerが作成されたときに、保存された設定値をロードする
    loadSettings();
  }

  /// アプリ起動時に保存された設定値を読み込む
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // もし値が保存されていればそれを使い、なければデフォルト値(2.0)を使う
    _scanInterval =
        prefs.getDouble(_scanIntervalKey) ?? 2.0;
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
}
