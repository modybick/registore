import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/formatter.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_scaffold.dart';
import 'product_edit_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState
    extends State<ProductListScreen> {
  late Future<void> _loadProductsFuture;
  @override
  void initState() {
    super.initState();
    _loadProductsFuture = context
        .read<ProductProvider>()
        .reloadProducts();
  }

  // 削除確認ダイアログ
  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('「${product.name}」を削除しますか？'),
        actions: [
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('削除'),
            onPressed: () async {
              await context
                  .read<ProductProvider>()
                  .deleteProduct(product.barcode);
              if (mounted) {
                // ダイアログ閉じる
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('商品マスタ一覧')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 商品がnull = 新規登録モードで編集画面に遷移
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _loadProductsFuture,
        builder: (context, snapshot) {
          // --- 非同期処理が実行中の場合 ---
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // --- エラーが発生した場合 ---
          if (snapshot.hasError) {
            return Center(
              child: Text('エラーが発生しました: ${snapshot.error}'),
            );
          }

          // --- 正常に完了した場合、ConsumerでProviderの状態を描画 ---
          // この時点では、Providerにデータがロード済みであることが保証されている
          return Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.products.isEmpty) {
                return const Center(
                  child: Text('商品が登録されていません。'),
                );
              }
              // ▼▼▼ 4. DefaultTabControllerでTabの管理をシンプルにする ▼▼▼
              return DefaultTabController(
                length: provider
                    .categories
                    .length, // Providerから取得した正しいタブ数を設定
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabs: provider.categories
                          .map(
                            (category) =>
                                Tab(text: category),
                          )
                          .toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: provider.categories.map((
                          category,
                        ) {
                          final products = provider
                              .getProductsByCategory(
                                category,
                              );
                          return ListView.builder(
                            padding: const EdgeInsets.all(
                              8.0,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product =
                                  products[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.image_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  title: Text(product.name),
                                  subtitle: Text(
                                    '${formatCurrency(product.price)} / ${product.category}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons
                                              .edit_outlined,
                                          color:
                                              Colors.blue,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ProductEditScreen(
                                                    product:
                                                        product,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons
                                              .delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _showDeleteConfirmation(
                                              product,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
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
        },
      ),
    );
  }
}
