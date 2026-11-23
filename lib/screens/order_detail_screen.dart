import 'package:flutter/material.dart';

import '../Models/order.dart';
import '../services/order_service.dart';
import '../utils/format.dart';
import 'order_history_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  // true khi vừa đặt hàng xong => hiện thông báo thành công
  final bool justPlaced;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.justPlaced = false,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();

  late final Stream<AppOrder?> _orderStream;

  bool _isBusy = false;

  // Lý do hủy đơn để người dùng chọn
  static const List<String> _cancelReasons = [
    'Muốn thay đổi địa chỉ giao hàng',
    'Muốn đổi màu sắc / kích cỡ / sản phẩm',
    'Tìm được giá tốt hơn ở nơi khác',
    'Đặt nhầm sản phẩm',
    'Lý do khác',
  ];

  @override
  void initState() {
    super.initState();
    _orderStream = _orderService.watchOrder(widget.orderId);
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
  // HỦY ĐƠN HÀNG
  // =========================
  Future<void> _cancelOrder(AppOrder order) async {
    if (_isBusy) return;

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String selected = _cancelReasons.first;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'HỦY ĐƠN HÀNG',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vui lòng chọn lý do hủy đơn:'),
                    const SizedBox(height: 8),
                    ..._cancelReasons.map((reason) {
                      return InkWell(
                        onTap: () {
                          setDialogState(() => selected = reason);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                selected == reason
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(reason)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'KHÔNG HỦY',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, selected),
                  child: const Text(
                    'XÁC NHẬN HỦY',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (reason == null || !mounted) return;

    setState(() => _isBusy = true);

    try {
      await _orderService.cancelOrder(order.id, reason);

      if (!mounted) return;
      _showMessage('Đã hủy đơn hàng.');
    } on StateError catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Không thể hủy đơn hàng. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // =========================
  // (DEMO) CHUYỂN TRẠNG THÁI TIẾP THEO
  // =========================
  Future<void> _advance(AppOrder order) async {
    if (_isBusy) return;

    setState(() => _isBusy = true);

    try {
      await _orderService.advanceStatus(order.id);
    } on StateError catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Không thể cập nhật trạng thái.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'CHI TIẾT ĐƠN HÀNG',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<AppOrder?>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Không thể tải đơn hàng'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final order = snapshot.data;

          if (order == null) {
            return const Center(child: Text('Không tìm thấy đơn hàng'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (widget.justPlaced) _buildSuccessBanner(),
                    _buildHeader(order),
                    const SizedBox(height: 20),
                    _buildTracking(order),
                    const SizedBox(height: 20),
                    _buildItems(order),
                    const SizedBox(height: 20),
                    _buildShippingInfo(order),
                    const SizedBox(height: 20),
                    _buildPaymentInfo(order),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildActions(order),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Đặt hàng thành công! Cảm ơn bạn đã mua sắm tại KICKS.',
              style: TextStyle(color: Colors.white, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppOrder order) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${order.code}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Đặt lúc ${formatDateTime(order.createdAt)}',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
        StatusChip(status: order.status),
      ],
    );
  }

  // =========================
  // THEO DÕI TRẠNG THÁI
  // =========================
  Widget _buildTracking(AppOrder order) {
    if (order.status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cancel_outlined, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Đơn hàng đã được hủy',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (order.cancelledAt != null) ...[
              const SizedBox(height: 6),
              Text('Thời gian: ${formatDateTime(order.cancelledAt!)}'),
            ],
            if (order.cancelReason != null) ...[
              const SizedBox(height: 4),
              Text('Lý do: ${order.cancelReason}'),
            ],
          ],
        ),
      );
    }

    const steps = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.shipping,
      OrderStatus.delivered,
    ];

    final currentIndex = steps.indexOf(order.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRẠNG THÁI ĐƠN HÀNG',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          final reached = index <= currentIndex;
          final isLast = index == steps.length - 1;
          final time = order.timeOf(step);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: reached ? Colors.black : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: reached
                                ? Colors.black
                                : const Color(0xFFCCCCCC),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          step.icon,
                          size: 16,
                          color: reached ? Colors.white : Colors.grey,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: index < currentIndex
                                ? Colors.black
                                : const Color(0xFFDDDDDD),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: TextStyle(
                            fontWeight:
                                reached ? FontWeight.bold : FontWeight.normal,
                            color: reached ? Colors.black : Colors.grey,
                          ),
                        ),
                        if (time != null)
                          Text(
                            formatDateTime(time),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // =========================
  // SẢN PHẨM + GIÁ
  // =========================
  Widget _buildItems(AppOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SẢN PHẨM',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            children: [
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
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
                              maxLines: 2,
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
              _row('Tạm tính', formatPrice(order.subtotal)),
              const SizedBox(height: 6),
              _row(
                'Phí vận chuyển',
                order.shippingFee == 0
                    ? 'Miễn phí'
                    : formatPrice(order.shippingFee),
              ),
              if (order.discount > 0) ...[
                const SizedBox(height: 6),
                _row(
                  order.couponCode == null
                      ? 'Giảm giá'
                      : 'Giảm giá (${order.couponCode})',
                  '-${formatPrice(order.discount)}',
                ),
              ],
              const Divider(height: 20),
              _row('TỔNG CỘNG', formatPrice(order.total), bold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingInfo(AppOrder order) {
    return _infoCard(
      title: 'THÔNG TIN GIAO HÀNG',
      lines: [
        '${order.recipientName}  |  ${order.phoneNumber}',
        order.fullAddress,
        if (order.note.isNotEmpty) 'Ghi chú: ${order.note}',
      ],
    );
  }

  Widget _buildPaymentInfo(AppOrder order) {
    return _infoCard(
      title: 'THANH TOÁN',
      lines: [
        order.paymentMethod.label,
        'Trạng thái: ${PaymentStatus.label(order.paymentStatus)}',
      ],
    );
  }

  Widget _infoCard({required String title, required List<String> lines}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(line, style: const TextStyle(height: 1.4)),
                  ),
                )
                .toList(),
          ),
        ),
      ],
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

  // =========================
  // NÚT HÀNH ĐỘNG (HỦY ĐƠN / DEMO)
  // =========================
  Widget _buildActions(AppOrder order) {
    final next = order.status.next;
    final blockedReason = order.cancelBlockedReason;
    final showCancelInfo =
        order.status != OrderStatus.cancelled && blockedReason != null;

    final showDemo = kEnableDemoOrderControls && next != null;

    if (order.status == OrderStatus.cancelled && !showDemo) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (order.canCancel)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isBusy ? null : () => _cancelOrder(order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'HỦY ĐƠN HÀNG',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (showCancelInfo)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  blockedReason!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            if (showDemo) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: _isBusy ? null : () => _advance(order),
                  child: Text(
                    '[MÔ PHỎNG] Chuyển sang: ${next!.label}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
