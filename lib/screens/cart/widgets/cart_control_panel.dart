// screens/cart/widgets/control_panel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../../../screens/payment/payment_screen.dart';
import '../../../screens/sale_history/sale_history_screen.dart';
import '../../../screens/settings/settings_screen.dart';
import '../../../utils/formatter.dart';

/// 合計金額の表示と各種操作ボタンを持つパネルウィジェット
class CartControlPanel extends StatelessWidget {
  final VoidCallback onClearCart;
  final VoidCallback onShowProductList;

  const CartControlPanel({
    super.key,
    required this.onClearCart,
    required this.onShowProductList,
  });

  @override
  Widget build(BuildContext context) {
    // Consumerウィジェットでカートの状態を監視
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final isCartEmpty = cart.items.isEmpty;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            // 上部に影をつけてコンテンツとの境界を明確にする
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
            color: Theme.of(
              context,
            ).scaffoldBackgroundColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 合計金額
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  '合計: ${formatCurrency(cart.totalAmount)}',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              // カートクリア・会計ボタン
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('カートをクリア'),
                      // カートが空の場合はボタンを無効化
                      onPressed: isCartEmpty
                          ? null
                          : onClearCart,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.error,
                        side: BorderSide(
                          color: !isCartEmpty
                              ? Theme.of(
                                  context,
                                ).colorScheme.error
                              : Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.shopping_cart_checkout,
                      ),
                      label: const Text('会計へ進む'),
                      // カートが空の場合はボタンを無効化
                      onPressed: isCartEmpty
                          ? null
                          : () => _navigateToPayment(
                              context,
                              cart,
                            ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // 下部ナビゲーションボタン
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: onShowProductList,
                    icon: const Icon(Icons.list_alt),
                    label: const Text('商品一覧'),
                  ),
                  TextButton.icon(
                    onPressed: () => _navigateTo(
                      context,
                      const SalesHistoryScreen(),
                    ),
                    icon: const Icon(Icons.history),
                    label: const Text('販売履歴'),
                  ),
                  TextButton.icon(
                    onPressed: () => _navigateTo(
                      context,
                      const SettingsScreen(),
                    ),
                    icon: const Icon(Icons.settings),
                    label: const Text('設定'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 決済画面へ遷移する
  Future<void> _navigateToPayment(
    BuildContext context,
    CartProvider cart,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          cartItems: cart.items.values.toList(),
          totalAmount: cart.totalAmount,
        ),
      ),
    );
    // 決済が完了して戻ってきた場合、カートを空にする
    // `context.mounted` は非同期処理後にウィジェットが存在するか確認するために重要
    if (result == true && context.mounted) {
      context.read<CartProvider>().clearCart();
    }
  }

  /// 指定された画面へ遷移する汎用メソッド
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
