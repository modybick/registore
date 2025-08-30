import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:registore/models/sale_model.dart';
import '../models/product_model.dart';
import 'database_service.dart';

class CsvService {
  /// CSVファイルを選択し、商品DBをインポートする
  /// 戻り値: 処理結果のメッセージ
  Future<String> importProductsFromCsv() async {
    try {
      // 1. ファイルピッカーを開いてCSVファイルを選択させる
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        return 'ファイルの選択がキャンセルされました。';
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return 'ファイルパスが取得できませんでした。';
      }

      // 2. ファイルを読み込み、CSVとして解析する
      final file = File(filePath);
      // UTF-8で読み込む
      final csvString = await file.readAsString(
        encoding: utf8,
      );

      // CsvToListConverterを使って、文字列をList<List<dynamic>>に変換
      final List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvString);

      // 3. 解析したデータをProductオブジェクトのリストに変換
      final List<Product> productsToImport = [];
      // 1行目(i=0)はヘッダーなのでスキップ
      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        try {
          // CSVの各列が正しいフォーマットかチェック
          final product = Product(
            barcode: row[0].toString(),
            name: row[1].toString(),
            price: int.parse(row[2].toString()),
            category: row[3].toString(),
          );
          productsToImport.add(product);
        } catch (e) {
          return 'エラー: ${i + 1}行目のデータ形式が正しくありません。\n(バーコード, 商品名, 価格(整数), カテゴリ) の順になっているか確認してください。';
        }
      }

      if (productsToImport.isEmpty) {
        return 'インポート対象の商品データが見つかりませんでした。';
      }

      // 4. DatabaseServiceを呼び出してDBに保存
      await DatabaseService.instance.importProducts(
        productsToImport,
      );

      return '成功: ${productsToImport.length}件の商品をインポートしました。';
    } catch (e) {
      return 'エラーが発生しました: ${e.toString()}';
    }
  }

  /// 販売履歴リストをCSVファイルとしてデバイスに保存する
  /// 戻り値: 処理結果のメッセージ
  Future<String> saveSalesHistoryAsCsv(
    List<Sale> sales,
  ) async {
    if (sales.isEmpty) {
      return '保存対象の販売履歴がありません。';
    }

    try {
      // 1. CSVデータのヘッダー行を作成
      List<List<dynamic>> rows = [];
      rows.add([
        '販売ID',
        '販売日時',
        '支払方法',
        '合計金額',
        'お預かり金額',
        '商品名',
        '単価',
        '数量',
        '小計',
      ]);

      // 2. 各販売履歴とその詳細をCSVの行に変換
      for (final sale in sales) {
        // 各販売履歴に紐づく詳細データをDBから取得
        final details = await DatabaseService.instance
            .getSaleDetails(sale.id!);
        if (details.isEmpty) {
          // 商品がない取引も記録に残す場合
          rows.add([
            sale.id,
            DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).format(sale.createdAt),
            sale.paymentMethod,
            sale.totalAmount,
            sale.tenderedAmount,
            '(商品なし)',
            '',
            '',
            '',
          ]);
        } else {
          for (final detail in details) {
            rows.add([
              sale.id,
              DateFormat(
                'yyyy-MM-dd HH:mm:ss',
              ).format(sale.createdAt),
              sale.paymentMethod,
              sale.totalAmount,
              sale.tenderedAmount,
              detail.productName,
              detail.price,
              detail.quantity,
              detail.price * detail.quantity, // 小計を計算
            ]);
          }
        }
      }

      // 2. CSV文字列に変換
      final String csv = const ListToCsvConverter().convert(
        rows,
      );

      // 3. CSV文字列をバイトデータ(Uint8List)に変換
      final Uint8List bytes = utf8.encode(csv);

      // 4. ファイル保存ダイアログを開く
      final String defaultFileName =
          'sales_history_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';

      final String? outputPath = await FilePicker.platform
          .saveFile(
            dialogTitle: '販売履歴を保存',
            fileName: defaultFileName,
            type: FileType.custom,
            allowedExtensions: ['csv'],
            bytes: bytes,
          );

      // 5. 結果を判定
      if (outputPath != null) {
        return 'CSVファイルの保存に成功しました。';
      } else {
        return 'ファイルの保存がキャンセルされました。';
      }
    } catch (e) {
      return '保存中にエラーが発生しました: ${e.toString()}';
    }
  }
}
