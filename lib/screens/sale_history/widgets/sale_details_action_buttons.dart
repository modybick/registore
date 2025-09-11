// screens/sale_detail/widgets/sale_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:registore/models/sale_model.dart';

/// 販売詳細画面の操作ボタン群ウィジェット
class SaleDetailsActionButtons extends StatelessWidget {
  final Sale sale;
  final VoidCallback onExpandToCart;
  final VoidCallback onToggleCancellation;

  const SaleDetailsActionButtons({
    super.key,
    required this.sale,
    required this.onExpandToCart,
    required this.onToggleCancellation,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = sale.isCancelled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 内容をカートに展開ボタン
        ElevatedButton.icon(
          onPressed: onExpandToCart,
          icon: const Icon(Icons.shopping_cart_outlined),
          label: const Text('内容をカートに展開'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // この販売履歴を取り消す/元に戻すボタン
        OutlinedButton.icon(
          onPressed: onToggleCancellation,
          icon: Icon(
            isCancelled
                ? Icons.undo
                : Icons.cancel_outlined,
          ),
          label: Text(
            isCancelled ? '取り消しを元に戻す' : 'この販売履歴を取り消す',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: isCancelled
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.error,
            side: BorderSide(
              color: isCancelled
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.error,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
