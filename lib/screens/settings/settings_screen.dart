import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/csv_service.dart';
import '../../widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isImporting = false;
  final CsvService _csvService = CsvService();

  // CSVインポート処理
  Future<void> _runImport() async {
    setState(() {
      _isImporting = true;
    });

    final resultMessage = await _csvService
        .importProductsFromCsv();

    // インポートが成功したら、ProductProviderに商品リストを再読み込みさせる
    if (resultMessage.startsWith('成功')) {
      // ignore: use_build_context_synchronously
      await context
          .read<ProductProvider>()
          .reloadProducts();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultMessage)),
      );
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // SettingsProviderを監視
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return AppScaffold(
          appBar: AppBar(title: const Text('設定')),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- バーコード読み取り間隔 ---
              const ListTile(
                leading: Icon(Icons.timer_outlined),
                title: Text(
                  'バーコード連続読み取り間隔',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
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
                        value: settings.scanInterval,
                        min: 0.1,
                        max: 5.0,
                        divisions:
                            49, // (5.0 - 0.1) / 0.1 = 49分割
                        label:
                            '${settings.scanInterval.toStringAsFixed(1)} 秒',
                        onChanged: (value) {
                          settings.updateScanInterval(
                            value,
                          );
                        },
                      ),
                    ),
                    Text(
                      '${settings.scanInterval.toStringAsFixed(1)} 秒',
                    ),
                  ],
                ),
              ),
              const Divider(height: 30),

              // --- 商品DBのインポート ---
              const ListTile(
                leading: Icon(Icons.storage_outlined),
                title: Text(
                  '商品データベース',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'CSVファイルから商品マスタを取り込みます。既存のデータは上書きされます。',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isImporting
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton.icon(
                        onPressed: _runImport,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('CSVファイルを取り込む'),
                      ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Text(
                  'CSVフォーマット:\n1列目: バーコード (文字列)\n2列目: 商品名 (文字列)\n3列目: 価格 (整数)\n4列目: カテゴリ (文字列)\n\n※1行目はヘッダー行として無視されます。',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
