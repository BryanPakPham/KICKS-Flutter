
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/address.dart';

class AddressService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Lấy collection địa chỉ của tài khoản đang đăng nhập
  CollectionReference<Map<String, dynamic>>
      get _addresses {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Người dùng chưa đăng nhập');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('addresses');
  }

  // =========================
  // 1. LẤY DANH SÁCH ĐỊA CHỈ
  // =========================
  Stream<List<ShippingAddress>> watchAddresses() {
    return _addresses.snapshots().map((snapshot) {
      final addresses = snapshot.docs
          .map(ShippingAddress.fromFirestore)
          .toList();

      // Địa chỉ mặc định hiển thị đầu tiên
      addresses.sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }

        final dateA = a.createdAt;
        final dateB = b.createdAt;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA);
      });

      return addresses;
    });
  }

  // =========================
  // 2. THÊM ĐỊA CHỈ
  // =========================
  Future<void> addAddress(ShippingAddress address) async {
    final collection = _addresses;
    final snapshot = await collection.get();

    final isFirstAddress = snapshot.docs.isEmpty;

    final newDoc = collection.doc();
    final batch = _firestore.batch();

    // Nếu địa chỉ mới được đặt làm mặc định,
    // bỏ mặc định của các địa chỉ cũ.
    if (address.isDefault) {
      for (final doc in snapshot.docs) {
        if (doc.data()['isDefault'] == true) {
          batch.update(
            doc.reference,
            {'isDefault': false},
          );
        }
      }
    }

    batch.set(newDoc, {
      ...address.toFirestore(),
      'isDefault': isFirstAddress || address.isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // =========================
  // 3. CHỈNH SỬA ĐỊA CHỈ
  // =========================
  Future<void> updateAddress(
    ShippingAddress address,
  ) async {
    if (address.id.isEmpty) {
      throw ArgumentError('ID địa chỉ không hợp lệ');
    }

    await _addresses.doc(address.id).update({
      'fullName': address.fullName.trim(),
      'phoneNumber': address.phoneNumber.trim(),
      'streetAddress': address.streetAddress.trim(),
      'ward': address.ward.trim(),
      'province': address.province.trim(),
      'note': address.note.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // 4. XÓA ĐỊA CHỈ
  // =========================
  Future<void> deleteAddress(String addressId) async {
    final collection = _addresses;
    final snapshot = await collection.get();

    final matching = snapshot.docs.where(
      (doc) => doc.id == addressId,
    );

    if (matching.isEmpty) {
      throw StateError('Không tìm thấy địa chỉ');
    }

    final deletedDoc = matching.first;
    final wasDefault =
        deletedDoc.data()['isDefault'] == true;

    final remaining = snapshot.docs
        .where((doc) => doc.id != addressId)
        .toList();

    final batch = _firestore.batch();

    batch.delete(deletedDoc.reference);

    // Nếu xóa địa chỉ mặc định,
    // tự chọn địa chỉ khác làm mặc định.
    if (wasDefault && remaining.isNotEmpty) {
      batch.update(
        remaining.first.reference,
        {'isDefault': true},
      );
    }

    await batch.commit();
  }

  // =========================
  // 5. ĐẶT ĐỊA CHỈ MẶC ĐỊNH
  // =========================
  Future<void> setDefaultAddress(
    String addressId,
  ) async {
    final snapshot = await _addresses.get();

    final exists = snapshot.docs.any(
      (doc) => doc.id == addressId,
    );

    if (!exists) {
      throw StateError('Không tìm thấy địa chỉ');
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      final shouldBeDefault = doc.id == addressId;
      final currentlyDefault =
          doc.data()['isDefault'] == true;

      if (shouldBeDefault != currentlyDefault) {
        batch.update(
          doc.reference,
          {'isDefault': shouldBeDefault},
        );
      }
    }

    await batch.commit();
  }
}
