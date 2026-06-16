import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final oldPriceController = TextEditingController();
  final stockController = TextEditingController();
  final brandController = TextEditingController();
  final imageUrlController = TextEditingController();
  final categoryIdController = TextEditingController();

  bool isSubmitting = false;

  Future<void> handleAddProduct() async {
    final auth = context.read<AuthProvider>();

    if (auth.token == null || auth.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa đăng nhập')),
      );
      return;
    }

    try {
      setState(() => isSubmitting = true);

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/Products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token!}',
        },
        body: jsonEncode({
          'name': nameController.text.trim(),
          'description': descriptionController.text.trim(),
          'price': double.tryParse(priceController.text.trim()) ?? 0,
          'oldPrice': oldPriceController.text.trim().isEmpty
              ? null
              : double.tryParse(oldPriceController.text.trim()),
          'stock': int.tryParse(stockController.text.trim()) ?? 0,
          'brand': brandController.text.trim(),
          'imageUrl': imageUrlController.text.trim(),
          'categoryId': int.tryParse(categoryIdController.text.trim()) ?? 1,
          'isFeatured': true,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm sản phẩm thành công')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Không thể thêm sản phẩm');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    oldPriceController.dispose();
    stockController.dispose();
    brandController.dispose();
    imageUrlController.dispose();
    categoryIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.currentUser?.role == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm sản phẩm'),
      ),
      body: !isAdmin
          ? const Center(
        child: Text('Chỉ admin mới được thêm sản phẩm'),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Tên sản phẩm',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mô tả',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Giá',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: oldPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Giá cũ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: stockController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tồn kho',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: brandController,
            decoration: const InputDecoration(
              labelText: 'Thương hiệu',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: imageUrlController,
            decoration: const InputDecoration(
              labelText: 'Image URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: categoryIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Category ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isSubmitting ? null : handleAddProduct,
            child: isSubmitting
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Thêm sản phẩm'),
          ),
        ],
      ),
    );
  }
}