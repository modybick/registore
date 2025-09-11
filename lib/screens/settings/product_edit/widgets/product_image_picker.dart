// screens/product_edit/widgets/product_image_picker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:registore/services/image_service.dart';

/// 商品画像の選択、表示、削除を行うウィジェット
class ProductImagePicker extends StatefulWidget {
  final String? initialImagePath;
  final ValueChanged<String?> onImageChanged;

  const ProductImagePicker({
    super.key,
    this.initialImagePath,
    required this.onImageChanged,
  });

  @override
  State<ProductImagePicker> createState() =>
      _ProductImagePickerState();
}

class _ProductImagePickerState
    extends State<ProductImagePicker> {
  final ImageService _imageService = ImageService();
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.initialImagePath;
  }

  /// 画像を選択し、親ウィジェットに通知する
  Future<void> _pickImage(ImageSourceType source) async {
    final file = await _imageService.pickAndCropImage(
      source,
      Theme.of(context).colorScheme,
    );
    if (file != null) {
      setState(() => _currentImagePath = file.path);
      widget.onImageChanged(_currentImagePath); // 変更を親に通知
    }
  }

  /// 画像を削除し、親ウィジェットに通知する
  void _deleteImage() {
    setState(() => _currentImagePath = null);
    widget.onImageChanged(null); // 変更を親に通知
  }

  /// 画像ソース（カメラ/ギャラリー）選択のモーダルを表示
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('カメラで撮影'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSourceType.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSourceType.gallery);
              },
            ),
            if (_currentImagePath != null) ...[
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(
                    context,
                  ).colorScheme.error,
                ),
                title: Text(
                  '画像を削除',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.error,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteImage();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: _currentImagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_currentImagePath!),
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.camera_alt,
                size: 50,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant,
              ),
      ),
    );
  }
}
