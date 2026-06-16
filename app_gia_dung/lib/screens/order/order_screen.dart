import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import file màu của bạn
import '../../core/app_colors.dart';
import 'package:intl/intl.dart';

import '../../models/order_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/order_provider.dart';
import '../review/review_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      if (auth.token != null && auth.token!.isNotEmpty) {
        context.read<OrderProvider>().fetchMyOrders(auth.token!);
      }
    });
  }

  // Lấy màu trạng thái dựa trên AppColors
  Color getStatusColor(String status) {
    switch (status.trim()) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đã xác nhận':
        return AppColors.primary;
      case 'Đang giao':
        return Colors.purple;
      case 'Hoàn thành':
        return Colors.green;
      case 'Đã hủy':
        return AppColors.danger;
      default:
        return AppColors.textGray;
    }
  }

  int getTrackingStep(String status) {
    switch (status.trim()) {
      case 'Chờ xác nhận':
        return 0;
      case 'Đã xác nhận':
        return 1;
      case 'Đang giao':
        return 2;
      case 'Hoàn thành':
        return 3;
      default:
        return -1;
    }
  }

  // --- UI Components ---

  Widget buildTrackingBar(String status) {
    if (status.trim() == 'Đã hủy') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.danger),
            SizedBox(width: 8),
            Text(
              'Đơn hàng này đã bị hủy',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final step = getTrackingStep(status);
    final List<Map<String, dynamic>> steps = [
      {'title': 'Chờ duyệt', 'icon': Icons.assignment_late_outlined},
      {'title': 'Đã nhận', 'icon': Icons.inventory_2_outlined},
      {'title': 'Đang giao', 'icon': Icons.local_shipping_outlined},
      {'title': 'Thành công', 'icon': Icons.task_alt},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final isDone = index <= step;
        final isProcessing = index == step;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: index == 0
                          ? Colors.transparent
                          : (isDone ? AppColors.primary : Colors.grey.shade300),
                      thickness: 2,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isProcessing
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      steps[index]['icon'],
                      size: 16,
                      color: isDone ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: index == steps.length - 1
                          ? Colors.transparent
                          : (index < step
                                ? AppColors.primary
                                : Colors.grey.shade300),
                      thickness: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                steps[index]['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                  color: isDone ? AppColors.textDark : AppColors.textGray,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Đơn hàng
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mã đơn: #${order.id.toString().toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(order.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: getStatusColor(order.status),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Ngày đặt: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1),
                ),
                buildTrackingBar(order.status),
              ],
            ),
          ),

          // Chi tiết sản phẩm & Thông tin (nền màu nhạt)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 6,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item.productName} x${item.quantity}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Text(
                          '${item.totalPrice.toStringAsFixed(0)}đ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${order.totalAmount.toStringAsFixed(0)} đ',
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                if (order.status == 'Chờ xác nhận') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final auth = context.read<AuthProvider>();

                        await context.read<OrderProvider>().cancelOrder(
                          auth.token!,
                          order.id,
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã hủy đơn hàng')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                      child: const Text('Hủy đơn'),
                    ),
                  ),
                ],
                if (order.status == 'Thành công') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewScreen(order: order),
                          ),
                        );
                      },
                      child: const Text('Đánh giá sản phẩm'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Đơn hàng của tôi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),
      body: auth.token == null || auth.token!.isEmpty
          ? _buildEmptyState(Icons.lock_outline, 'Bạn chưa đăng nhập')
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<OrderProvider>().fetchMyOrders(auth.token!),
              child: orderProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : orderProvider.orders.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Chưa có đơn hàng nào',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Bạn chưa đặt đơn hàng nào. Hãy mua sắm để tạo đơn hàng đầu tiên nhé!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textGray,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: const Text('Mua sắm ngay'),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orderProvider.orders.length,
                      itemBuilder: (context, index) =>
                          buildOrderCard(orderProvider.orders[index]),
                    ),
            ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textGray.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.textGray, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
