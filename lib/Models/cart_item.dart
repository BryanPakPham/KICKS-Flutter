import 'package:cloud_firestore/cloud_firestore.dart';

// Giới hạn số lượng tối đa cho mỗi dòng sản phẩm trong giỏ
const int kMaxCartQuantity = 10;

class CartItem {
  // ID dòng giỏ hàng = productId + màu + size
  final String id;
  final int productId;
  final String productCode;
  final String name;
  final String colorName;
  final String size;
  final String image;
  final double unitPrice;
  final int quantity;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productCode,
    required this.name,
    required this.colorName,
    required this.size,
    required this.image,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  // Tạo ID ổn định cho từng biến thể (sản phẩm + màu + size)
  static String buildId(int productId, String colorName, String size) {
    final raw = '${productId}_${colorName}_$size';
    return raw.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '-');
  }

  factory CartItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return CartItem(
      id: document.id,
      productId: (data['productId'] as num?)?.toInt() ?? 0,
      productCode: data['productCode'] as String? ?? '',
      name: data['name'] as String? ?? '',
      colorName: data['colorName'] as String? ?? '',
      size: data['size'] as String? ?? '',
      image: data['image'] as String? ?? '',
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productCode': productCode,
      'name': name,
      'colorName': colorName,
      'size': size,
      'image': image,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }
}
