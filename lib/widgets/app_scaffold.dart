import 'package:flutter/material.dart';

/// アプリ全体で共通のレイアウトを提供するScaffoldウィジェット。
/// 自動的に SafeArea でラップされる。
class AppScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBarがnullでない場合は、PreferredSizeウィジェットを使って高さを設定する
        // これにより、AppBarを持つScaffoldと同じように振る舞う
        appBar: appBar != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(
                  kToolbarHeight,
                ),
                child: appBar!,
              )
            : null,
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
