// screens/product_edit/product_edit_screen.dart

import 'package:flutter/material.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../models/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/sound_service.dart';
import '../../../widgets/app_scaffold.dart';
import '../edit_unique_barcode_async_validator.dart';
import '../unique_barcode_async_validator.dart';
import 'widgets/form_action_buttons.dart';
import 'widgets/product_form.dart';
import 'widgets/product_image_picker.dart';

/// 商品の新規登録または編集を行う画面
class ProductEditScreen extends StatefulWidget {
  final Product? product; // nullの場合は新規登録モード

  const ProductEditScreen({super.key, this.product});

  @override
  State<ProductEditScreen> createState() =>
      _ProductEditScreenState();
}

class _ProductEditScreenState
    extends State<ProductEditScreen> {
  late final FormGroup form;
  late final bool _isEditing;

  // カテゴリ候補と画像パスは、UIの状態として親が管理する
  List<String> _categoryOptions = [];
  String? _imagePath;

  @override
  void initState() {
    super.initState();

    _isEditing = widget.product != null;
    _imagePath = _isEditing
        ? widget.product!.imagePath
        : null;

    _initializeForm();
    _loadInitialData();
  }

  /// フォームの定義と初期化
  void _initializeForm() {
    form = FormGroup({
      'barcode': FormControl<String>(
        value: _isEditing ? widget.product!.barcode : '',
        asyncValidators: [
          // 編集モードと新規登録モードで適用する非同期バリデーターを切り替え
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

  /// カテゴリ候補などの初期データを非同期でロードする
  void _loadInitialData() {
    // initState内でProviderから安全にデータを取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.products.isEmpty) {
        provider.reloadProducts().then((_) {
          if (mounted) {
            setState(
              () => _categoryOptions =
                  provider.pureCategories,
            );
          }
        });
      } else {
        setState(
          () => _categoryOptions = provider.pureCategories,
        );
      }
    });
  }

  /// フォームを保存する処理
  Future<void> _saveForm() async {
    if (form.invalid) {
      form.markAllAsTouched(); // 無効な場合、エラーメッセージを表示
      return;
    }

    // フォームの値を取得し、Productモデルに変換
    final newProduct = _createProductFromForm();
    final provider = context.read<ProductProvider>();

    // 編集モードかどうかに応じて、更新または追加処理を呼び出す
    if (_isEditing) {
      await provider.updateProduct(newProduct);
    } else {
      await provider.addProduct(newProduct);
    }

    if (mounted) Navigator.pop(context);
  }

  /// フォームの入力値からProductオブジェクトを生成する
  Product _createProductFromForm() {
    String? barcodeValue = form.control('barcode').value;
    if (barcodeValue != null &&
        barcodeValue.trim().isEmpty) {
      barcodeValue = null; // 空白のみのバーコードはnullとして扱う
    }

    String categoryValue =
        form.control('category').value ?? '';
    if (categoryValue.trim().isEmpty) {
      categoryValue = '未分類'; // カテゴリ未入力の場合は「未分類」とする
    }

    return Product(
      id: _isEditing ? widget.product!.id : null,
      barcode: barcodeValue,
      name: form.control('name').value,
      price: form.control('price').value,
      category: categoryValue,
      imagePath: _imagePath,
    );
  }

  /// バーコードスキャナダイアログを表示
  void _showBarcodeScannerDialog() {
    final activeFormats = context
        .read<SettingsProvider>()
        .activeBarcodeFormats;
    final scannerController = MobileScannerController(
      formats: activeFormats,
    );
    final soundService = SoundService();

    final vibrationEnabled = context
        .read<SettingsProvider>()
        .vibrationEnabled;
    final volume = context.read<SettingsProvider>().volume;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('バーコードをスキャン'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: MobileScanner(
            controller: scannerController,
            onDetect: (capture) {
              final barcodeValue =
                  capture.barcodes.first.rawValue;
              if (barcodeValue != null &&
                  barcodeValue.isNotEmpty) {
                soundService.playSuccessSound(
                  vibrationEnabled: vibrationEnabled,
                  volume: volume,
                );
                form.control('barcode').value =
                    barcodeValue; // フォームに値をセット
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
      ),
    );
  }

  /// 商品を削除する処理
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
              backgroundColor: Theme.of(
                context,
              ).colorScheme.error,
            ),
            child: const Text('削除'),
            onPressed: () async {
              final provider = context
                  .read<ProductProvider>();
              await provider.deleteProduct(
                widget.product!.id!,
              );
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pop(ctx); // ダイアログを閉じる
              Navigator.pop(context); // 編集画面を閉じる
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
            children: [
              // 画像選択ウィジェット
              ProductImagePicker(
                initialImagePath: _imagePath,
                onImageChanged: (newPath) {
                  setState(
                    () => _imagePath = newPath,
                  ); // 子からの通知でStateを更新
                },
              ),
              const SizedBox(height: 24),

              // フォーム入力ウィジェット
              ProductForm(
                categoryOptions: _categoryOptions,
                onScanBarcode: _showBarcodeScannerDialog,
              ),
              const SizedBox(height: 40),

              // アクションボタンウィジェット
              FormActionButtons(
                isEditing: _isEditing,
                onCancel: () => Navigator.pop(context),
                onSave: _saveForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
