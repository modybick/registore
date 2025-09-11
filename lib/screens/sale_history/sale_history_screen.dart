import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:registore/utils/formatter.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../sale_details/sale_detail_screen.dart';
import '../../services/csv_service.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() =>
      _SalesHistoryScreenState();
}

class _SalesHistoryScreenState
    extends State<SalesHistoryScreen> {
  bool _isExporting = false;
  final CsvService _csvService = CsvService();

  // エクスポート処理
  Future<void> _runCsvSave() async {
    setState(() {
      _isExporting = true;
    });

    // Providerから現在表示されている販売履歴リストを取得
    final sales = context.read<SalesProvider>().sales;
    final resultMessage = await _csvService
        .saveSalesHistoryAsCsv(sales);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultMessage),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      setState(() {
        _isExporting = false;
      });
    }
  }

  /// 全削除の確認ダイアログを表示する
  void _showDeleteConfirmationDialog() {
    bool isChecked = false;
    showDialog(
      context: context,
      barrierDismissible: false, // ダイアログの外側をタップしても閉じないようにする
      builder: (BuildContext dialogContext) {
        // ダイアログ内のチェックボックスの状態を管理するためにStatefulBuilderを使う
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('最終確認'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'すべての販売履歴を完全に削除します。\nこの操作は元に戻すことはできません。',
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text('上記を理解し、削除に同意します。'),
                    value: isChecked,
                    onChanged: (bool? value) {
                      // チェックボックスの状態を更新
                      setDialogState(() {
                        isChecked = value ?? false;
                      });
                    },
                    controlAffinity:
                        ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(); // ダイアログを閉じる
                  },
                ),
                // チェックボックスがONの場合のみ、削除ボタンを有効化する
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isChecked
                        ? Theme.of(
                            context,
                          ).colorScheme.error
                        : Colors.grey,
                  ),
                  onPressed: isChecked
                      ? () async {
                          // 削除処理を実行
                          // 1. awaitの前に、contextに依存するオブジェクトを変数に確保する
                          final salesProvider = context
                              .read<SalesProvider>();
                          final navigator = Navigator.of(
                            dialogContext,
                          );
                          // ScaffoldMessengerは、元の画面(this.context)から取得
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(
                                this.context,
                              );

                          // 2. 非同期処理を実行
                          await salesProvider
                              .clearAllSalesHistory();

                          // 3. awaitの後では、確保しておいた変数を使う
                          //    (contextを直接使わない)

                          // まずダイアログを閉じる
                          navigator.pop();

                          if (!context.mounted) return;

                          // 元の画面がまだ存在することを確認してからスナックバーを表示
                          if (scaffoldMessenger.mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'すべての販売履歴を削除しました。',
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                duration: Duration(
                                  milliseconds: 1500,
                                ),
                              ),
                            );
                          }
                        }
                      : null, // isCheckedがfalseならボタンを無効化
                  child: const Text('削除実行'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 履歴削除

  @override
  void initState() {
    super.initState();
    // 画面表示時に販売履歴をロードする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().loadSalesHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('販売履歴'),
        actions: [
          // 履歴削除ボタン
          IconButton(
            onPressed: _showDeleteConfirmationDialog,
            icon: const Icon(Icons.delete),
            tooltip: '履歴削除',
          ),

          // エクスポート処理中はボタンを無効化、またはインジケーターを表示
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'CSV保存',
              onPressed: _runCsvSave,
            ),
        ],
      ),
      body: Consumer<SalesProvider>(
        builder: (context, salesProvider, child) {
          if (salesProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (salesProvider.sales.isEmpty) {
            return const Center(child: Text('販売履歴がありません。'));
          }
          return ListView.separated(
            itemCount: salesProvider.sales.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final sale = salesProvider.sales[index];
              final formattedDate = DateFormat(
                'yyyy/MM/dd HH:mm',
              ).format(sale.createdAt);

              // 取り消し状態に応じてスタイルを決定
              final bool isCancelled = sale.isCancelled;
              final textStyle = TextStyle(
                color: isCancelled ? Colors.grey : null,
                decoration: isCancelled
                    ? TextDecoration.lineThrough
                    : null,
              );
              final amountStyle = TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCancelled ? Colors.grey : null,
                decoration: isCancelled
                    ? TextDecoration.lineThrough
                    : null,
              );

              return ListTile(
                title: Text(
                  formattedDate,
                  style: textStyle,
                ),
                subtitle: Text(
                  '支払方法: ${sale.paymentMethod}',
                  style: textStyle,
                ),
                trailing: Text(
                  formatCurrency(sale.totalAmount),
                  style: amountStyle,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SaleDetailScreen(sale: sale),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
