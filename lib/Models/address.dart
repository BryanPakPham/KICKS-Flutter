
import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingAddress {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String streetAddress;
  final String ward;
  final String province;
  final String note;
  final bool isDefault;
  final DateTime? createdAt;

  const ShippingAddress({
    this.id = '',
    required this.fullName,
    required this.phoneNumber,
    required this.streetAddress,
    required this.ward,
    required this.province,
    this.note = '',
    this.isDefault = false,
    this.createdAt,
  });

  // ĐỌC DỮ LIỆU TỪ FIRESTORE
  factory ShippingAddress.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return ShippingAddress(
      id: document.id,
      fullName: data['fullName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      streetAddress:
          data['streetAddress'] as String? ?? '',
      ward: data['ward'] as String? ?? '',
      province: data['province'] as String? ?? '',
      note: data['note'] as String? ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // CHUYỂN DỮ LIỆU ĐỂ LƯU VÀO FIRESTORE
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'streetAddress': streetAddress,
      'ward': ward,
      'province': province,
      'note': note,
      'isDefault': isDefault,
      if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  // TẠO BẢN SAO ĐỂ CẬP NHẬT THÔNG TIN
  ShippingAddress copyWith({
    String? fullName,
    String? phoneNumber,
    String? streetAddress,
    String? ward,
    String? province,
    String? note,
    bool? isDefault,
  }) {
    return ShippingAddress(
      id: id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      streetAddress: streetAddress ?? this.streetAddress,
      ward: ward ?? this.ward,
      province: province ?? this.province,
      note: note ?? this.note,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }
}
