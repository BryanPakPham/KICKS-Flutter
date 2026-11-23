import '../Models/coupon.dart';

// Danh sách mã giảm giá (cấu hình cục bộ, có thể chuyển lên Firestore sau)
const List<Coupon> availableCoupons = [
  Coupon(
    code: 'KICKS10',
    description: 'Giảm 10% (tối đa 300.000 ₫) cho đơn từ 1.000.000 ₫',
    type: CouponType.percent,
    value: 10,
    minOrder: 1000000,
    maxDiscount: 300000,
  ),
  Coupon(
    code: 'WELCOME50',
    description: 'Giảm 50.000 ₫ cho đơn từ 500.000 ₫',
    type: CouponType.fixed,
    value: 50000,
    minOrder: 500000,
  ),
  Coupon(
    code: 'FREESHIP',
    description: 'Miễn phí vận chuyển cho đơn từ 500.000 ₫',
    type: CouponType.freeShipping,
    minOrder: 500000,
  ),
];

// Tìm mã giảm giá theo code (không phân biệt hoa thường)
Coupon? findCoupon(String input) {
  final code = input.trim().toUpperCase();
  if (code.isEmpty) return null;

  for (final coupon in availableCoupons) {
    if (coupon.code == code) return coupon;
  }
  return null;
}
