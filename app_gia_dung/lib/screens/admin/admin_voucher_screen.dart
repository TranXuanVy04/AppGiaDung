import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../services/voucher_service.dart';
import 'package:intl/intl.dart';

class AdminVoucherScreen extends StatefulWidget {
  const AdminVoucherScreen({super.key});

  @override
  State<AdminVoucherScreen> createState() => _AdminVoucherScreenState();
}

class _AdminVoucherScreenState extends State<AdminVoucherScreen> {
  final VoucherService voucherService = VoucherService();

  final codeController = TextEditingController();
  final discountController = TextEditingController();
  final minOrderController = TextEditingController();
  final money = NumberFormat('#,###', 'vi_VN');

  List<dynamic> vouchers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(loadVouchers);
  }

  Future<void> loadVouchers() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => isLoading = true);

    try {
      vouchers = await voucherService.getAdminVouchers(token);
      print(vouchers);
    } catch (e) {
      showSnack('Lỗi: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> addVoucher() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    if (codeController.text.trim().isEmpty ||
        discountController.text.trim().isEmpty ||
        minOrderController.text.trim().isEmpty) {
      showSnack('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    try {
      await voucherService.createVoucher(
        token: token,
        code: codeController.text.trim(),
        discountAmount: double.parse(discountController.text),
        minOrderAmount: double.parse(minOrderController.text),
      );

      codeController.clear();
      discountController.clear();
      minOrderController.clear();

      showSnack('Thêm voucher thành công');
      await loadVouchers();
    } catch (e) {
      showSnack('Lỗi: $e');
    }
  }

  Future<void> deleteVoucher(int id) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    try {
      await voucherService.deleteVoucher(token, id);
      showSnack('Đã xoá voucher');
      await loadVouchers();
    } catch (e) {
      showSnack('Lỗi: $e');
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    discountController.dispose();
    minOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý voucher'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: 'Mã voucher',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: discountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số tiền giảm',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: minOrderController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Đơn tối thiểu',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: addVoucher,
            child: const Text('THÊM VOUCHER'),
          ),
          const SizedBox(height: 24),

          ...vouchers.map((v) {
            final discount = v['discountValue'] ?? 0;
            final minOrder = v['minOrderValue'] ?? 0;
            return Card(
              child: ListTile(
                title: Text(
                  v['code'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Giảm: ${money.format(discount)} đ\n'
                      'Đơn tối thiểu: ${money.format(minOrder)} đ',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteVoucher(v['id']),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}