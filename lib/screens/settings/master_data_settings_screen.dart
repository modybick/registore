import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:registore/providers/product_provider.dart';
import 'package:registore/providers/sales_provider.dart';

import '../../services/csv_service.dart';
import '../../widgets/app_scaffold.dart';
import 'payment_method_list_screen.dart';
import 'product_list_screen.dart';

class MasterDataSettingsScreen extends StatefulWidget {
  const MasterDataSettingsScreen({super.key});
  @override
  State<MasterDataSettingsScreen> createState() =>
      _MasterDataSettingsScreenState();
}

class _MasterDataSettingsScreenState
    extends State<MasterDataSettingsScreen> {
  // 処理ステータス
  bool _isImporting = false;
  bool _isSalesExporting = false;
  bool _isProductsExporting = false;
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
        SnackBar(
          content: Text(resultMessage),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _isImporting = false;
      });
    }
  }

  // 販売履歴CSVを保存
  Future<void> _runSalesSave() async {
    setState(() {
      _isSalesExporting = true;
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
        SnackBar(
          content: Text(resultMessage),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _isSalesExporting = false;
      });
    }
  }

  // 商品マスタをCSV保存
  Future<void> _runProductsSave() async {
    setState(() {
      _isProductsExporting = true;
    });

    final productProvider = context.read<ProductProvider>();
    if (productProvider.products.isEmpty) {
      await productProvider.loadProducts();
    }
    // 新しい保存メソッドを呼び出す
    final resultMessage = await _csvService
        .saveProductsAsCsv(productProvider.products);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultMessage),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _isProductsExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('マスタ設定')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- 商品マスタ ---
          const ListTile(
            title: Text(
              '商品マスタ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('商品マスタの編集'),
            subtitle: const Text('商品の追加、編集、削除を行います。'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductListScreen(),
              ),
            ),
          ),
          ListTile(
            leading: _isImporting
                ? const CircularProgressIndicator()
                : const Icon(Icons.upload_file),
            title: const Text('商品マスタをCSVで取り込む'),
            subtitle: const Text('既存のデータは上書きされます。'),
            onTap: _isImporting ? null : _runImport,
          ),
          ListTile(
            leading: _isProductsExporting
                ? const CircularProgressIndicator()
                : const Icon(Icons.save_alt),
            title: const Text('商品マスタをCSVで保存'),
            subtitle: const Text('商品マスタをファイルに保存します。'),
            onTap: _isProductsExporting
                ? null
                : _runProductsSave,
          ),
          const Divider(height: 30),

          // --- 決済方法マスタ ---
          const ListTile(
            title: Text(
              '決済方法マスタ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('決済方法の編集'),
            subtitle: const Text('会計画面に表示する決済方法を編集します。'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const PaymentMethodListScreen(),
              ),
            ),
          ),
          const Divider(height: 30),

          // --- データ管理 ---
          const ListTile(
            title: Text(
              'データ管理',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          ListTile(
            leading: _isSalesExporting
                ? const CircularProgressIndicator()
                : const Icon(Icons.save_alt),
            title: const Text('販売履歴をCSVで保存'),
            subtitle: const Text('すべての販売履歴をファイルに保存します。'),
            onTap: _isSalesExporting ? null : _runSalesSave,
          ),
        ],
      ),
    );
  }
}
