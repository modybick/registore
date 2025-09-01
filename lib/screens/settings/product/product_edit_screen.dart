import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/sound_service.dart';
import '../../../models/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../utils/currency_input_formatter.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product; // nullなら新規登録、nullでなければ編集
  const ProductEditScreen({super.key, this.product});
  @override
  State<ProductEditScreen> createState() =>
      _ProductEditScreenState();
}

class _ProductEditScreenState
    extends State<ProductEditScreen> {
  // Formの状態を管理するためのキー
  final _formKey = GlobalKey<FormState>();

  // 各TextFormFieldを制御するためのコントローラー
  late final TextEditingController _barcodeController;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;

  // 編集モードかどうかを判定するフラグ
  late bool _isEditing;

  // 画像パスのプレースホルダー
  // String? _imagePath;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.product != null;

    // 編集モードなら初期値を設定、新規登録なら空文字を設定
    _barcodeController = TextEditingController(
      text: _isEditing ? widget.product!.barcode : '',
    );
    _nameController = TextEditingController(
      text: _isEditing ? widget.product!.name : '',
    );
    _priceController = TextEditingController(
      text: _isEditing
          ? CurrencyInputFormatter()
                .formatEditUpdate(
                  TextEditingValue.empty,
                  TextEditingValue(
                    text: widget.product!.price.toString(),
                  ),
                )
                .text
          : '',
    );
    _categoryController = TextEditingController(
      text: _isEditing ? widget.product!.category : '',
    );
    // _imagePath = _isEditing ? widget.product!.imagePath : null;
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // フォームを保存する処理
  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final priceString = _priceController.text.replaceAll(
        ',',
        '',
      );
      final newProduct = Product(
        barcode: _barcodeController.text.trim(),
        name: _nameController.text.trim(),
        price: int.parse(priceString),
        category: _categoryController.text.trim(),
        // imagePath: _imagePath,
      );

      final provider = context.read<ProductProvider>();

      // 編集モードか新規登録モードかで呼び出すメソッドを切り替え
      if (_isEditing) {
        await provider.updateProduct(newProduct);
      } else {
        await provider.addProduct(newProduct);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  void _showBarcodeScannerDialog() {
    // 1. ダイアログを開く直前に、Providerから最新のフォーマット設定を取得
    final activeFormats = context
        .read<SettingsProvider>()
        .activeBarcodeFormats;
    // 2. コントローラーに設定を適用
    final MobileScannerController scannerController =
        MobileScannerController(formats: activeFormats);

    final SoundService soundService = SoundService();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('バーコードをスキャン'),
          content: SizedBox(
            width: 300,
            height: 400, // ダイアログ内のスキャナのサイズ
            child: MobileScanner(
              controller: scannerController,
              // ProductEditScreen専用のシンプルなコールバックを渡す
              onDetect: (capture) {
                // 1. 検出されたバーコードの値を取得
                final String? barcodeValue =
                    capture.barcodes.first.rawValue;

                if (barcodeValue != null &&
                    barcodeValue.isNotEmpty) {
                  // 2. テキストフィールドに値をセットする
                  soundService.playSuccessSound();
                  _barcodeController.text = barcodeValue;

                  // 3. ダイアログを閉じる
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('閉じる'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        );
      },
    );
  }

  // 商品を削除する処理
  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('「${widget.product!.name}」を削除しますか？'),
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
                  .deleteProduct(widget.product!.barcode);
              if (mounted) {
                // 一覧画面に戻る
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
      appBar: AppBar(
        title: Text(_isEditing ? '商品を編集' : '商品を登録'),
        actions: [
          // 編集モードの場合のみ、削除ボタンを表示する
          if (_isEditing)
            IconButton(
              tooltip: '削除',
              icon: const Icon(Icons.delete),
              onPressed: _deleteProduct,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 画像プレビュー ---
              GestureDetector(
                onTap: () {
                  /* TODO: 画像選択機能を実装 */
                },
                child: Container(
                  height: 150,
                  width: 150,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 入力フォーム ---
              TextFormField(
                readOnly: _isEditing,
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: _isEditing
                      ? 'バーコード（編集不可）'
                      : 'バーコード',
                  prefixIcon: const Icon(
                    Icons.barcode_reader,
                  ),
                  suffixIcon: _isEditing
                      ? null
                      : IconButton(
                          tooltip: 'スキャンして入力',
                          icon: const Icon(
                            Icons.qr_code_scanner,
                          ),

                          onPressed:
                              _showBarcodeScannerDialog,
                        ),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty)
                    ? '必須項目です'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '商品名',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty)
                    ? '必須項目です'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '価格',
                  prefixIcon: Icon(Icons.currency_yen),
                  suffixText: '円',
                ),
                keyboardType: TextInputType.number,
                // 数字のみ入力を許可する
                inputFormatters: [
                  // 数字のみ許可するFormatterは不要になる
                  // FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(), // 作成したカスタムフォーマッタを適用
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '必須項目です';
                  }
                  // バリデーション時もカンマを削除してからチェックする
                  final price = int.tryParse(
                    value.replaceAll(',', ''),
                  );
                  if (price == null) {
                    return '数値を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'カテゴリ',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty)
                    ? '必須項目です'
                    : null,
              ),
              const SizedBox(height: 40),

              // --- ボタン ---
              Row(
                // 右寄せにする
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child:
                        // キャンセルボタン
                        OutlinedButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                          ),
                          child: const Text('キャンセル'),
                        ),
                  ),
                  const SizedBox(width: 16),
                  // 保存ボタン
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(_isEditing ? '更新' : '登録'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
