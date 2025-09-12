import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:registore/providers/settings_provider.dart';
import 'package:registore/providers/theme_provider.dart'; // 作成したProvider

class BaseSettingsScreen extends StatelessWidget {
  const BaseSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 現在のテーマ設定をProviderから取得
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('基本設定')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                leading: Icon(Icons.vibration),
                title: Text(
                  'スキャン時のフィードバック',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 音量調節
              const ListTile(title: Text('効果音の音量')),
              Slider(
                value: settings.volume,
                min: 0.0, // 0% (ミュート)
                max: 1.0, // 100%
                label:
                    '${(settings.volume * 100).round()}%',
                divisions: 100,
                onChanged: (value) {
                  settings.updateVolume(value);
                },
              ),
              // バイブレーション ON/OFF
              SwitchListTile(
                title: const Text('バイブレーション'),
                subtitle: const Text('スキャン成功・失敗時に振動させます。'),
                value: settings.vibrationEnabled,
                onChanged: (value) {
                  settings.updateVibration(value);
                },
              ),

              const Divider(height: 30),

              ListTile(
                leading: Icon(Icons.brightness_6),
                title: Text(
                  'テーマ設定',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _themeModeToString(
                    themeProvider.themeMode,
                  ),
                ),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('システム設定に従う'),
                value: ThemeMode.system,
                // ignore: deprecated_member_use
                groupValue: themeProvider.themeMode,
                // ignore: deprecated_member_use
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
                // ignore: deprecated_member_use
                groupValue: themeProvider.themeMode,
                // ignore: deprecated_member_use
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
                // ignore: deprecated_member_use
                groupValue: themeProvider.themeMode,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeProvider>().setTheme(
                      value,
                    );
                  }
                },
              ),
            ],
          );
        },
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
