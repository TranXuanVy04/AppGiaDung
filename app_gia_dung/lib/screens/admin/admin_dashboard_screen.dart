import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../provider/auth_provider.dart';
import '../../provider/admin_dashboard_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final moneyFormat = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<AdminDashboardProvider>().fetchDashboard(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final data = provider.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text('Không có dữ liệu'))
          : RefreshIndicator(
        onRefresh: () {
          final token = context.read<AuthProvider>().token!;
          return context
              .read<AdminDashboardProvider>()
              .fetchDashboard(token);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _statCard(
                  'Doanh thu',
                  '${moneyFormat.format(data['totalRevenue'])} đ',
                  Icons.payments_outlined,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _statCard(
                  'Đơn hàng',
                  '${data['totalOrders']}',
                  Icons.receipt_long_outlined,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard(
                  'Sản phẩm',
                  '${data['totalProducts']}',
                  Icons.inventory_2_outlined,
                  AppColors.primary,
                ),
                const SizedBox(width: 12),
                _statCard(
                  'Bán chạy',
                  '${(data['bestSellingProducts'] as List).length}',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Sản phẩm bán chạy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(data['bestSellingProducts'] as List).map((item) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(item['productName'] ?? ''),
                  subtitle: Text('Đã bán: ${item['soldQuantity']}'),
                  trailing: Text(
                    '${moneyFormat.format(item['revenue'])} đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: AppColors.textGray)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}