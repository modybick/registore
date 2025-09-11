// screens/product_edit/widgets/form_action_buttons.dart

import 'package:flutter/material.dart';

/// フォームの主要なアクションボタン（キャンセル、保存）ウィジェット
class FormActionButtons extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const FormActionButtons({
    super.key,
    required this.isEditing,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
            ),
            child: const Text('キャンセル'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
            ),
            child: Text(isEditing ? '更新' : '登録'),
          ),
        ),
      ],
    );
  }
}
