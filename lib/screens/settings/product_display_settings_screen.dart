import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_scaffold.dart';

class ProductDisplaySettingsScreen extends StatelessWidget {
  const ProductDisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('商品一覧表示設定')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- 全文表示チェックボックス ---
              SwitchListTile(
                title: const Text(
                  '長い商品名を全文表示する',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'OFFにすると、下の設定行数で折り返して表示されます。',
                ),
                value: settings.showFullName,
                onChanged: (bool? value) {
                  if (value != null) {
                    settings.updateShowFullName(value);
                  }
                },
              ),

              // --- ▼▼▼ 表示行数設定スライダー ▼▼▼ ---
              Opacity(
                opacity: settings.showFullName ? 0.4 : 1.0,
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(
                        Icons.format_line_spacing,
                      ),
                      title: Text('最大表示行数'),
                      subtitle: Text(
                        '「全文表示」がOFFのときに適用されます。',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: settings
                                  .productNameMaxLines
                                  .toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4, // 5 - 1 = 4分割
                              label:
                                  '${settings.productNameMaxLines} 行',
                              onChanged:
                                  settings.showFullName
                                  ? null // 全文表示がONなら無効化
                                  : (value) {
                                      settings
                                          .updateProductNameMaxLines(
                                            value.round(),
                                          );
                                    },
                            ),
                          ),
                          Text(
                            '${settings.productNameMaxLines} 行',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              SwitchListTile(
                title: const Text(
                  'バーコードなしタブを表示',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  '商品一覧に「バーコードなし」商品をまとめたタブを追加します',
                ),
                value: settings.showNoBarcodeTab,
                onChanged: (newValue) {
                  // Providerのメソッドを呼び出して設定を更新
                  context
                      .read<SettingsProvider>()
                      .updateShowNoBarcodeTab(newValue);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
