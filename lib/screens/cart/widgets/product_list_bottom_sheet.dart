import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumerを使ってProductProviderの状態を監視
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // データロード中の表示
        if (productProvider.isLoading) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // カテゴリが取得できない場合（データが空など）
        if (productProvider.categories.isEmpty ||
            _tabController == null) {
          return const SizedBox(
            height: 300,
            child: Center(child: Text('商品が登録されていません。')),
          );
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),

              // カテゴリタブ
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: productProvider.categories
                    .map((category) => Tab(text: category))
                    .toList(),
              ),

              // 商品リスト
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: productProvider.categories.map((
                    category,
                  ) {
                    final products = productProvider
                        .getProductsByCategory(category);
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                            formatCurrency(product.price),
                          ),
                          onTap: () {
                            // 商品をカートに追加
                            context
                                .read<CartProvider>()
                                .addItem(product);
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
