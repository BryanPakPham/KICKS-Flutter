import 'package:flutter/material.dart';

import '../Models/address.dart';
import '../Models/cart_item.dart';
import '../Models/coupon.dart';
import '../Models/order.dart';
import '../services/address_service.dart';
import '../services/order_service.dart';
import '../utils/format.dart';
import '../utils/pricing.dart';
import 'address_form_screen.dart';
import 'order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  final Coupon? coupon;

  const CheckoutScreen({
    super.key,
    required this.items,
    this.coupon,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final AddressService _addressService = AddressService();
  final OrderService _orderService = OrderService();
  final TextEditingController _noteController = TextEditingController();

  late final Stream<List<ShippingAddress>> _addressStream;

  String? _selectedAddressId;
  PaymentMethod _paymentMethod = PaymentMethod.cod;
  bool _isPlacing = false;

  @override
  void initState() {
    super.initState();
    _addressStream = _addressService.watchAddresses();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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

  // Địa chỉ đang chọn (mặc định: địa chỉ default, được xếp đầu danh sách)
  ShippingAddress? _resolveAddress(List<ShippingAddress> addresses) {
    if (addresses.isEmpty) return null;

    for (final address in addresses) {
      if (address.id == _selectedAddressId) return address;
    }

    return addresses.first;
  }

  Future<void> _addAddress() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddressFormScreen()),
    );

    if (!mounted) return;

    if (result == true) {
      _showMessage('Thêm địa chỉ thành công!');
    }
  }

  // =========================
  // XÁC NHẬN VÀ ĐẶT HÀNG
  // =========================
  Future<void> _placeOrder(
    ShippingAddress? address,
    OrderPricing pricing,
  ) async {
    if (_isPlacing) return;

    if (address == null) {
      _showMessage('Vui lòng thêm địa chỉ giao hàng');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'XÁC NHẬN ĐẶT HÀNG',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Người nhận: ${address.fullName}'),
            const SizedBox(height: 6),
            Text('Thanh toán: ${_paymentMethod.label}'),
            const SizedBox(height: 6),
            Text(
              'Tổng cộng: ${formatPrice(pricing.total)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'KIỂM TRA LẠI',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'ĐẶT HÀNG',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isPlacing = true);

    try {
      final orderId = await _orderService.placeOrder(
        items: widget.items,
        address: address,
        paymentMethod: _paymentMethod,
        coupon: widget.coupon,
        note: _noteController.text,
      );

      if (!mounted) return;

      // Thay màn hình checkout bằng màn hình chi tiết đơn vừa tạo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(
            orderId: orderId,
            justPlaced: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacing = false);
      _showMessage('Đặt hàng thất bại. Vui lòng thử lại.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pricing = OrderPricing.calculate(
      widget.items,
      coupon: widget.coupon,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'THANH TOÁN',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<ShippingAddress>>(
        stream: _addressStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Không thể tải địa chỉ giao hàng'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final addresses = snapshot.data!;
          final address = _resolveAddress(addresses);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionTitle('1. ĐỊA CHỈ GIAO HÀNG'),
                    _buildAddressSection(addresses, address),
                    const SizedBox(height: 24),
                    _sectionTitle('2. PHƯƠNG THỨC THANH TOÁN'),
                    _buildPaymentSection(),
                    const SizedBox(height: 24),
                    _sectionTitle('3. GHI CHÚ'),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: 'Ghi chú cho người giao hàng (không bắt buộc)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _sectionTitle('4. ĐƠN HÀNG'),
                    _buildOrderSummary(pricing),
                  ],
                ),
              ),
              _buildBottomBar(address, pricing),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // =========================
  // ĐỊA CHỈ
  // =========================
  Widget _buildAddressSection(
    List<ShippingAddress> addresses,
    ShippingAddress? selected,
  ) {
    if (addresses.isEmpty) {
      return OutlinedButton.icon(
        onPressed: _addAddress,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: Colors.black, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('THÊM ĐỊA CHỈ GIAO HÀNG'),
      );
    }

    return Column(
      children: [
        ...addresses.map((address) {
          final isSelected = address.id == selected?.id;

          return GestureDetector(
            onTap: () => setState(() => _selectedAddressId = address.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFFEAEAEA),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${address.fullName}  |  ${address.phoneNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            address.streetAddress,
                            address.ward,
                            address.province,
                          ].where((p) => p.trim().isNotEmpty).join(', '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        if (address.isDefault)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              'Mặc định',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addAddress,
            icon: const Icon(Icons.add, color: Colors.black, size: 18),
            label: const Text(
              'Thêm địa chỉ mới',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // PHƯƠNG THỨC THANH TOÁN
  // =========================
  Widget _buildPaymentSection() {
    return Column(
      children: [
        ...PaymentMethod.values.map((method) {
          final isSelected = method == _paymentMethod;

          return GestureDetector(
            onTap: () => setState(() => _paymentMethod = method),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFFEAEAEA),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(method.icon, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          method.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }),
        if (_paymentMethod != PaymentMethod.cod)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              'Lưu ý: đây là bản mô phỏng, ứng dụng chưa kết nối cổng '
              'thanh toán thật nên sẽ không trừ tiền.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
      ],
    );
  }

  // =========================
  // TÓM TẮT ĐƠN HÀNG
  // =========================
  Widget _buildOrderSummary(OrderPricing pricing) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        children: [
          ...widget.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFFF7F7F7),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${item.colorName} • Cỡ ${item.size} • x${item.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(formatPrice(item.lineTotal)),
                ],
              ),
            );
          }),
          const Divider(height: 20),
          _row('Tạm tính', formatPrice(pricing.subtotal)),
          const SizedBox(height: 6),
          _row(
            'Phí vận chuyển',
            pricing.shippingFee == 0
                ? 'Miễn phí'
                : formatPrice(pricing.shippingFee),
          ),
          if (pricing.discount > 0) ...[
            const SizedBox(height: 6),
            _row(
              'Giảm giá (${pricing.appliedCoupon?.code})',
              '-${formatPrice(pricing.discount)}',
            ),
          ],
          const Divider(height: 20),
          _row('TỔNG CỘNG', formatPrice(pricing.total), bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 17 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }

  Widget _buildBottomBar(ShippingAddress? address, OrderPricing pricing) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tổng cộng',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    formatPrice(pricing.total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _isPlacing ? null : () => _placeOrder(address, pricing),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPlacing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'XÁC NHẬN ĐẶT HÀNG',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
