import 'package:flutter/material.dart';

import '../Models/order.dart';
import '../services/order_service.dart';
import '../utils/format.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late final Stream<List<AppOrder>> _ordersStream;

  // Các tab lọc theo trạng thái
  static const List<_OrderTab> _tabs = [
    _OrderTab('Tất cả', null),
    _OrderTab('Đang xử lý', [OrderStatus.pending, OrderStatus.confirmed]),
    _OrderTab('Đang giao', [OrderStatus.shipping]),
    _OrderTab('Đã giao', [OrderStatus.delivered]),
    _OrderTab('Đã hủy', [OrderStatus.cancelled]),
  ];

  @override
  void initState() {
    super.initState();
    _ordersStream = OrderService().watchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'ĐƠN HÀNG CỦA TÔI',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: _tabs.map((tab) => Tab(text: tab.label)).toList(),
          ),
        ),
        body: StreamBuilder<List<AppOrder>>(
          stream: _ordersStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Không thể tải lịch sử đơn hàng'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            final orders = snapshot.data!;

            return TabBarView(
              children: _tabs.map((tab) {
                final filtered = tab.statuses == null
                    ? orders
                    : orders
                        .where((o) => tab.statuses!.contains(o.status))
                        .toList();

                return _buildList(filtered);
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<AppOrder> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Chưa có đơn hàng nào',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildOrderCard(AppOrder order) {
    final first = order.items.isNotEmpty ? order.items.first : null;
    final moreCount = order.items.length - 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: order.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order.code}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatDateTime(order.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const Divider(height: 20),
            if (first != null)
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    color: Colors.white,
                    child: Image.asset(
                      first.image,
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
                        Text(
                          first.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${first.colorName} • Cỡ ${first.size} • x${first.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        if (moreCount > 0)
                          Text(
                            'và $moreCount sản phẩm khác',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.totalQuantity} sản phẩm',
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  'Tổng: ${formatPrice(order.total)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTab {
  final String label;
  final List<OrderStatus>? statuses;

  const _OrderTab(this.label, this.statuses);
}

// Nhãn trạng thái đơn hàng (dùng chung cho danh sách và chi tiết)
class StatusChip extends StatelessWidget {
  final OrderStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isCancelled = status == OrderStatus.cancelled;
    final isDone = status == OrderStatus.delivered;

    final Color background = isCancelled
        ? const Color(0xFFFDECEC)
        : isDone
            ? Colors.black
            : Colors.white;

    final Color foreground = isCancelled
        ? Colors.red
        : isDone
            ? Colors.white
            : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCancelled ? Colors.red : Colors.black,
        ),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
