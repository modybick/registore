// screens/cart/widgets/cart_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/formatter.dart';

/// カート内の商品リストを表示するウィジェット
class CartListView extends StatelessWidget {
  const CartListView({super.key});

  @override
  Widget build(BuildContext context) {
    // ConsumerウィジェットでCartProviderを監視
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        // カートが空の場合は、builderの外で定義されたchildウィジェットを表示
        // これにより、カートが空の状態のUIは再ビルドされず、パフォーマンスが向上する
        if (cart.items.isEmpty) {
          return child!;
        }
        final cartItems = cart.items.values.toList();
        return ListView.builder(
          itemCount: cartItems.length,
          itemBuilder: (ctx, i) {
            final item = cartItems[i];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: ListTile(
                title: Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    // 設定に応じて商品名の表示行数を変更
                    return Text(
                      item.name,
                      maxLines: settings.showFullName
                          ? null
                          : settings.productNameMaxLines,
                      overflow: settings.showFullName
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    );
                  },
                ),
                subtitle: Text(
                  '単価: ${formatCurrency(item.price)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 数量を減らすボタン
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Theme.of(
                          context,
                        ).colorScheme.error,
                      ),
                      onPressed: () => context
                          .read<CartProvider>()
                          .decrementItem(item.id),
                    ),
                    // 数量表示
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 数量を増やすボタン
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Theme.of(
                          context,
                        ).colorScheme.tertiary,
                      ),
                      onPressed: () => context
                          .read<CartProvider>()
                          .incrementItem(item.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      // カートが空の時に表示するウィジェット
      child: const Center(
        child: Text(
          '商品をスキャンしてください',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
