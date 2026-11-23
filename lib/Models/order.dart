import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'cart_item.dart';

// Cho phép hủy đơn "đã xác nhận" trong vòng bao nhiêu giờ kể từ lúc đặt
const int kCancelWindowHours = 24;

// =========================
// TRẠNG THÁI ĐƠN HÀNG
// =========================
enum OrderStatus {
  pending('pending', 'Chờ xác nhận', Icons.hourglass_empty),
  confirmed('confirmed', 'Đã xác nhận', Icons.check_circle_outline),
  shipping('shipping', 'Đang giao hàng', Icons.local_shipping_outlined),
  delivered('delivered', 'Đã giao hàng', Icons.inventory_2_outlined),
  cancelled('cancelled', 'Đã hủy', Icons.cancel_outlined);

  final String key;
  final String label;
  final IconData icon;

  const OrderStatus(this.key, this.label, this.icon);

  static OrderStatus fromKey(String? key) {
    return OrderStatus.values.firstWhere(
      (s) => s.key == key,
      orElse: () => OrderStatus.pending,
    );
  }

  // Trạng thái tiếp theo trong luồng giao hàng bình thường
  OrderStatus? get next {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.shipping;
      case OrderStatus.shipping:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }
}

// =========================
// PHƯƠNG THỨC THANH TOÁN
// =========================
enum PaymentMethod {
  cod(
    'cod',
    'Thanh toán khi nhận hàng (COD)',
    'Trả tiền mặt cho nhân viên giao hàng',
    Icons.payments_outlined,
  ),
  bankTransfer(
    'bank_transfer',
    'Chuyển khoản ngân hàng',
    'Thanh toán qua ngân hàng trực tuyến (mô phỏng)',
    Icons.account_balance_outlined,
  ),
  eWallet(
    'e_wallet',
    'Ví điện tử (MoMo / ZaloPay)',
    'Thanh toán qua ví điện tử (mô phỏng)',
    Icons.account_balance_wallet_outlined,
  );

  final String key;
  final String label;
  final String description;
  final IconData icon;

  const PaymentMethod(
    this.key,
    this.label,
    this.description,
    this.icon,
  );

  static PaymentMethod fromKey(String? key) {
    return PaymentMethod.values.firstWhere(
      (m) => m.key == key,
      orElse: () => PaymentMethod.cod,
    );
  }
}

// Trạng thái thanh toán
class PaymentStatus {
  static const String unpaid = 'unpaid';
  static const String paid = 'paid';
  static const String refunding = 'refunding';

  static String label(String status) {
    switch (status) {
      case paid:
        return 'Đã thanh toán';
      case refunding:
        return 'Chờ hoàn tiền';
      default:
        return 'Chưa thanh toán';
    }
  }
}

// =========================
// SẢN PHẨM TRONG ĐƠN HÀNG
// =========================
class OrderItem {
  final int productId;
  final String productCode;
  final String name;
  final String colorName;
  final String size;
  final String image;
  final double unitPrice;
  final int quantity;

  const OrderItem({
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

  factory OrderItem.fromCartItem(CartItem item) {
    return OrderItem(
      productId: item.productId,
      productCode: item.productCode,
      name: item.name,
      colorName: item.colorName,
      size: item.size,
      image: item.image,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
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

  Map<String, dynamic> toMap() {
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

// Một mốc trong lịch sử trạng thái
class StatusEntry {
  final OrderStatus status;
  final DateTime at;

  const StatusEntry({required this.status, required this.at});

  factory StatusEntry.fromMap(Map<String, dynamic> data) {
    return StatusEntry(
      status: OrderStatus.fromKey(data['status'] as String?),
      at: (data['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.key,
      'at': Timestamp.fromDate(at),
    };
  }
}

// =========================
// ĐƠN HÀNG
// =========================
class AppOrder {
  final String id;
  final String code;
  final List<OrderItem> items;

  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final String? couponCode;

  final PaymentMethod paymentMethod;
  final String paymentStatus;

  final OrderStatus status;
  final List<StatusEntry> history;

  // Thông tin giao hàng (lưu cố định tại thời điểm đặt)
  final String recipientName;
  final String phoneNumber;
  final String fullAddress;
  final String note;

  final DateTime createdAt;
  final String? cancelReason;
  final DateTime? cancelledAt;

  const AppOrder({
    required this.id,
    required this.code,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    required this.couponCode,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.history,
    required this.recipientName,
    required this.phoneNumber,
    required this.fullAddress,
    required this.note,
    required this.createdAt,
    this.cancelReason,
    this.cancelledAt,
  });

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  // Thời điểm một trạng thái được ghi nhận (nếu có)
  DateTime? timeOf(OrderStatus status) {
    for (final entry in history) {
      if (entry.status == status) return entry.at;
    }
    return null;
  }

  // ------------------------------------------------
  // ĐIỀU KIỆN HỦY ĐƠN
  // - Chờ xác nhận: được hủy bất cứ lúc nào
  // - Đã xác nhận: chỉ được hủy trong 24 giờ kể từ lúc đặt
  // - Đang giao / Đã giao / Đã hủy: không thể hủy
  // ------------------------------------------------
  bool get canCancel => cancelBlockedReason == null;

  String? get cancelBlockedReason {
    switch (status) {
      case OrderStatus.pending:
        return null;
      case OrderStatus.confirmed:
        final deadline = createdAt.add(
          const Duration(hours: kCancelWindowHours),
        );
        if (DateTime.now().isAfter(deadline)) {
          return 'Đơn đã xác nhận chỉ được hủy trong '
              '$kCancelWindowHours giờ kể từ khi đặt hàng.';
        }
        return null;
      case OrderStatus.shipping:
        return 'Đơn hàng đang được giao nên không thể hủy.';
      case OrderStatus.delivered:
        return 'Đơn hàng đã giao nên không thể hủy.';
      case OrderStatus.cancelled:
        return 'Đơn hàng đã được hủy trước đó.';
    }
  }

  factory AppOrder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final items = ((data['items'] as List?) ?? [])
        .whereType<Map>()
        .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final history = ((data['history'] as List?) ?? [])
        .whereType<Map>()
        .map((e) => StatusEntry.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return AppOrder(
      id: document.id,
      code: data['code'] as String? ?? document.id,
      items: items,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      shippingFee: (data['shippingFee'] as num?)?.toDouble() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      couponCode: data['couponCode'] as String?,
      paymentMethod:
          PaymentMethod.fromKey(data['paymentMethod'] as String?),
      paymentStatus:
          data['paymentStatus'] as String? ?? PaymentStatus.unpaid,
      status: OrderStatus.fromKey(data['status'] as String?),
      history: history,
      recipientName: data['recipientName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      fullAddress: data['fullAddress'] as String? ?? '',
      note: data['note'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cancelReason: data['cancelReason'] as String?,
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }
}
