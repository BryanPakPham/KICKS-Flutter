import '../Models/cart_item.dart';
import '../Models/coupon.dart';

// Phí vận chuyển cố định, miễn phí từ ngưỡng bên dưới
const double kShippingFee = 30000;
const double kFreeShippingThreshold = 2000000;

// Kết quả tính tiền của một giỏ hàng
class OrderPricing {
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final Coupon? appliedCoupon;

  const OrderPricing({
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    this.appliedCoupon,
  });

  // Tính: tổng = tiền hàng + phí ship - giảm giá
  // Mã không hợp lệ (chưa đủ điều kiện) sẽ bị bỏ qua.
  factory OrderPricing.calculate(
    List<CartItem> items, {
    Coupon? coupon,
  }) {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );

    final validCoupon =
        (coupon != null && coupon.validate(subtotal) == null)
            ? coupon
            : null;

    double shipping = 0;
    if (items.isNotEmpty && subtotal < kFreeShippingThreshold) {
      shipping = kShippingFee;
    }
    if (validCoupon != null && validCoupon.isFreeShipping) {
      shipping = 0;
    }

    final discount = validCoupon?.discountOn(subtotal) ?? 0;
    final total = subtotal + shipping - discount;

    return OrderPricing(
      subtotal: subtotal,
      shippingFee: shipping,
      discount: discount,
      total: total < 0 ? 0 : total,
      appliedCoupon: validCoupon,
    );
  }
}
