class SaleDetail {
  final int? id;
  final int saleId;
  final String productName;
  final int price;
  final int quantity;

  SaleDetail({
    this.id,
    required this.saleId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory SaleDetail.fromMap(Map<String, dynamic> map) {
    return SaleDetail(
      id: map['id'],
      saleId: map['saleId'],
      productName: map['productName'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}
