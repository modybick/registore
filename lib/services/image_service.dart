import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

// 画像の取得元（カメラ or ギャラリー）を定義
enum ImageSourceType { camera, gallery }

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// 画像を選択し、トリミングして、そのファイルのパスを返す
  Future<File?> pickAndCropImage(
    ImageSourceType source,
  ) async {
    // 1. 画像を選択
    final pickedFile = await _picker.pickImage(
      source: source == ImageSourceType.camera
          ? ImageSource.camera
          : ImageSource.gallery,
    );

    if (pickedFile == null) {
      return null; // ユーザーが選択をキャンセル
    }

    // 2. 選択した画像をトリミング
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80, // 画質を80%に圧縮
      aspectRatio: const CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ), // 縦横比を1:1に固定
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '画像のトリミング',
          toolbarColor: Colors.teal,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true, // 縦横比を固定
        ),
        IOSUiSettings(
          title: '画像のトリミング',
          aspectRatioLockEnabled: true, // 縦横比を固定
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile == null) {
      return null; // ユーザーがトリミングをキャンセル
    }

    return File(croppedFile.path);
  }
}
