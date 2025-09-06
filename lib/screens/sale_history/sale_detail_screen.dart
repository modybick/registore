import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:registore/providers/settings_provider.dart';
import 'package:registore/utils/formatter.dart';
import '../../models/sale_detail_model.dart';
import '../../models/sale_model.dart';
import '../../services/database_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../providers/cart_provider.dart';
import '../../providers/sales_provider.dart';

class SaleDetailScreen extends StatefulWidget {
  final Sale sale;
  const SaleDetailScreen({super.key, required this.sale});

  @override
  State<SaleDetailScreen> createState() =>
      _SaleDetailScreenState();
}

class _SaleDetailScreenState
    extends State<SaleDetailScreen> {
  // DBから詳細リストを取得するためのFuture。State内で管理する。
  late Future<List<SaleDetail>> _detailsFuture;
  late Sale _currentSale;

  @override
  void initState() {
    super.initState();

    // initStateで一度だけDBから詳細データを取得する非同期処理を開始する
    // sale.idがnullでないことを!で保証（履歴画面から来るので必ずIDはある想定）
    _detailsFuture = DatabaseService.instance
        .getSaleDetails(widget.sale.id!);
    _currentSale = widget.sale; // 初期状態をウィジェットからコピー
  }

  // カートに展開する処理
  void _expandToCart(List<SaleDetail> details) {
    context.read<CartProvider>().overwriteCartWithDetails(
      details,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('商品をカートに展開しました。'),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 1500),
      ),
    );
    // カート画面まで戻る
    Navigator.of(
      context,
    ).popUntil((route) => route.isFirst);
  }

  // 販売を取り消す/元に戻す処理
  void _toggleCancellation() async {
    await context
        .read<SalesProvider>()
        .toggleSaleCancellation(_currentSale);

    // await の直後に、ウィジェットがまだ存在するかをチェックする
    if (!mounted) return;

    // チェックの後で、安全に setState や scaffoldMessenger を使う
    setState(() {
      _currentSale = _currentSale.copyWith(
        isCancelled: !_currentSale.isCancelled,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentSale.isCancelled
              ? 'この販売履歴を取り消しました。'
              : '取り消しを元に戻しました。',
        ),
        backgroundColor: _currentSale.isCancelled
            ? Colors.red
            : Colors.blue,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('販売履歴詳細')),
      // FutureBuilderを使って非同期処理の結果に応じてUIを構築する
      body: FutureBuilder<List<SaleDetail>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          // --- データロード中の表示 ---
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // --- エラーが発生した場合の表示 ---
          if (snapshot.hasError) {
            return Center(
              child: Text('エラーが発生しました: ${snapshot.error}'),
            );
          }
          // --- データがない、または空の場合の表示 ---
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('詳細データが見つかりません。'),
            );
          }

          // --- 正常にデータが取得できた場合の表示 ---
          final details = snapshot.data!;
          // 合計点数を計算
          final totalItems = details.fold(
            0,
            (sum, item) => sum + item.quantity,
          );
          // 日付をフォーマット
          final formattedDate = DateFormat(
            'yyyy/MM/dd HH:mm',
          ).format(widget.sale.createdAt);

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Column(
              children: [
                if (_currentSale.isCancelled)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red[100],
                    child: const Text(
                      'この販売は取り消し済みです',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // --- 販売日時の表示 ---
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '販売日時: $formattedDate',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium,
                  ),
                ),

                // --- 商品リスト (payment_screenからUIを流用) ---
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(
                        8.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        // ヘッダー
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 16.0,
                              ),
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  '商品名',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '数量',
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '小計',
                                  textAlign:
                                      TextAlign.right,
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // リスト本体
                        Expanded(
                          child: ListView.separated(
                            itemCount: details.length,
                            separatorBuilder:
                                (context, index) =>
                                    const Divider(
                                      height: 1,
                                      indent: 8.0,
                                      endIndent: 8.0,
                                    ),
                            itemBuilder: (context, index) {
                              final item = details[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 16.0,
                                    ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Consumer<SettingsProvider>(
                                        builder:
                                            (
                                              context,
                                              settings,
                                              child,
                                            ) {
                                              return Text(
                                                item.productName,
                                                maxLines:
                                                    settings
                                                        .showFullName
                                                    ? null
                                                    : settings
                                                          .productNameMaxLines,
                                                overflow:
                                                    settings
                                                        .showFullName
                                                    ? TextOverflow
                                                          .visible
                                                    : TextOverflow
                                                          .ellipsis,
                                              );
                                            },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${item.quantity}',
                                        textAlign: TextAlign
                                            .center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        formatCurrency(
                                          item.price *
                                              item.quantity,
                                        ),
                                        textAlign:
                                            TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // --- 金額サマリー (payment_screenからUIを流用) ---
                _buildSummaryCard(totalItems),
                const Spacer(),
                _buildActionButtons(details),
              ],
            ),
          );
        },
      ),
    );
  }

  // 金額サマリーを表示するヘルパーウィジェット
  Widget _buildSummaryCard(int totalItems) {
    final sale = widget.sale;
    final changeAmount =
        sale.tenderedAmount - sale.totalAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow(
              '合計金額 ($totalItems点)',
              sale.totalAmount,
            ),
            _buildSummaryRow('お預かり', sale.tenderedAmount),
            _buildSummaryRow(
              'お釣り',
              changeAmount,
              isEmphasized: true,
            ),
            const Divider(height: 20),
            _buildSummaryRow(
              '支払方法',
              null,
              valueText: sale.paymentMethod,
            ),
          ],
        ),
      ),
    );
  }

  // 金額表示行を生成するヘルパーウィジェット
  Widget _buildSummaryRow(
    String label,
    double? amount, {
    bool isEmphasized = false,
    String? valueText,
  }) {
    final textStyle = TextStyle(
      fontSize: isEmphasized ? 22 : 18,
      fontWeight: isEmphasized
          ? FontWeight.bold
          : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(
            valueText ?? formatCurrency(amount ?? 0),
            style: textStyle.copyWith(
              color: isEmphasized ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  // ボタンを生成するヘルパーウィジェット
  Widget _buildActionButtons(List<SaleDetail> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 内容をカートに展開ボタン
        ElevatedButton.icon(
          onPressed: () => _expandToCart(details),
          icon: const Icon(Icons.shopping_cart),
          label: const Text('内容をカートに展開'),
        ),
        const SizedBox(height: 8),
        // この販売履歴を取り消す/元に戻すボタン
        OutlinedButton.icon(
          onPressed: _toggleCancellation,
          icon: Icon(
            _currentSale.isCancelled
                ? Icons.undo
                : Icons.cancel_outlined,
          ),
          label: Text(
            _currentSale.isCancelled
                ? '取り消しを元に戻す'
                : 'この販売履歴を取り消す',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _currentSale.isCancelled
                ? Colors.blue
                : Colors.red,
            side: BorderSide(
              color: _currentSale.isCancelled
                  ? Colors.blue
                  : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
