
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phoneNumber = '',
    this.createdAt,
  });

  // Chuyển dữ liệu Firestore thành UserProfile
  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return UserProfile(
      uid: document.id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Chuyển UserProfile thành dữ liệu lưu Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  // Tạo bản sao hồ sơ với thông tin mới
  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt,
    );
  }
}
