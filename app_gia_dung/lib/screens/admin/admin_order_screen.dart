import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../provider/admin_order_provider.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final moneyFormat = NumberFormat('#,###', 'vi_VN');

  final statuses = [
    'Chờ xác nhận',
    'Đã nhận',
    'Đang giao',
    'Thành công',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<AdminOrderProvider>().fetchOrders(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminOrderProvider>();
    final token = context.read<AuthProvider>().token!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: provider.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = provider.orders[index];
          final items = order['items'] as List;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mã đơn: #${order['id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Khách hàng: ${order['fullName'] ?? ''}'),
                  Text('SĐT: ${order['phone'] ?? ''}'),
                  Text('Địa chỉ: ${order['address'] ?? ''}'),
                  const Divider(),

                  ...items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item['productName']} x${item['quantity']}',
                            ),
                          ),
                          Text(
                            '${moneyFormat.format(item['unitPrice'])} đ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        'Tổng: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${moneyFormat.format(order['totalAmount'])} đ',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: statuses.contains(order['status'])
                        ? order['status']
                        : 'Chờ xác nhận',
                    decoration: const InputDecoration(
                      labelText: 'Trạng thái đơn hàng',
                      border: OutlineInputBorder(),
                    ),
                    items: statuses.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == null) return;

                      await provider.updateStatus(
                        token,
                        order['id'],
                        value,
                      );
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}