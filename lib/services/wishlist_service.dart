
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/product.dart';

class WishlistService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =====================================
  // 1. LẤY TÀI KHOẢN HIỆN TẠI
  // =====================================
  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'Vui lòng đăng nhập để sử dụng danh sách yêu thích',
      );
    }

    return user.uid;
  }

  // =====================================
  // 2. COLLECTION WISHLIST
  // =====================================
  CollectionReference<Map<String, dynamic>>
      get _wishlistCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist');
  }

  // =====================================
  // 3. THEO DÕI SẢN PHẨM YÊU THÍCH
  // =====================================
  Stream<Set<int>> watchWishlistIds() {
    return _wishlistCollection.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => int.tryParse(doc.id))
            .whereType<int>()
            .toSet();
      },
    );
  }

  // =====================================
  // 4. KIỂM TRA SẢN PHẨM ĐÃ YÊU THÍCH
  // =====================================
  Future<bool> isInWishlist(int productId) async {
    final snapshot = await _wishlistCollection
        .doc(productId.toString())
        .get();

    return snapshot.exists;
  }

  // =====================================
  // 5. THÊM SẢN PHẨM VÀO WISHLIST
  // =====================================
  Future<void> addToWishlist(Product product) async {
    final docRef = _wishlistCollection
        .doc(product.id.toString());

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, {
          'productId': product.id,
          'productCode': product.productCode,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // =====================================
  // 6. XÓA SẢN PHẨM KHỎI WISHLIST
  // =====================================
  Future<void> removeFromWishlist(int productId) async {
    await _wishlistCollection
        .doc(productId.toString())
        .delete();
  }

  // =====================================
  // 7. BẬT / TẮT YÊU THÍCH
  // =====================================
  // Trả về true nếu sản phẩm được thêm,
  // false nếu sản phẩm bị bỏ yêu thích.
  Future<bool> toggleWishlist(Product product) async {
    final docRef = _wishlistCollection
        .doc(product.id.toString());

    return _firestore.runTransaction<bool>(
      (transaction) async {
        final snapshot = await transaction.get(docRef);

        if (snapshot.exists) {
          transaction.delete(docRef);
          return false;
        }

        transaction.set(docRef, {
          'productId': product.id,
          'productCode': product.productCode,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return true;
      },
    );
  }
}
