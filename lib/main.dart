import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:registore/providers/payment_method_provider.dart';
import 'package:registore/providers/product_provider.dart';
import 'package:registore/providers/sales_provider.dart';
import 'package:registore/services/sound_service.dart';
import 'package:registore/utils/create_text_theme.dart';
import 'providers/cart_provider.dart';
import 'screens/cart/cart_screen.dart';
import 'providers/settings_provider.dart';
import 'package:registore/providers/theme_provider.dart'; // 作成したProvider
import 'package:registore/theme/theme.dart'; // 作成したテーマ定義

final RouteObserver<PageRoute> routeObserver =
    RouteObserver<PageRoute>();

Future<void> main() async {
  // runApp() の前に Flutter の機能 (DB初期化など) を呼び出す場合に必要です。
  WidgetsFlutterBinding.ensureInitialized();
  // アプリ全体の画面の向きを縦向き（上向きと下向き）に固定する
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SoundService.instance.init();
  runApp(
    // ChangeNotifierProviderでThemeProviderをアプリ全体に提供
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentMethodProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        // `ChangeNotifierProxyProvider` を使って、
        // `SettingsProvider` のインスタンスを `CartProvider` に渡す
        ChangeNotifierProxyProvider<
          SettingsProvider,
          CartProvider
        >(
          // `CartProvider` のインスタンスを生成する部分
          create: (context) => CartProvider(
            // 最初に一度だけ `SettingsProvider` を読み込む
            context.read<SettingsProvider>(),
          ),

          // `SettingsProvider` が更新されたときに、`CartProvider` も更新する場合に使う
          // (今回はコンストラクタで渡すだけで良いので、古いインスタンスをそのまま返す)
          update: (context, settings, previousCart) =>
              previousCart!,
        ),
        ChangeNotifierProxyProvider<
          SettingsProvider,
          SalesProvider
        >(
          // `CartProvider` のインスタンスを生成する部分
          create: (context) => SalesProvider(
            // 最初に一度だけ `SettingsProvider` を読み込む
            context.read<SettingsProvider>(),
          ),

          // `SettingsProvider` が更新されたときに、`CartProvider` も更新する場合に使う
          // (今回はコンストラクタで渡すだけで良いので、古いインスタンスをそのまま返す)
          update: (context, settings, previousSale) =>
              previousSale!,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          TextTheme textTheme = createTextTheme(
            context,
            "M PLUS Rounded 1c",
            "M PLUS Rounded 1c",
          );

          MaterialTheme theme = MaterialTheme(textTheme);
          return MaterialApp(
            title: 'RegiStore',
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: themeProvider.themeMode,
            navigatorObservers: [routeObserver],
            // 最初に表示する画面を指定
            home: const CartScreen(),
          );
        },
      ),
    );
  }
}
