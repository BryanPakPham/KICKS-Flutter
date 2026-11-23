import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/cart_item.dart';
import '../Models/product.dart';
import '../Models/product_color.dart';

class CartService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection giỏ hàng của tài khoản đang đăng nhập
  CollectionReference<Map<String, dynamic>> get _cart {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Vui lòng đăng nhập để sử dụng giỏ hàng');
    }

    return _firestore.collection('users').doc(user.uid).collection('cart');
  }

  // =========================
  // 1. THEO DÕI GIỎ HÀNG
  // =========================
  Stream<List<CartItem>> watchCart() {
    return _cart.orderBy('addedAt').snapshots().map((snapshot) {
      return snapshot.docs.map(CartItem.fromFirestore).toList();
    });
  }

  // Tổng số lượng sản phẩm trong giỏ (dùng cho badge)
  Stream<int> watchCartCount() {
    return watchCart().map(
      (items) => items.fold<int>(0, (sum, item) => sum + item.quantity),
    );
  }

  // =========================
  // 2. THÊM SẢN PHẨM
  // Cùng sản phẩm + màu + size => cộng dồn số lượng
  // =========================
  // Trả về số lượng hiện tại của dòng đó sau khi thêm.
  Future<int> addItem({
    required Product product,
    required ProductColor color,
    required String size,
    int quantity = 1,
  }) async {
    final id = CartItem.buildId(product.id, color.name, size);
    final docRef = _cart.doc(id);

    return _firestore.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        final current =
            (snapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
        final next = current + quantity;
        final capped = next > kMaxCartQuantity ? kMaxCartQuantity : next;

        transaction.update(docRef, {'quantity': capped});
        return capped;
      }

      final capped =
          quantity > kMaxCartQuantity ? kMaxCartQuantity : quantity;

      transaction.set(docRef, {
        'productId': product.id,
        'productCode': product.productCode,
        'name': product.name,
        'colorName': color.name,
        'size': size,
        'image': color.sideImage,
        'unitPrice': product.price,
        'quantity': capped,
        'addedAt': FieldValue.serverTimestamp(),
      });
      return capped;
    });
  }

  // =========================
  // 3. CẬP NHẬT SỐ LƯỢNG
  // Số lượng <= 0 => xóa khỏi giỏ
  // =========================
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    final capped = quantity > kMaxCartQuantity ? kMaxCartQuantity : quantity;

    await _cart.doc(itemId).update({'quantity': capped});
  }

  // =========================
  // 4. XÓA SẢN PHẨM
  // =========================
  Future<void> removeItem(String itemId) async {
    await _cart.doc(itemId).delete();
  }

  // =========================
  // 5. XÓA TOÀN BỘ GIỎ HÀNG
  // =========================
  Future<void> clear() async {
    final snapshot = await _cart.get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
