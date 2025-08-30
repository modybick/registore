import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:registore/providers/settings_provider.dart';
import 'package:registore/screens/payment/payment_screen.dart';
import 'package:registore/screens/sale_history/sale_histry_screen.dart';
import 'package:registore/screens/settings/settings_screen.dart';
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/app_scaffold.dart';
import 'widgets/product_list_bottom_sheet.dart';

// --- 親ウィジェット ---
// 画面全体のロジックと状態を管理する

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final MobileScannerController _scannerController =
      MobileScannerController();
  final SoundService _soundService = SoundService();
  bool _isProcessing = false;

  void _onBarcodeDetected(BarcodeCapture capture) async {
    // ... (このメソッドの中身は変更なし)
    if (_isProcessing) {
      return;
    }
    setState(() {
      _isProcessing = true;
    });
    final String? barcodeValue =
        capture.barcodes.first.rawValue;
    if (barcodeValue != null && barcodeValue.isNotEmpty) {
      final product = await DatabaseService.instance
          .getProductByBarcode(barcodeValue);
      if (!mounted) return;
      final cartProvider = context.read<CartProvider>();
      final scaffoldMessenger = ScaffoldMessenger.of(
        context,
      );
      if (product != null) {
        cartProvider.addItem(product);
        _soundService.playSuccessSound();
      } else {
        _soundService.playErrorSound();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('商品が見つかりません: $barcodeValue'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).size.height - 150,
              left: 16,
              right: 16,
            ),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }

      final scanInterval = context
          .read<SettingsProvider>()
          .scanInterval;
      await Future.delayed(
        Duration(
          milliseconds: (scanInterval * 1000).toInt(),
        ),
      );
    }
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showClearCartDialog() {
    // ... (このメソッドの中身は変更なし)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('確認'),
        content: const Text('カート内のすべての商品を削除しますか？'),
        actions: <Widget>[
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text(
              '削除する',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showProductListBottomSheet() {
    // ... (このメソッドの中身は変更なし)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return const ProductListBottomSheet();
      },
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // appBarは廃止したので指定しない
      body: Column(
        children: [
          // スキャナ部分
          _ScannerView(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
          ),

          // カートリスト部分 (Stackを削除しシンプルに)
          const Expanded(child: _CartListView()),

          // 新しい操作パネル
          _ControlPanel(
            onClearCart: _showClearCartDialog,
            onShowProductList: _showProductListBottomSheet,
          ),
        ],
      ),
    );
  }
}

// --- 子ウィジェット群 ---

// _ScannerView, _CartListView は以前のコードから変更なし
/// 1. バーコードスキャナUIを表示するウィジェット
class _ScannerView extends StatefulWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;

  const _ScannerView({
    required this.controller,
    required this.onDetect,
  });

  @override
  State<_ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<_ScannerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  final Rect scanWindow = Rect.fromCenter(
    center: const Offset(0.5, 0.5), // ビューの中心
    width: double.infinity * 0.8,
    height: 120, // ビューの高さの(120 / 150)
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: widget.controller,
            onDetect: widget.onDetect,
            scanWindow: Rect.fromLTWH(
              0,
              0,
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
          ),
          FadeTransition(
            opacity: _animationController.drive(
              Tween(begin: 1.0, end: 0.3),
            ),
            child: Container(
              width:
                  MediaQuery.of(context).size.width * 0.8,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. カート内商品リストを表示するウィジェット
class _CartListView extends StatelessWidget {
  const _CartListView();

  @override
  Widget build(BuildContext context) {
    // Consumerウィジェットを使い、CartProviderの変更があった場合のみこの部分を再描画する
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) {
          // カートが空の場合は、再描画の必要がない `child` ウィジェットを表示
          return child!;
        }
        return ListView.builder(
          itemCount: cart.items.length,
          itemBuilder: (ctx, i) {
            final item = cart.items.values.toList()[i];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(
                  '単価: ¥${item.price.toStringAsFixed(0)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        context
                            .read<CartProvider>()
                            .decrementItem(item.barcode);
                      },
                    ),
                    CircleAvatar(
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
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        context
                            .read<CartProvider>()
                            .incrementItem(item.barcode);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      // builderの `child` 引数に渡されるウィジェット。これは再描画されない。
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

/// 3. 新しい操作パネルウィジェット
class _ControlPanel extends StatelessWidget {
  final VoidCallback onClearCart;
  final VoidCallback onShowProductList;

  const _ControlPanel({
    required this.onClearCart,
    required this.onShowProductList,
  });

  @override
  Widget build(BuildContext context) {
    // Consumerを使ってカートの状態を監視
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final bool isCartEmpty = cart.items.isEmpty;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            // 子ウィジェットを横いっぱいに広げる
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 合計金額 ---
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  '合計: ¥${cart.totalAmount.toStringAsFixed(0)}',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),

              // --- 会計ボタンとクリアボタン ---
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
                        foregroundColor: Colors.red,
                        side: const BorderSide(
                          color: Colors.red,
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
                          : () async {
                              // Navigator.pushから結果を受け取る
                              final result =
                                  await Navigator.push<
                                    bool
                                  >(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PaymentScreen(
                                            cartItems: cart
                                                .items
                                                .values
                                                .toList(),
                                            totalAmount: cart
                                                .totalAmount,
                                          ),
                                    ),
                                  );

                              // もし会計が完了(result == true)して戻ってきたら、カートをクリアする
                              if (result == true &&
                                  context.mounted) {
                                context
                                    .read<CartProvider>()
                                    .clearCart();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),

              // --- ナビゲーションボタン ---
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SalesHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('販売履歴'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SettingsScreen(),
                        ),
                      );
                    },
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
}
