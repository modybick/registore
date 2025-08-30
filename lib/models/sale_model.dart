import 'sale_detail_model.dart';

class Sale {
  final int? id;
  final double totalAmount;
  final double tenderedAmount;
  final String paymentMethod;
  final DateTime createdAt;
  final bool isCancelled;
  List<SaleDetail> details; // 詳細情報を保持するリスト

  Sale({
    this.id,
    required this.totalAmount,
    required this.tenderedAmount,
    required this.paymentMethod,
    required this.createdAt,
    this.isCancelled = false,
    this.details = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'tenderedAmount': tenderedAmount,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt
          .toIso8601String(), // 日付は文字列として保存
      'isCancelled': isCancelled ? 1 : 0,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      totalAmount: map['totalAmount'],
      tenderedAmount: map['tenderedAmount'],
      paymentMethod: map['paymentMethod'],
      createdAt: DateTime.parse(
        map['createdAt'],
      ), // 文字列から日付に変換
      isCancelled: map['isCancelled'] == 1,
    );
  }

  // 状態をコピーして新しいインスタンスを生成するメソッドを追加
  Sale copyWith({bool? isCancelled}) {
    return Sale(
      id: id,
      totalAmount: totalAmount,
      tenderedAmount: tenderedAmount,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      details: details,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}
