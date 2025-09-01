import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:registore/main.dart';
import '../../screens/payment/payment_screen.dart';
import '../../screens/sale_history/sale_histry_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../utils/formatter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/database_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/app_scaffold.dart';
import 'widgets/product_list_bottom_sheet.dart';

// --- 親ウィジェット ---
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final SoundService _soundService = SoundService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // 1. 親ウィジェットが`watch`でSettingsProviderの変更を監視する
    final settingsProvider = context
        .watch<SettingsProvider>();

    return AppScaffold(
      body: Column(
        children: [
          // 2. 監視して得た最新の設定を、子ウィジェットに渡す
          _ScannerView(
            key: ValueKey(
              settingsProvider.activeBarcodeFormats
                  .toString(),
            ),
            formats: settingsProvider.activeBarcodeFormats,
            onDetect: (capture) => _onBarcodeDetected(
              capture,
              settingsProvider.scanInterval,
            ),
          ),
          const Expanded(child: _CartListView()),
          _ControlPanel(
            onClearCart: _showClearCartDialog,
            onShowProductList: _showProductListBottomSheet,
          ),
        ],
      ),
    );
  }

  // scanIntervalを引数で受け取るように変更
  void _onBarcodeDetected(
    BarcodeCapture capture,
    double scanInterval,
  ) async {
    if (_isProcessing) return;
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
      // 引数で渡された最新のスキャン間隔を使う
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
}

// --- 子ウィジェット群 ---

/// 1. バーコードスキャナUIを表示し、自身のコントローラーを管理するウィジェット
class _ScannerView extends StatefulWidget {
  final List<BarcodeFormat> formats;
  final void Function(BarcodeCapture) onDetect;

  const _ScannerView({
    super.key, // Keyを受け取れるようにする
    required this.formats,
    required this.onDetect,
  });

  @override
  State<_ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<_ScannerView>
    with SingleTickerProviderStateMixin, RouteAware {
  late final MobileScannerController _controller;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // initStateで、親から渡された初期フォーマットでコントローラーを生成
    _controller = MobileScannerController(
      formats: widget.formats,
      autoStart: false,
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserverにこのStateを購読者として登録する
    routeObserver.subscribe(
      this,
      ModalRoute.of(context)! as PageRoute,
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didPush() {
    _startCamera();
  }

  @override
  void didPopNext() {
    _startCamera();
  }

  /// 他の画面がこの画面の上にプッシュされたときに呼ばれる
  @override
  void didPushNext() {
    // カメラを停止する
    _stopCamera();
  }

  @override
  void didPop() {
    _stopCamera();
  }

  // カメラの起動/停止を安全に行うヘルパーメソッド
  void _startCamera() {
    // カートスクリーンが開かれている時だけカメラが起動
    final bool isTopScreen =
        ModalRoute.of(context)?.isCurrent ?? false;
    if (!_controller.value.isRunning && isTopScreen) {
      _controller.start();
    }
  }

  void _stopCamera() {
    // カートスクリーンが開かれている時だけカメラが起動
    if (_controller.value.isRunning) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // カートスクリーンが開かれている時だけカメラが起動
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: widget.onDetect,
            scanWindow: Rect.fromLTWH(
              0,
              0,
              MediaQuery.of(context).size.width,
              150,
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
          const Text(
            'バーコードを枠内にスキャンしてください',
            style: TextStyle(
              color: Colors.white,
              backgroundColor: Colors.black54,
              fontSize: 16,
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
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) {
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
                  '単価: ${formatCurrency(item.price)}',
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

/// 3. 操作パネルウィジェット
class _ControlPanel extends StatelessWidget {
  final VoidCallback onClearCart;
  final VoidCallback onShowProductList;

  const _ControlPanel({
    required this.onClearCart,
    required this.onShowProductList,
  });

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('カートをクリア'),
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
                      onPressed: isCartEmpty
                          ? null
                          : () async {
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
