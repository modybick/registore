// screens/sale_detail/widgets/sale_summary_card.dart

import 'package:flutter/material.dart';
import '../../../models/sale_model.dart';
import '../../../utils/formatter.dart';

/// 販売の金額サマリーを表示するカードウィジェット
class SaleSummaryCard extends StatelessWidget {
  final Sale sale;
  final int totalItems;

  const SaleSummaryCard({
    super.key,
    required this.sale,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final changeAmount =
        sale.tenderedAmount - sale.totalAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow(
              context,
              '支払方法',
              null,
              valueText: sale.paymentMethod,
            ),
            const Divider(height: 20),
            _buildSummaryRow(
              context,
              '合計金額 ($totalItems点)',
              sale.totalAmount,
              isEmphasized: true,
            ),
            _buildSummaryRow(
              context,
              'お預かり',
              sale.tenderedAmount,
            ),
            _buildSummaryRow(context, 'お釣り', changeAmount),
          ],
        ),
      ),
    );
  }

  /// 金額表示の各行を生成する
  Widget _buildSummaryRow(
    BuildContext context,
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(
            valueText ?? formatCurrency(amount ?? 0),
            style: textStyle.copyWith(
              color: isEmphasized
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
