import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:registore/providers/theme_provider.dart'; // 作成したProvider

class DisplaySettingsScreen extends StatelessWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 現在のテーマ設定をProviderから取得
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('ディスプレイ設定')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('テーマ設定'),
            subtitle: Text(
              _themeModeToString(themeProvider.themeMode),
            ),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('システム設定に従う'),
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                // ProviderのsetThemeメソッドを呼び出してテーマを変更
                context.read<ThemeProvider>().setTheme(
                  value,
                );
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('ライトモード'),
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeProvider>().setTheme(
                  value,
                );
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('ダークモード'),
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeProvider>().setTheme(
                  value,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 表示用のヘルパー関数
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'システム設定に従う';
      case ThemeMode.light:
        return 'ライトモード';
      case ThemeMode.dark:
        return 'ダークモード';
    }
  }
}
