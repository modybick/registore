import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_provider.dart';
import '../../screens/settings/payment_method_list_screen.dart';
import '../../providers/product_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/csv_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../screens/settings/product/product_list_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isImporting = false;
  bool _isExporting = false;
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

  // CSVを保存
  Future<void> _runSalesSave() async {
    setState(() {
      _isExporting = true;
    });

    final salesProvider = context.read<SalesProvider>();
    if (salesProvider.sales.isEmpty) {
      await salesProvider.loadSalesHistory();
    }
    // 新しい保存メソッドを呼び出す
    final resultMessage = await _csvService
        .saveSalesHistoryAsCsv(salesProvider.sales);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultMessage)),
      );
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // SettingsProviderを監視
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // ラジオボタンの選択肢をデータとして定義 (タイトル: 値)
        final barcodeOptions = {
          '1次元バーコードのみ (JANコードなど)': BarcodeScanType.oneD,
          '2次元バーコードのみ (QRコードなど)': BarcodeScanType.twoD,
          '両方を読み取る': BarcodeScanType.both,
        };
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

              // --- バーコード種別設定 ---
              const ListTile(
                leading: Icon(Icons.barcode_reader),
                title: Text(
                  '読み取り対象バーコード',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                children: barcodeOptions.entries.map((
                  entry,
                ) {
                  return RadioListTile<BarcodeScanType>(
                    title: Text(entry.key),
                    value: entry.value,
                    groupValue: settings.barcodeScanType,
                    onChanged: (BarcodeScanType? value) {
                      if (value != null) {
                        settings.updateBarcodeScanType(
                          value,
                        );
                      }
                    },
                  );
                }).toList(),
              ),

              const Divider(height: 30),

              // --- 商品マスタの編集 ---
              ListTile(
                leading: const Icon(
                  Icons.inventory_2_outlined,
                ),
                title: const Text(
                  '商品マスタの編集',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('商品の追加、編集、削除を行います。'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ProductListScreen(),
                    ),
                  );
                },
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
              const ListTile(
                leading: Icon(Icons.history_edu_outlined),
                title: Text(
                  '販売履歴データ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'すべての販売履歴をCSVファイルとしてデバイスに保存します。',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isExporting
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton.icon(
                        // ▼▼▼ 呼び出すメソッドとテキストを変更 ▼▼▼
                        onPressed: _runSalesSave,
                        icon: const Icon(Icons.save_alt),
                        label: const Text('販売履歴をファイルに保存'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
              ),

              const Divider(height: 30),

              // --- 決済方法 ---
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text(
                  '決済方法の編集',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  '会計画面に表示する決済方法を編集します。',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PaymentMethodListScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
