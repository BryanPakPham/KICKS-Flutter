import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/address.dart';
import '../Models/cart_item.dart';
import '../Models/coupon.dart';
import '../Models/order.dart';
import '../utils/pricing.dart';

// Bật nút "giả lập cập nhật trạng thái" trong màn hình chi tiết đơn.
// App chưa có trang quản trị nên dùng để demo luồng trạng thái.
// Đặt thành false khi nộp bản cuối / triển khai thật.
const bool kEnableDemoOrderControls = true;

class OrderService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _userDoc {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Vui lòng đăng nhập để xem đơn hàng');
    }

    return _firestore.collection('users').doc(user.uid);
  }

  CollectionReference<Map<String, dynamic>> get _orders =>
      _userDoc.collection('orders');

  // Tạo mã đơn dạng KS240115-4821
  String _generateCode(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');

    final date = '${two(now.year % 100)}${two(now.month)}${two(now.day)}';
    final suffix = (now.microsecondsSinceEpoch % 10000)
        .toString()
        .padLeft(4, '0');

    return 'KS$date-$suffix';
  }

  // =========================
  // 1. ĐẶT HÀNG (CHECKOUT)
  // Lưu đơn + xóa các sản phẩm đã đặt khỏi giỏ trong 1 batch
  // =========================
  Future<String> placeOrder({
    required List<CartItem> items,
    required ShippingAddress address,
    required PaymentMethod paymentMethod,
    Coupon? coupon,
    String note = '',
  }) async {
    if (items.isEmpty) {
      throw StateError('Giỏ hàng đang trống');
    }

    final pricing = OrderPricing.calculate(items, coupon: coupon);
    final now = DateTime.now();
    final orderRef = _orders.doc();
    final cartRef = _userDoc.collection('cart');

    final fullAddress = [
      address.streetAddress,
      address.ward,
      address.province,
    ].where((part) => part.trim().isNotEmpty).join(', ');

    // COD: thanh toán khi nhận hàng. Các phương thức còn lại được
    // mô phỏng là đã thanh toán (chưa kết nối cổng thanh toán thật).
    final paymentStatus = paymentMethod == PaymentMethod.cod
        ? PaymentStatus.unpaid
        : PaymentStatus.paid;

    final batch = _firestore.batch();

    batch.set(orderRef, {
      'code': _generateCode(now),
      'items': items
          .map((item) => OrderItem.fromCartItem(item).toMap())
          .toList(),
      'subtotal': pricing.subtotal,
      'shippingFee': pricing.shippingFee,
      'discount': pricing.discount,
      'total': pricing.total,
      'couponCode': pricing.appliedCoupon?.code,
      'paymentMethod': paymentMethod.key,
      'paymentStatus': paymentStatus,
      'status': OrderStatus.pending.key,
      'history': [
        StatusEntry(status: OrderStatus.pending, at: now).toMap(),
      ],
      'recipientName': address.fullName,
      'phoneNumber': address.phoneNumber,
      'fullAddress': fullAddress,
      'note': note.trim(),
      'createdAt': Timestamp.fromDate(now),
    });

    for (final item in items) {
      batch.delete(cartRef.doc(item.id));
    }

    await batch.commit();

    return orderRef.id;
  }

  // =========================
  // 2. LỊCH SỬ MUA HÀNG (mới nhất trước)
  // =========================
  Stream<List<AppOrder>> watchOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(AppOrder.fromFirestore).toList();
    });
  }

  // =========================
  // 3. THEO DÕI MỘT ĐƠN HÀNG (trạng thái cập nhật realtime)
  // =========================
  Stream<AppOrder?> watchOrder(String orderId) {
    return _orders.doc(orderId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return AppOrder.fromFirestore(snapshot);
    });
  }

  // =========================
  // 4. HỦY ĐƠN HÀNG (kiểm tra điều kiện bằng dữ liệu mới nhất)
  // =========================
  Future<void> cancelOrder(String orderId, String reason) async {
    final docRef = _orders.doc(orderId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw StateError('Không tìm thấy đơn hàng');
      }

      final order = AppOrder.fromFirestore(snapshot);
      final blocked = order.cancelBlockedReason;

      if (blocked != null) {
        throw StateError(blocked);
      }

      final now = DateTime.now();

      transaction.update(docRef, {
        'status': OrderStatus.cancelled.key,
        'cancelReason': reason,
        'cancelledAt': Timestamp.fromDate(now),
        // Đơn đã thanh toán online => chờ hoàn tiền
        if (order.paymentStatus == PaymentStatus.paid)
          'paymentStatus': PaymentStatus.refunding,
        'history': FieldValue.arrayUnion([
          StatusEntry(status: OrderStatus.cancelled, at: now).toMap(),
        ]),
      });
    });
  }

  // =========================
  // 5. (DEMO) CHUYỂN SANG TRẠNG THÁI TIẾP THEO
  // Thực tế bước này do phía cửa hàng / quản trị thực hiện.
  // =========================
  Future<void> advanceStatus(String orderId) async {
    final docRef = _orders.doc(orderId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw StateError('Không tìm thấy đơn hàng');
      }

      final order = AppOrder.fromFirestore(snapshot);
      final next = order.status.next;

      if (next == null) {
        throw StateError('Đơn hàng không thể chuyển trạng thái nữa');
      }

      final now = DateTime.now();

      transaction.update(docRef, {
        'status': next.key,
        // COD: thu tiền khi giao thành công
        if (next == OrderStatus.delivered &&
            order.paymentMethod == PaymentMethod.cod)
          'paymentStatus': PaymentStatus.paid,
        'history': FieldValue.arrayUnion([
          StatusEntry(status: next, at: now).toMap(),
        ]),
      });
    });
  }
}
