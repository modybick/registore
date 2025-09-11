// screens/payment/widgets/payment_items_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/cart_item_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/formatter.dart';

/// 会計対象の商品リストを表示するウィジェット
class PaymentItemsListView extends StatelessWidget {
  final List<CartItem> cartItems;

  const PaymentItemsListView({
    super.key,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: cartItems.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildListItem(
                context,
                cartItems[index],
              );
            },
          ),
        ),
      ],
    );
  }

  /// リストのヘッダー
  Widget _buildHeader() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 5,
            child: Text('商品名', style: headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '数量',
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '小計',
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
        ],
      ),
    );
  }

  /// リストの各行
  Widget _buildListItem(
    BuildContext context,
    CartItem item,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Consumer<SettingsProvider>(
              builder: (context, settings, _) {
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
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formatCurrency(item.price * item.quantity),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
