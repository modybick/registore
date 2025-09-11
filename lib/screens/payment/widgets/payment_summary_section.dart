// screens/payment/widgets/payment_summary_section.dart

import 'package:flutter/material.dart';
import 'package:registore/utils/currency_input_formatter.dart';
import '../../../utils/formatter.dart';

/// 金額サマリー（合計、お預かり、お釣り）を表示するウィジェット
class PaymentSummarySection extends StatelessWidget {
  final double totalAmount;
  final double changeAmount;
  final int totalItems;
  final TextEditingController tenderedController;
  final VoidCallback onSetSameAmount;

  const PaymentSummarySection({
    super.key,
    required this.totalAmount,
    required this.changeAmount,
    required this.totalItems,
    required this.tenderedController,
    required this.onSetSameAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummaryRow(
          context,
          '合計金額 ($totalItems点)',
          totalAmount,
        ),
        _buildTenderedRow(context), // お預かり行は専用のメソッドに
        _buildSummaryRow(
          context,
          'お釣り',
          changeAmount < 0 ? 0 : changeAmount,
          isEmphasized: true,
        ),
      ],
    );
  }

  /// 「合計」と「お釣り」の行を生成する
  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double amount, {
    bool isEmphasized = false,
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
            formatCurrency(amount),
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

  /// 「お預かり」金額の入力行を生成する
  Widget _buildTenderedRow(BuildContext context) {
    const textStyle = TextStyle(fontSize: 18);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('お預かり', style: textStyle),
          Row(
            children: [
              FilledButton(
                onPressed: onSetSameAmount,
                child: const Text('同額'),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: tenderedController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: textStyle,
                  inputFormatters: [
                    CurrencyInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: '金額を入力',
                  ),
                  onSubmitted: (_) =>
                      FocusScope.of(context).unfocus(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
