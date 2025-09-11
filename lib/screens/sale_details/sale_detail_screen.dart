// screens/sale_detail/sale_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:registore/models/sale_detail_model.dart';

import '../../models/sale_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/sales_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/app_scaffold.dart';
import 'widgets/sale_details_action_buttons.dart';
import 'widgets/sale_details_list_view.dart';
import 'widgets/sale_summary_card.dart';

/// 販売履歴詳細画面
class SaleDetailScreen extends StatefulWidget {
  final Sale sale;
  const SaleDetailScreen({super.key, required this.sale});

  @override
  State<SaleDetailScreen> createState() =>
      _SaleDetailScreenState();
}

class _SaleDetailScreenState
    extends State<SaleDetailScreen> {
  // DBから詳細リストを取得するためのFuture
  late Future<List<SaleDetail>> _detailsFuture;
  // キャンセル状態をUIに反映させるためのローカルState
  late Sale _currentSale;

  @override
  void initState() {
    super.initState();
    // 最初に一度だけDBからデータを取得する
    _detailsFuture = DatabaseService.instance
        .getSaleDetails(widget.sale.id!);
    // キャンセル状態を更新できるように、State変数にコピー
    _currentSale = widget.sale;
  }

  /// 履歴の内容を現在のカートに上書きで展開する
  void _expandToCart(List<SaleDetail> details) {
    context.read<CartProvider>().overwriteCartWithDetails(
      details,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('商品をカートに展開しました。'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.tertiary,
      ),
    );
    // カート画面（最初の画面）まで一気に戻る
    Navigator.of(
      context,
    ).popUntil((route) => route.isFirst);
  }

  /// 販売のキャンセル状態をトグルする
  Future<void> _toggleCancellation() async {
    // Provider経由でDBのデータを更新
    await context
        .read<SalesProvider>()
        .toggleSaleCancellation(_currentSale);

    // 非同期処理後にウィジェットが破棄されている可能性を考慮
    if (!mounted) return;

    // UIの状態を更新
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
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('販売履歴詳細')),
      body: FutureBuilder<List<SaleDetail>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          // データロード中
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // エラー発生
          if (snapshot.hasError) {
            return Center(
              child: Text('エラーが発生しました: ${snapshot.error}'),
            );
          }
          // データなし
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('詳細データが見つかりません。'),
            );
          }

          // --- データ取得成功 ---
          final details = snapshot.data!;
          final totalItems = details.fold(
            0,
            (sum, item) => sum + item.quantity,
          );
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
                // キャンセル済みの場合に表示するバナー
                if (_currentSale.isCancelled)
                  _buildCancelledBanner(context),

                // 販売日時
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '販売日時: $formattedDate',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium,
                  ),
                ),

                // 商品リスト（子ウィジェット）
                Expanded(
                  child: SaleDetailsListView(
                    details: details,
                  ),
                ),

                const SizedBox(height: 8),

                // 金額サマリー（子ウィジェット）
                SaleSummaryCard(
                  sale: widget.sale,
                  totalItems: totalItems,
                ),

                // 操作ボタン（子ウィジェット）
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SaleDetailsActionButtons(
                    sale: _currentSale,
                    onExpandToCart: () =>
                        _expandToCart(details),
                    onToggleCancellation:
                        _toggleCancellation,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// キャンセル済みバナーを生成する
  Widget _buildCancelledBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).colorScheme.error,
      child: Text(
        'この販売は取り消し済みです',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
