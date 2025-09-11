// screens/cart/widgets/scanner_view.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:registore/main.dart'; // routeObserverのために必要

/// バーコードスキャナUIとカメラ制御を行うウィジェット
///
/// RouteAwareをmixinしており、画面遷移を検知して不要なカメラの動作を停止する
class ScannerView extends StatefulWidget {
  final List<BarcodeFormat> formats;
  final void Function(BarcodeCapture) onDetect;

  const ScannerView({
    super.key,
    required this.formats,
    required this.onDetect,
  });

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView>
    with SingleTickerProviderStateMixin, RouteAware {
  late final MobileScannerController _controller;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: widget.formats,
      autoStart: false, // 初期状態では開始しない
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // 点滅するようなアニメーション
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // この画面のライフサイクル(push, popなど)を検知するためにRouteObserverに登録
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

  // この画面が表示された時 (didPush: 初回表示, didPopNext: 他の画面から戻ってきた時)
  @override
  void didPush() => _startCamera();
  @override
  void didPopNext() => _startCamera();

  // この画面から他の画面へ遷移する時 (didPushNext: 次の画面へ, didPop: 前の画面へ)
  @override
  void didPushNext() => _stopCamera();
  @override
  void didPop() => _stopCamera();

  /// カメラが起動中でなければ安全に起動する
  void _startCamera() {
    // 画面が最前面にある場合のみカメラを起動する
    if (!_controller.value.isRunning && mounted) {
      _controller.start();
    }
  }

  /// カメラが起動中であれば安全に停止する
  void _stopCamera() {
    if (_controller.value.isRunning) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: widget.onDetect,
          ),
          // スキャン領域を示すアニメーション付きの枠線
          FadeTransition(
            opacity: _animationController.drive(
              Tween(begin: 1.0, end: 0.5),
            ),
            child: Container(
              width:
                  MediaQuery.of(context).size.width * 0.8,
              height: 100,
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
