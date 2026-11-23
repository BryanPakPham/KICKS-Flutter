import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/cart_item.dart';
import '../Models/coupon.dart';
import '../data/coupon_data.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../utils/format.dart';
import '../utils/pricing.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final TextEditingController _couponController = TextEditingController();

  // Giữ stream ổn định theo từng tài khoản
  Stream<List<CartItem>>? _cartStream;
  String? _cartUserId;

  Coupon? _coupon;
  String? _couponMessage;

  // Các dòng đang được cập nhật (tránh bấm liên tục)
  final Set<String> _busyIds = {};

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Stream<List<CartItem>> _streamFor(String uid) {
    if (_cartUserId != uid) {
      _cartUserId = uid;
      _cartStream = _cartService.watchCart();
      _coupon = null;
      _couponMessage = null;
    }
    return _cartStream!;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================
  // CẬP NHẬT SỐ LƯỢNG
  // =========================
  Future<void> _changeQuantity(CartItem item, int quantity) async {
    if (_busyIds.contains(item.id)) return;

    setState(() => _busyIds.add(item.id));

    try {
      await _cartService.updateQuantity(item.id, quantity);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Không thể cập nhật số lượng. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _busyIds.remove(item.id));
    }
  }

  // =========================
  // XÓA SẢN PHẨM
  // =========================
  Future<void> _removeItem(CartItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'XÓA SẢN PHẨM',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text('Xóa "${item.name}" khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'HỦY',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'XÓA',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _cartService.removeItem(item.id);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Không thể xóa sản phẩm. Vui lòng thử lại.');
    }
  }

  // =========================
  // ÁP DỤNG / GỠ MÃ GIẢM GIÁ
  // =========================
  void _applyCoupon(double subtotal) {
    FocusScope.of(context).unfocus();

    final input = _couponController.text;
    final coupon = findCoupon(input);

    if (input.trim().isEmpty) {
      setState(() => _couponMessage = 'Vui lòng nhập mã giảm giá');
      return;
    }

    if (coupon == null) {
      setState(() {
        _coupon = null;
        _couponMessage = 'Mã giảm giá không tồn tại';
      });
      return;
    }

    final error = coupon.validate(subtotal);

    if (error != null) {
      setState(() {
        _coupon = null;
        _couponMessage = error;
      });
      return;
    }

    setState(() {
      _coupon = coupon;
      _couponMessage = null;
      _couponController.clear();
    });
  }

  void _removeCoupon() {
    setState(() {
      _coupon = null;
      _couponMessage = null;
    });
  }

  // Chọn nhanh từ danh sách mã khả dụng
  void _showCouponList(double subtotal) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MÃ GIẢM GIÁ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...availableCoupons.map((coupon) {
                  final error = coupon.validate(subtotal);
                  final usable = error == null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEAEAEA)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coupon.code,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: usable ? Colors.black : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                coupon.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: usable
                              ? () {
                                  Navigator.pop(sheetContext);
                                  setState(() {
                                    _coupon = coupon;
                                    _couponMessage = null;
                                  });
                                }
                              : null,
                          child: Text(
                            'ÁP DỤNG',
                            style: TextStyle(
                              color: usable ? Colors.black : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'GIỎ HÀNG',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final user = authSnapshot.data;

          if (user == null) {
            return _buildMessage(
              icon: Icons.shopping_bag_outlined,
              title: 'BẠN CHƯA ĐĂNG NHẬP',
              subtitle: 'Đăng nhập để xem giỏ hàng và đặt hàng.',
              buttonText: 'ĐĂNG NHẬP',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            );
          }

          return StreamBuilder<List<CartItem>>(
            stream: _streamFor(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Không thể tải giỏ hàng'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                );
              }

              final items = snapshot.data!;

              if (items.isEmpty) {
                return _buildMessage(
                  icon: Icons.shopping_bag_outlined,
                  title: 'GIỎ HÀNG TRỐNG',
                  subtitle: 'Hãy chọn cho mình một đôi giày ưng ý nhé!',
                );
              }

              return _buildCart(items);
            },
          );
        },
      ),
    );
  }

  // =========================
  // GIAO DIỆN GIỎ HÀNG
  // =========================
  Widget _buildCart(List<CartItem> items) {
    final subtotal = items.fold<double>(0, (s, i) => s + i.lineTotal);

    // Mã đang áp dụng nhưng không còn đủ điều kiện (vd: xóa bớt hàng)
    final couponError = _coupon?.validate(subtotal);
    final pricing = OrderPricing.calculate(items, coupon: _coupon);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              ...items.map(_buildItem),
              const SizedBox(height: 16),
              _buildCouponSection(subtotal, couponError),
            ],
          ),
        ),
        _buildSummary(items, pricing),
      ],
    );
  }

  Widget _buildItem(CartItem item) {
    final busy = _busyIds.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              item.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _removeItem(item),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Màu: ${item.colorName}  •  Cỡ: ${item.size}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(item.unitPrice),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepper(item, busy),
                    Text(
                      formatPrice(item.lineTotal),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(CartItem item, bool busy) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: busy ? null : () => _changeQuantity(item, item.quantity - 1),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.remove, size: 18),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: (busy || item.quantity >= kMaxCartQuantity)
                ? null
                : () => _changeQuantity(item, item.quantity + 1),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.add,
                size: 18,
                color: item.quantity >= kMaxCartQuantity
                    ? Colors.grey
                    : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // MÃ GIẢM GIÁ
  // =========================
  Widget _buildCouponSection(double subtotal, String? couponError) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'MÃ GIẢM GIÁ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showCouponList(subtotal),
                child: const Text(
                  'Xem mã',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),

          if (_coupon != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_coupon!.code} - ${_coupon!.description}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  InkWell(
                    onTap: _removeCoupon,
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
            if (couponError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '$couponError. Mã sẽ không được áp dụng.',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
          ] else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _applyCoupon(subtotal),
                    decoration: InputDecoration(
                      hintText: 'Nhập mã giảm giá',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => _applyCoupon(subtotal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('ÁP DỤNG'),
                  ),
                ),
              ],
            ),

          if (_coupon == null && _couponMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _couponMessage!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // TỔNG TIỀN + NÚT THANH TOÁN
  // =========================
  Widget _buildSummary(List<CartItem> items, OrderPricing pricing) {
    final quantity = items.fold<int>(0, (s, i) => s + i.quantity);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow('Tạm tính ($quantity sản phẩm)',
                formatPrice(pricing.subtotal)),
            const SizedBox(height: 6),
            _summaryRow(
              'Phí vận chuyển',
              pricing.shippingFee == 0
                  ? 'Miễn phí'
                  : formatPrice(pricing.shippingFee),
            ),
            if (pricing.discount > 0) ...[
              const SizedBox(height: 6),
              _summaryRow(
                'Giảm giá (${pricing.appliedCoupon?.code})',
                '-${formatPrice(pricing.discount)}',
              ),
            ],
            const Divider(height: 20),
            _summaryRow(
              'TỔNG CỘNG',
              formatPrice(pricing.total),
              bold: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        items: items,
                        coupon: pricing.appliedCoupon,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'TIẾN HÀNH THANH TOÁN',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 17 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: Colors.black,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }

  // Màn hình thông báo (trống / chưa đăng nhập)
  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            if (buttonText != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(buttonText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
