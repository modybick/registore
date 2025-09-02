import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:registore/screens/settings/unique_barcode_async_validator.dart';
import 'package:registore/utils/currency_input_formatter.dart';
import 'package:registore/utils/currency_value_accessor.dart';
import 'package:registore/providers/settings_provider.dart';
import 'package:registore/services/sound_service.dart';
import 'package:registore/models/product_model.dart';
import 'package:registore/providers/product_provider.dart';
import 'package:registore/widgets/app_scaffold.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:uuid/uuid.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product; // nullなら新規登録、nullでなければ編集
  const ProductEditScreen({super.key, this.product});
  @override
  State<ProductEditScreen> createState() =>
      _ProductEditScreenState();
}

class _ProductEditScreenState
    extends State<ProductEditScreen> {
  late final FormGroup form;

  // 編集モードかどうかを判定するフラグ
  late bool _isEditing;

  // 画像パスのプレースホルダー
  // String? _imagePath;

  @override
  void initState() {
    super.initState();

    _isEditing = widget.product != null;

    // _imagePath = _isEditing ? widget.product!.imagePath : null;

    // フォームの構造とバリデーションルールを定義
    form = FormGroup({
      'isBarcodeLess': FormControl<bool>(value: false),
      'barcode': FormControl<String>(
        value: _isEditing ? widget.product!.barcode : '',
        validators: [Validators.required],
        // 新規登録モードの場合のみ、非同期バリデーターを適用
        asyncValidators: _isEditing
            ? []
            : [UniqueBarcodeAsyncValidator()],
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
        validators: [Validators.required],
      ),
    });

    // 編集モードではバーコード入力欄を無効化
    if (_isEditing) {
      form.control('barcode').markAsDisabled();
    } else {
      // --- ▼▼▼ チェックボックスの状態に応じてバーコード欄を制御するリスナーを追加 ▼▼▼ ---
      final isBarcodeLessControl =
          form.control('isBarcodeLess')
              as FormControl<bool>;
      final barcodeControl = form.control('barcode');

      // 初期状態を設定
      if (isBarcodeLessControl.value ?? false) {
        barcodeControl.markAsDisabled();
        barcodeControl.setValidators([]); // バリデーターを解除
      }

      // チェックボックスの値が変更されたら、バーコード欄の状態を更新
      isBarcodeLessControl.valueChanges.listen((
        isBarcodeLess,
      ) {
        if (isBarcodeLess ?? false) {
          barcodeControl.markAsDisabled(); // 無効化
          barcodeControl.setValidators([]); // バリデーターを解除
          barcodeControl.updateValueAndValidity(); // 状態を更新
        } else {
          barcodeControl.markAsEnabled(); // 有効化
          barcodeControl.setValidators([
            Validators.required,
          ]); // バリデーターを再設定
          barcodeControl.updateValueAndValidity(); // 状態を更新
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // フォームを保存する処理
  Future<void> _saveForm() async {
    if (form.invalid) {
      // フォームが無効な場合は、すべてのフィールドに触れたことにしてエラーを表示
      form.markAllAsTouched();
      return;
    }

    // --- ▼▼▼ 保存時のバーコード生成ロジックを追加 ▼▼▼ ---
    String barcodeValue;
    final isBarcodeLess =
        form.control('isBarcodeLess').value as bool;

    if (!_isEditing && isBarcodeLess) {
      // 新規登録かつ「バーコードなし」がONの場合、UUIDを生成
      Uuid uuid = Uuid();
      barcodeValue = 'no-barcode-${uuid.v4()}';
    } else {
      // それ以外の場合は、フォームの値をそのまま使用
      barcodeValue = form.control('barcode').value;
    }

    final newProduct = Product(
      barcode: barcodeValue,
      name: form.control('name').value,
      price: form.control('price').value,
      category: form.control('category').value,
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
              final navigator = Navigator.of(screenContext);

              await provider.deleteProduct(
                widget.product!.barcode,
              );

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
              if (!_isEditing)
                ReactiveCheckboxListTile(
                  formControlName: 'isBarcodeLess',
                  title: const Text('バーコードなし商品として登録'),
                ),

              ReactiveTextField<String>(
                formControlName: 'barcode',
                readOnly: _isEditing,
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
                validationMessages: {
                  'required': (error) => '必須項目です',
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
              ReactiveTextField<String>(
                formControlName: 'category',
                decoration: const InputDecoration(
                  labelText: 'カテゴリ',
                  prefixIcon: Icon(Icons.category),
                ),
                validationMessages: {
                  'required': (error) => '必須項目です',
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
