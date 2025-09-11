// screens/payment/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item_model.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/sales_provider.dart';
import '../../utils/formatter.dart';
import '../../widgets/app_scaffold.dart';
import 'widgets/complete_payment_button.dart';
import 'widgets/payment_items_list_view.dart';
import 'widgets/payment_method_selector.dart';
import 'widgets/payment_summary_section.dart';

/// 会計画面
class PaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _tenderedController = TextEditingController();
  double _changeAmount = 0.0;
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tenderedController.addListener(_calculateChange);
    _loadDefaultPaymentMethod();
  }

  @override
  void dispose() {
    _tenderedController.removeListener(_calculateChange);
    _tenderedController.dispose();
    super.dispose();
  }

  /// Providerから支払い方法をロードし、デフォルト値を設定する
  void _loadDefaultPaymentMethod() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context
          .read<PaymentMethodProvider>();
      provider.loadMethods().then((_) {
        if (!mounted) return;
        if (provider.methods.isNotEmpty) {
          setState(
            () => _selectedPaymentMethod =
                provider.methods.first.name,
          );
        } else {
          setState(() => _selectedPaymentMethod = 'なし');
        }
      });
    });
  }

  /// お預かり金額の入力に応じてお釣りを計算する
  void _calculateChange() {
    final tenderedString = _tenderedController.text
        .replaceAll(',', '');
    final tenderedAmount =
        double.tryParse(tenderedString) ?? 0.0;
    setState(() {
      _changeAmount = tenderedAmount - widget.totalAmount;
    });
  }

  /// お預かり金額に合計金額と同額をセットする
  void _setSameAmount() {
    _tenderedController.text = formatCurrency(
      widget.totalAmount,
    ).replaceAll('¥', '');
    FocusScope.of(context).unfocus(); // 金額セット後にキーボードを閉じる
  }

  /// 会計を完了する処理
  Future<void> _completePayment() async {
    if (_selectedPaymentMethod == null) {
      _showErrorSnackBar('支払方法を選択してください');
      return;
    }

    setState(() => _isProcessing = true);

    final tenderedString = _tenderedController.text
        .replaceAll(',', '');
    final tenderedAmount =
        double.tryParse(tenderedString) ?? 0.0;

    // SalesProviderを呼び出して販売履歴をDBに保存
    await context.read<SalesProvider>().addSale(
      items: widget.cartItems,
      totalAmount: widget.totalAmount,
      tenderedAmount: tenderedAmount,
      paymentMethod: _selectedPaymentMethod!,
    );

    // 会計成功を伝えながら前の画面（カート画面）に戻る
    if (mounted) Navigator.pop(context, true);
  }

  /// エラーメッセージ用のSnackBarを表示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenderedAmount =
        double.tryParse(
          _tenderedController.text.replaceAll(',', ''),
        ) ??
        0.0;
    final isPaymentEnabled =
        tenderedAmount > 0 &&
        _changeAmount >= 0 &&
        !_isProcessing;

    return AppScaffold(
      appBar: AppBar(title: const Text('お会計')),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            // 会計対象の商品リスト
            Expanded(
              child: PaymentItemsListView(
                cartItems: widget.cartItems,
              ),
            ),
            const Divider(thickness: 2),

            // 金額サマリー（合計、お預かり、お釣り）
            PaymentSummarySection(
              totalAmount: widget.totalAmount,
              changeAmount: _changeAmount,
              tenderedController: _tenderedController,
              onSetSameAmount: _setSameAmount,
              totalItems: widget.cartItems.fold(
                0,
                (sum, item) => sum + item.quantity,
              ),
            ),

            // 支払方法の選択
            PaymentMethodSelector(
              selectedMethod: _selectedPaymentMethod,
              onMethodSelected: (method) {
                setState(
                  () => _selectedPaymentMethod = method,
                );
              },
            ),

            // 会計完了ボタン
            CompletePaymentButton(
              isEnabled: isPaymentEnabled,
              isProcessing: _isProcessing,
              onPressed: _completePayment,
            ),
          ],
        ),
      ),
    );
  }
}
