import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:registore/providers/payment_method_provider.dart';
import 'package:registore/utils/formatter.dart';
import '../../models/cart_item_model.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/app_scaffold.dart';

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
  String? _selectedPaymentMethod; // デフォルトの支払方法
  bool _isProcessing = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 預かり金額が入力されたら、お釣りを自動計算するリスナーを設定
    _tenderedController.addListener(_calculateChange);
    // 画面初期化時に決済方法をロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<PaymentMethodProvider>()
          .loadMethods()
          .then((_) {
            // ロード後、最初の決済方法をデフォルトで選択状態にする
            if (mounted) {
              final provider = context
                  .read<PaymentMethodProvider>();
              if (provider.methods.isNotEmpty) {
                setState(() {
                  _selectedPaymentMethod =
                      provider.methods.first.name;
                });
              }
            }
          });
    });
  }

  @override
  void dispose() {
    _tenderedController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    final tenderedAmount =
        double.tryParse(_tenderedController.text) ?? 0.0;
    setState(() {
      _changeAmount = tenderedAmount - widget.totalAmount;
    });
  }

  // 会計を完了する処理
  Future<void> _completePayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('支払方法を選択してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final tenderedAmount =
        double.tryParse(_tenderedController.text) ?? 0.0;

    // SalesProviderを呼び出して販売履歴を保存
    await context.read<SalesProvider>().addSale(
      items: widget.cartItems,
      totalAmount: widget.totalAmount,
      tenderedAmount: tenderedAmount,
      paymentMethod: _selectedPaymentMethod!,
    );

    // 処理完了後、前の画面に戻る
    // Navigator.popの第2引数にtrueを渡すことで、会計が成功したことを伝える
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalItems = widget.cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    return AppScaffold(
      appBar: AppBar(title: const Text('お会計')),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            // --- 会計内容のヘッダー ---
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 3.0,
                horizontal: 8.0,
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 5, // 商品名の幅を広めに取る
                    child: Text(
                      '商品名',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      '数量',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '小計',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // --- 会計内容の一覧 ---
            Expanded(
              child: ListView.separated(
                itemCount: widget.cartItems.length,
                separatorBuilder: (context, index) =>
                    const Divider(
                      height: 1,
                    ), // 各項目の間に区切り線を入れる
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 8.0,
                    ),
                    child: Row(
                      children: [
                        // 商品名
                        Expanded(
                          flex: 5,
                          child: Text(
                            item.name,
                            overflow: TextOverflow
                                .ellipsis, // 長い商品名は省略記号(...)で表示
                          ),
                        ),
                        // 数量
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // 小計金額
                        Expanded(
                          flex: 3,
                          child: Text(
                            formatCurrency(
                              item.price * item.quantity,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(thickness: 2),

            // --- 金額サマリー ---
            _buildSummaryRow(
              '合計金額 ($totalItems点)',
              widget.totalAmount,
            ),
            _buildSummaryRow(
              'お預かり',
              null,
              controller: _tenderedController,
            ),
            _buildSummaryRow(
              'お釣り',
              _changeAmount < 0 ? 0 : _changeAmount,
              isEmphasized: true,
            ),

            // --- 支払方法ボタン ---
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              // Wrapを使うと、ボタンが増えても自動で折り返してくれる
              child: Consumer<PaymentMethodProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    height: 50.0,
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 4.0,
                      radius: const Radius.circular(2.0),
                      child: ListView.builder(
                        // 2. スクロール方向を水平に設定
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.methods.length,
                        itemBuilder: (context, index) {
                          final method =
                              provider.methods[index];
                          // 3. 各ボタンの左右に余白を追加して、間隔を作る
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                            child: ChoiceChip(
                              label: Text(method.name),
                              selected:
                                  _selectedPaymentMethod ==
                                  method.name,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedPaymentMethod =
                                        method.name;
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- 会計完了ボタン ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    ((int.tryParse(
                                  _tenderedController.text,
                                ) ??
                                0) <=
                            0 ||
                        _changeAmount < 0 ||
                        _isProcessing)
                    ? null
                    : _completePayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('会計を完了する'),
              ),
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
    TextEditingController? controller,
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
          if (controller != null)
            SizedBox(
              width: 150,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: textStyle,
                decoration: const InputDecoration(
                  hintText: '金額を入力',
                  suffixText: ' 円',
                ),
              ),
            )
          else
            Text(
              formatCurrency(amount ?? 0),
              style: textStyle.copyWith(
                color: isEmphasized ? Colors.red : null,
              ),
            ),
        ],
      ),
    );
  }
}
