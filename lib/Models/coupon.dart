import '../utils/format.dart';

enum CouponType { percent, fixed, freeShipping }

class Coupon {
  final String code;
  final String description;
  final CouponType type;

  // percent: phần trăm giảm | fixed: số tiền giảm | freeShipping: không dùng
  final double value;

  // Giá trị đơn hàng tối thiểu để áp dụng
  final double minOrder;

  // Mức giảm tối đa (chỉ dùng cho loại percent), null = không giới hạn
  final double? maxDiscount;

  const Coupon({
    required this.code,
    required this.description,
    required this.type,
    this.value = 0,
    this.minOrder = 0,
    this.maxDiscount,
  });

  // Trả về null nếu hợp lệ, ngược lại trả về lý do không hợp lệ
  String? validate(double subtotal) {
    if (subtotal < minOrder) {
      return 'Đơn hàng tối thiểu ${formatPrice(minOrder)} '
          'để dùng mã $code';
    }
    return null;
  }

  // Số tiền được giảm trực tiếp trên tiền hàng
  double discountOn(double subtotal) {
    if (validate(subtotal) != null) return 0;

    switch (type) {
      case CouponType.percent:
        final raw = subtotal * value / 100;
        final capped = maxDiscount == null
            ? raw
            : (raw > maxDiscount! ? maxDiscount! : raw);
        return capped.roundToDouble();
      case CouponType.fixed:
        return value > subtotal ? subtotal : value;
      case CouponType.freeShipping:
        return 0;
    }
  }

  bool get isFreeShipping => type == CouponType.freeShipping;
}
