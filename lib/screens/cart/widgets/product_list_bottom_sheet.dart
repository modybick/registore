import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:registore/models/product_model.dart';
import 'package:registore/providers/settings_provider.dart';
import '../../../utils/formatter.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_provider.dart';

class ProductListBottomSheet extends StatefulWidget {
  const ProductListBottomSheet({super.key});

  @override
  State<ProductListBottomSheet> createState() =>
      _ProductListBottomSheetState();
}

class _ProductListBottomSheetState
    extends State<ProductListBottomSheet>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // --- タブとタブビューを構築するロジックを外部に切り出し ---
  List<Tab> _tabs = [];
  List<Widget> _tabViews = [];

  @override
  void initState() {
    super.initState();

    context.read<ProductProvider>().loadProducts();

    // initState内で非同期処理を安全に呼び出す
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // プロバイダから商品データをロードする
      final productProvider = context
          .read<ProductProvider>();
      productProvider.loadProducts().then((_) {
        // データロード後にTabControllerを初期化
        if (mounted) {
          setState(() {
            _tabController = TabController(
              length: productProvider.categories.length,
              vsync: this,
            );
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Providerの変更をリッスンし、タブを再構築する
    _updateTabs();
  }

  /// Providerの状態に基づいてタブとビューを構築・更新するメソッド
  void _updateTabs() {
    final productProvider = context
        .watch<ProductProvider>();
    final settingsProvider = context
        .watch<SettingsProvider>();

    // 新しいタブとビューのリストを生成
    final newTabs = <Tab>[];
    final newTabViews = <Widget>[];

    // isLoadingでなく、商品データが準備できているかを確認
    if (productProvider.products.isNotEmpty) {
      // 1. 「バーコードなし」タブ（設定がONの場合）
      if (settingsProvider.showNoBarcodeTab) {
        newTabs.add(const Tab(text: 'バーコードなし'));
        newTabViews.add(
          _buildProductListView(
            productProvider.productsWithNoBarcode,
          ),
        );
      }
      // 2. 「すべて」タブ
      newTabs.add(const Tab(text: 'すべて'));
      newTabViews.add(
        _buildProductListView(productProvider.products),
      );

      // 3. カテゴリタブ (productProvider.categoriesは「すべて」を含むため、それ以外を追加)
      final categories = productProvider.categories.where(
        (c) => c != 'すべて',
      );
      for (final category in categories) {
        newTabs.add(Tab(text: category));
        newTabViews.add(
          _buildProductListView(
            productProvider.getProductsByCategory(category),
          ),
        );
      }
    }

    // タブの構成が変更されたかチェック
    if (!const ListEquality().equals(
      _tabs.map((t) => t.text).toList(),
      newTabs.map((t) => t.text).toList(),
    )) {
      setState(() {
        _tabs = newTabs;
        _tabViews = newTabViews;
        // TabControllerを新しいタブの数で再作成
        _tabController?.dispose(); // 古いコントローラを破棄
        _tabController = TabController(
          length: _tabs.length,
          vsync: this,
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumerではなく、buildメソッドの先頭でProviderを取得
    final productProvider = context
        .watch<ProductProvider>();

    // データロード中の表示
    if (productProvider.isLoading && _tabs.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 商品が登録されていない場合の表示
    if (productProvider.products.isEmpty &&
        !productProvider.isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('商品が登録されていません。')),
      );
    }

    // TabControllerがまだ初期化されていない場合（一瞬だけ表示される可能性）
    if (_tabController == null) {
      return const SizedBox(
        height: 300,
      ); // or a smaller loading indicator
    }

    // メインのUI
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          // ボトムシートを掴むためのハンドル
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),

          // カテゴリタブ
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _tabs,
          ),

          // 商品リスト
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabViews,
            ),
          ),
        ],
      ),
    );
  }

  /// 商品リストのListViewを構築する共通メソッド
  Widget _buildProductListView(List<Product> products) {
    return ListView.separated(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Text(
                product.name,
                maxLines: settings.showFullName
                    ? null
                    : settings.productNameMaxLines,
                overflow: settings.showFullName
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              );
            },
          ),
          subtitle: Text(formatCurrency(product.price)),
          onTap: () {
            context.read<CartProvider>().addItem(product);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 1,
          thickness: 1,
          indent: 10,
          endIndent: 10,
        );
      },
    );
  }
}
