import 'dart:io';

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
    extends State<ProductListBottomSheet> {
  // 非同期処理を保持するためのFuture
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    // initStateで一度だけデータロードを開始する
    _loadFuture = context
        .read<ProductProvider>()
        .loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          // ハンドル (変更なし)
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),

          // FutureBuilderでデータロードを管理
          Expanded(
            child: FutureBuilder(
              future: _loadFuture,
              builder: (context, snapshot) {
                // ロード中の表示
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // エラー表示
                if (snapshot.hasError) {
                  return Center(
                    child: Text('エラー: ${snapshot.error}'),
                  );
                }

                // ロード完了後、ConsumerでUIを構築
                return Consumer2<
                  ProductProvider,
                  SettingsProvider
                >(
                  builder:
                      (
                        context,
                        productProvider,
                        settingsProvider,
                        child,
                      ) {
                        if (productProvider
                            .products
                            .isEmpty) {
                          return const Center(
                            child: Text('商品が登録されていません。'),
                          );
                        }

                        // タブのリストを動的に生成
                        final tabs = <Tab>[];
                        if (settingsProvider
                            .showNoBarcodeTab) {
                          tabs.add(
                            const Tab(text: 'バーコードなし'),
                          );
                        }
                        tabs.addAll(
                          productProvider.categories
                              .map((c) => Tab(text: c))
                              .toList(),
                        );

                        return DefaultTabController(
                          length: tabs.length,
                          child: Column(
                            children: [
                              TabBar(
                                isScrollable: true,
                                tabs: tabs,
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    // バーコードなしタブのビュー
                                    if (settingsProvider
                                        .showNoBarcodeTab)
                                      _buildProductListView(
                                        productProvider
                                            .productsWithNoBarcode,
                                      ),

                                    // カテゴリごとのタブのビュー
                                    ...productProvider
                                        .categories
                                        .map((category) {
                                          return _buildProductListView(
                                            productProvider
                                                .getProductsByCategory(
                                                  category,
                                                ),
                                          );
                                        })
                                        .toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                );
              },
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
          leading: SizedBox(
            width: 50,
            height: 50,
            child: product.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(
                      4.0,
                    ),
                    child: Image.file(
                      File(product.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                            return Icon(
                              Icons.error_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.error,
                            );
                          },
                    ),
                  )
                : Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant,
                  ),
          ),
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
