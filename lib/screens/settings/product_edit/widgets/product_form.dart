// screens/product_edit/widgets/product_form.dart

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_raw_autocomplete/reactive_raw_autocomplete.dart';

import '../../../../utils/currency_input_formatter.dart';
import '../../../../utils/currency_value_accessor.dart';

/// 商品情報を入力するためのフォームフィールド群ウィジェット
class ProductForm extends StatelessWidget {
  final List<String> categoryOptions;
  final VoidCallback onScanBarcode;

  const ProductForm({
    super.key,
    required this.categoryOptions,
    required this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // バーコード入力フィールド
        ReactiveTextField<String>(
          formControlName: 'barcode',
          decoration: InputDecoration(
            labelText: 'バーコード（任意）',
            prefixIcon: const Icon(Icons.barcode_reader),
            suffixIcon: IconButton(
              tooltip: 'スキャンして入力',
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: onScanBarcode,
            ),
          ),
          validationMessages: {
            'unique': (error) => 'このバーコードは既に使用されています',
          },
          showErrors: (control) =>
              control.invalid && control.touched,
        ),
        const SizedBox(height: 16),

        // 商品名入力フィールド
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

        // 価格入力フィールド
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

        // カテゴリ入力（オートコンプリート）フィールド
        _buildCategoryAutocomplete(),
      ],
    );
  }

  /// カテゴリ入力用のオートコンプリートウィジェットを構築
  Widget _buildCategoryAutocomplete() {
    return ReactiveRawAutocomplete<String, String>(
      formControlName: 'category',
      optionsBuilder: (textEditingValue) {
        final text = textEditingValue.text;
        if (text.isEmpty) return categoryOptions;
        return categoryOptions.where(
          (option) => option.toLowerCase().startsWith(
            text.toLowerCase(),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        // ... (UI部分は変更なし)
        return Align(/* ... */);
      },
      fieldViewBuilder:
          (
            context,
            controller,
            focusNode,
            onFieldSubmitted,
          ) {
            return ReactiveTextField<String>(
              formControlName: 'category',
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'カテゴリ (任意)',
                prefixIcon: Icon(Icons.category),
              ),
              onSubmitted: (_) => onFieldSubmitted(),
            );
          },
    );
  }
}
