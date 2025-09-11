// screens/payment/widgets/payment_method_selector.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/payment_method_provider.dart';

/// 支払方法を選択するための横スクロール可能なチップリスト
class PaymentMethodSelector extends StatelessWidget {
  final String? selectedMethod;
  final ValueChanged<String?> onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Consumer<PaymentMethodProvider>(
        builder: (context, provider, child) {
          if (provider.methods.isEmpty) {
            return const SizedBox(
              height: 50.0,
              child: Center(child: Text('支払方法が設定されていません')),
            );
          }
          return SizedBox(
            height: 50.0,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: provider.methods.map((method) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                    ),
                    child: ChoiceChip(
                      label: Text(method.name),
                      selected:
                          selectedMethod == method.name,
                      onSelected: (selected) {
                        if (selected)
                          onMethodSelected(method.name);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
