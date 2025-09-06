import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:registore/screens/settings/edit_unique_barcode_async_validator.dart';
import 'package:registore/screens/settings/unique_barcode_async_validator.dart';
import 'package:registore/utils/currency_input_formatter.dart';
import 'package:registore/utils/currency_value_accessor.dart';
import 'package:registore/providers/settings_provider.dart';
import 'package:registore/services/sound_service.dart';
import 'package:registore/models/product_model.dart';
import 'package:registore/providers/product_provider.dart';
import 'package:registore/widgets/app_scaffold.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_raw_autocomplete/reactive_raw_autocomplete.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product; // nullなら新規登録、nullでなければ編集
  const ProductEditScreen({super.key, this.product});
  @override
  State<ProductEditScreen> createState() =>
      _ProductEditScreenState();
}

class _ProductEditScreenState
    extends State<ProductEditScreen> {
  late FormGroup form;

  // 編集モードかどうかを判定するフラグ
  late bool _isEditing;

  // カテゴリ候補リストを保持するState変数
  List<String> _categoryOptions = [];

  // 画像パスのプレースホルダー
  // String? _imagePath;

  @override
  void initState() {
    super.initState();

    _isEditing = widget.product != null;

    // initState内でProviderからデータを取得する安全な方法
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      // もしProviderにデータがなければロードする
      if (provider.products.isEmpty) {
        provider.reloadProducts().then((_) {
          if (mounted) {
            setState(() {
              _categoryOptions = provider.pureCategories;
            });
          }
        });
      } else {
        setState(() {
          _categoryOptions = provider.pureCategories;
        });
      }
    });

    // TODO: _imagePath = _isEditing ? widget.product!.imagePath : null;

    // フォームの構造とバリデーションルールを定義
    form = FormGroup({
      'barcode': FormControl<String>(
        value: _isEditing ? widget.product!.barcode : '',
        // 新規登録モードの場合のみ、非同期バリデーターを適用
        asyncValidators: [
          // 編集モードか新規登録モードかで、適用するバリデーターを切り替える
          if (_isEditing)
            EditUniqueBarcodeAsyncValidator(
              widget.product!.id!,
            )
          else
            UniqueBarcodeAsyncValidator(),
        ],
      ),
      'name': FormControl<String>(
        value: _isEditing ? widget.product!.name : '',
        validators: [Validators.required],
      ),
      'price': FormControl<int>(
        value: _isEditing ? widget.product!.price : null,
        validators: [
          Validators.required,
          Validators.number(),
        ],
      ),
      'category': FormControl<String>(
        value: _isEditing ? widget.product!.category : '',
      ),
    });
  }

  // フォームを保存する処理
  Future<void> _saveForm() async {
    if (form.invalid) {
      // フォームが無効な場合は、すべてのフィールドに触れたことにしてエラーを表示
      form.markAllAsTouched();
      return;
    }

    // バーコードが''の場合、nullに変換
    String? barcodeValue =
        form.control('barcode').value as String?;

    // もしバーコードの値がnullではなく、かつトリム（前後の空白削除）した結果が空文字列なら、
    // nullとして扱うようにする
    if (barcodeValue != null &&
        barcodeValue.trim().isEmpty) {
      barcodeValue = null;
    }

    // カテゴリが未入力かどうか
    String categoryValue =
        form.control('category').value ?? '';
    // もし入力が空文字列なら、「未分類」として扱う
    if (categoryValue.trim().isEmpty) {
      categoryValue = '未分類';
    }

    final newProduct = Product(
      id: _isEditing
          ? widget.product!.id
          : null, // 編集時はidを引き継ぐ
      barcode: barcodeValue,
      name: form.control('name').value,
      price: form.control('price').value,
      category: categoryValue,
    );

    final provider = context.read<ProductProvider>();
    if (_isEditing) {
      await provider.updateProduct(newProduct);
    } else {
      await provider.addProduct(newProduct);
    }

    if (mounted) Navigator.pop(context);
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
              scanWindow: Rect.fromLTWH(0, 0, 300, 400),
              // ProductEditScreen専用のシンプルなコールバックを渡す
              onDetect: (capture) {
                // 1. 検出されたバーコードの値を取得
                final String? barcodeValue =
                    capture.barcodes.first.rawValue;

                if (barcodeValue != null &&
                    barcodeValue.isNotEmpty) {
                  soundService.playSuccessSound();

                  // 2. テキストフィールドに値をセットする
                  form.control('barcode').value =
                      barcodeValue;

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
    // このメソッドの`context`はProductEditScreenのものです
    final screenContext = context;
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
              // 1. awaitの前に、contextに依存するものをすべて変数に確保する
              final provider = Provider.of<ProductProvider>(
                screenContext,
                listen: false,
              );

              await provider.deleteProduct(
                widget.product!.id!,
              );

              if (!context.mounted) return;

              final navigator = Navigator.of(screenContext);

              // 一覧画面に戻る
              navigator.pop(ctx);
              // 編集画面自体を閉じて、一覧画面に戻る
              navigator.pop(screenContext);
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
      body: ReactiveForm(
        formGroup: form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
              ReactiveTextField<String>(
                formControlName: 'barcode',
                decoration: InputDecoration(
                  labelText: 'バーコード（任意）',
                  prefixIcon: const Icon(
                    Icons.barcode_reader,
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'スキャンして入力',
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _showBarcodeScannerDialog,
                  ),
                ),
                validationMessages: {
                  'unique': (error) => 'このバーコードは既に使用されています',
                },
                // ユーザーの入力が終わったタイミングで非同期バリデーションをトリガー
                showErrors: (control) =>
                    control.invalid && control.touched,
              ),
              const SizedBox(height: 16),

              ReactiveTextField<String>(
                formControlName: 'name',
                decoration: const InputDecoration(
                  labelText: '商品名',
                  prefixIcon: Icon(Icons.label),
                ),
                validationMessages: {
                  'required': (error) => '必須項目です',
                },
              ),
              const SizedBox(height: 16),

              ReactiveTextField<int>(
                formControlName: 'price',
                valueAccessor: CurrencyValueAccessor(),
                inputFormatters: [CurrencyInputFormatter()],
                decoration: const InputDecoration(
                  labelText: '価格',
                  prefixIcon: Icon(Icons.sell),
                  suffixText: '円',
                ),
                keyboardType: TextInputType.number,
                validationMessages: {
                  'required': (error) => '必須項目です',
                  'number': (error) => '数値を入力してください',
                },
              ),
              const SizedBox(height: 16),

              ReactiveRawAutocomplete<String, String>(
                formControlName: 'category',
                optionsBuilder: (textEditingValue) {
                  final text = textEditingValue.text;
                  if (text.isEmpty) {
                    return _categoryOptions;
                  }
                  return _categoryOptions.where(
                    (option) => option
                        .toLowerCase()
                        .startsWith(text.toLowerCase()),
                  );
                },
                optionsViewBuilder:
                    (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(
                                  maxHeight: 200,
                                ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options
                                    .elementAt(index);
                                return InkWell(
                                  onTap: () =>
                                      onSelected(option),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(
                                          16.0,
                                        ),
                                    child: Text(option),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                // fieldViewBuilderの中で`ReactiveTextField`を使う
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      // `RawAutocomplete`から渡されるコントローラーとフォーカスノードは、
                      // `ReactiveTextField`に渡すことで正しく連携される
                      return ReactiveTextField<String>(
                        formControlName:
                            'category', // これがFormControlとUIを繋ぐ
                        focusNode: focusNode,
                        onTap: (control) {
                          if (control.value == null ||
                              control.value!.isEmpty) {
                            control.value = 'a';
                            control.value = '';
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'カテゴリ (任意)',
                          prefixIcon: Icon(Icons.category),
                        ),
                        onSubmitted: (_) =>
                            onFieldSubmitted(),
                      );
                    },
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
