// screens/cart/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/database_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/app_scaffold.dart';
import 'widgets/cart_list_view.dart';
import 'widgets/control_panel.dart';
import 'widgets/product_list_bottom_sheet.dart';
import 'widgets/scanner_view.dart';

/// カート画面のメインウィジェット
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final SoundService _soundService = SoundService();

  /// 連続スキャンによる重複処理を防ぐためのフラグ
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // SettingsProviderをwatchで監視し、設定変更時にUIを再構築
    final settingsProvider = context
        .watch<SettingsProvider>();

    return AppScaffold(
      body: Column(
        children: [
          // 設定(読み取り可能なバーコード形式)が変更されたら、
          // Keyを使ってScannerViewウィジェット自体を再生成する
          ScannerView(
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
          const Expanded(child: CartListView()),
          ControlPanel(
            onClearCart: _showClearCartDialog,
            onShowProductList: _showProductListBottomSheet,
          ),
        ],
      ),
    );
  }

  /// バーコードが検出された際の処理
  Future<void> _onBarcodeDetected(
    BarcodeCapture capture,
    double scanInterval,
  ) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final barcodeValue = capture.barcodes.first.rawValue;

    if (barcodeValue != null && barcodeValue.isNotEmpty) {
      final product = await DatabaseService.instance
          .getProductByBarcode(barcodeValue);

      // 非同期処理後にウィジェットが破棄されている可能性を考慮
      if (!mounted) return;

      final cartProvider = context.read<CartProvider>();

      if (product != null) {
        cartProvider.addItem(product);
      } else {
        _soundService.playErrorSound();
        _showErrorSnackBar('商品が見つかりません: $barcodeValue');
      }

      // 設定されたスキャン間隔だけ待機し、連続スキャンを防ぐ
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

  /// エラーメッセージを画面上部のSnackBarで表示する
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        // SnackBarをスキャナビューの下に表示するためのマージン設定
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 16,
          right: 16,
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// カートを空にするか確認するダイアログを表示
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
            child: Text(
              '削除する',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
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

  /// 商品一覧をモーダルボトムシートで表示
  void _showProductListBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 高さを画面の半分以上にできる
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (_) => const ProductListBottomSheet(),
    );
  }
}
