import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:registore/providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/cart/cart_screen.dart';

void main() {
  // runApp() の前に Flutter の機能 (DB初期化など) を呼び出す場合に必要です。
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider を使い、アプリ全体で利用する Provider を設定します。
    // 今後、商品マスタや販売履歴の Provider を追加する際にここへ追記します。
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'レジアプリ DEMO',
        theme: ThemeData(
          // アプリ全体のカラーテーマを設定
          primarySwatch: Colors.teal,
          // UI要素の密度を調整
          visualDensity:
              VisualDensity.adaptivePlatformDensity,
          // AppBarのテーマをカスタマイズ
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          // ElevatedButtonのテーマをカスタマイズ
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ),
        // 最初に表示する画面を指定
        home: const CartScreen(),
      ),
    );
  }
}
