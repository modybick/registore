import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode =
      ThemeMode.system; // デフォルトはシステム設定に従う
  static const String _themePreferenceKey = 'theme_mode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme(); // アプリ起動時に保存された設定を読み込む
  }

  // 設定を読み込むメソッド
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex =
        prefs.getInt(_themePreferenceKey) ??
        0; // 保存されてなければ0 (system)
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  // 設定を保存し、UIに通知するメソッド
  Future<void> setTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return; // 同じ設定なら何もしない

    _themeMode = themeMode;
    notifyListeners(); // UIに変更を通知

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _themePreferenceKey,
      themeMode.index,
    ); // 選択されたテーマを保存
  }
}
