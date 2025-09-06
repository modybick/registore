import 'package:flutter/material.dart';

/// ラジオボタンの選択肢のデータ構造を定義
class RadioOption<T> {
  final String title;
  final T value;

  const RadioOption({
    required this.title,
    required this.value,
  });
}

/// 複数のRadioListTileを生成・管理するためのカスタムウィジェット
class RadioGroup<T> extends StatelessWidget {
  final String title;
  final IconData? icon;
  final T groupValue;
  final List<RadioOption<T>> options;
  final ValueChanged<T?> onChanged;

  const RadioGroup({
    super.key,
    required this.title,
    this.icon,
    required this.groupValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // グループ全体のタイトル
        ListTile(
          leading: icon != null ? Icon(icon) : null,
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 選択肢からラジオボタンを生成
        Column(
          children: options.map((option) {
            return RadioListTile<T>(
              title: Text(option.title),
              value: option.value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: onChanged,
            );
          }).toList(),
        ),
      ],
    );
  }
}
