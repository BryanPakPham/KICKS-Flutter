
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/user_profile.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Lấy người dùng hiện tại
  User get currentUser {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Người dùng chưa đăng nhập');
    }

    return user;
  }

  // Lấy đường dẫn hồ sơ trong Firestore
  DocumentReference<Map<String, dynamic>>
      get _userDocument {
    return _firestore
        .collection('users')
        .doc(currentUser.uid);
  }

  // Tạo hồ sơ nếu tài khoản chưa có dữ liệu Firestore
  Future<UserProfile> getOrCreateProfile() async {
    final user = currentUser;
    final docRef = _userDocument;
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      return UserProfile.fromFirestore(snapshot);
    }

    final profile = UserProfile(
      uid: user.uid,
      fullName: user.displayName ?? '',
      email: user.email ?? '',
      phoneNumber: '',
    );

    await docRef.set({
      ...profile.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return profile;
  }

  // Theo dõi thông tin hồ sơ
  Stream<UserProfile?> watchProfile() {
    return _userDocument.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return UserProfile.fromFirestore(snapshot);
    });
  }

  // Cập nhật thông tin cá nhân
  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    if (fullName.trim().isEmpty) {
      throw ArgumentError('Họ tên không được để trống');
    }

    await _userDocument.set({
      'fullName': fullName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await currentUser.updateDisplayName(fullName.trim());
  }
}
