import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_method_model.dart';
import '../../providers/payment_method_provider.dart';
import '../../widgets/app_scaffold.dart';

class PaymentMethodListScreen extends StatefulWidget {
  const PaymentMethodListScreen({super.key});

  @override
  State<PaymentMethodListScreen> createState() =>
      _PaymentMethodListScreenState();
}

class _PaymentMethodListScreenState
    extends State<PaymentMethodListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentMethodProvider>().loadMethods();
    });
  }

  // 追加・編集ダイアログを表示する
  void _showEditDialog({PaymentMethod? method}) {
    final isEditing = method != null;
    final controller = TextEditingController(
      text: isEditing ? method.name : '',
    );

    // ダイアログ内のボタンの状態を管理するために、StatefulBuilderを使用
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // テキストフィールドが空かどうかをチェックするリスナーを追加
            void checkButtonState() {
              setDialogState(
                () {},
              ); // 空のsetStateを呼ぶことで、ボタンの状態を再評価させる
            }

            controller.addListener(checkButtonState);

            // ダイアログが閉じられるときにリスナーをクリーンアップ
            WidgetsBinding.instance.addPostFrameCallback((
              _,
            ) {
              if (!ModalRoute.of(context)!.isCurrent) {
                controller.removeListener(checkButtonState);
              }
            });

            return AlertDialog(
              title: Text(
                isEditing ? '決済方法を編集' : '決済方法を追加',
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '決済方法名',
                ),
                onChanged: (text) {
                  // テキストが変更されるたびにボタンの状態を更新
                  setDialogState(() {});
                },
              ),
              actions: [
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    controller.removeListener(
                      checkButtonState,
                    ); // リスナーを削除
                    Navigator.pop(dialogContext);
                  },
                ),
                ElevatedButton(
                  // テキストが空でなければボタンを有効化
                  onPressed:
                      controller.text.trim().isNotEmpty
                      ? () {
                          final name = controller.text
                              .trim();
                          final provider =
                              Provider.of<
                                PaymentMethodProvider
                              >(context, listen: false);
                          if (isEditing) {
                            provider.updateMethod(
                              method.id!,
                              name,
                            );
                          } else {
                            provider.addMethod(name);
                          }
                          controller.removeListener(
                            checkButtonState,
                          ); // リスナーを削除
                          Navigator.pop(dialogContext);
                        }
                      : null, // 空の場合は無効
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 削除の確認ダイアログ
  void _showDeleteConfirmation(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('「${method.name}」を削除しますか？'),
        actions: [
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.error,
            ),
            child: const Text('削除'),
            onPressed: () {
              context
                  .read<PaymentMethodProvider>()
                  .deleteMethod(method.id!);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('「${method.name}」を削除しました'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('決済方法の編集')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<PaymentMethodProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (provider.methods.isEmpty) {
            return const Center(
              child: Text('決済方法が登録されていません。'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(
              8.0,
            ), // ListView全体に余白
            itemCount: provider.methods.length,
            itemBuilder: (context, index) {
              final method = provider.methods[index];
              return Card(
                // 1. ListTileをCardでラップ
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  title: Text(
                    method.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 編集ボタン
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blue,
                        ),
                        onPressed: () =>
                            _showEditDialog(method: method),
                      ),
                      // 2. 削除ボタンを追加
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(
                            context,
                          ).colorScheme.error,
                        ),
                        onPressed: () =>
                            _showDeleteConfirmation(method),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
