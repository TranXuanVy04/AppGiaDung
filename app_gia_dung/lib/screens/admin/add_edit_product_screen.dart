import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/admin_product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final oldPriceController = TextEditingController();
  final stockController = TextEditingController();
  final brandController = TextEditingController();
  final imageUrlController = TextEditingController();
  final categoryIdController = TextEditingController();

  bool isSaving = false;
  bool isFeatured = false;

  @override
  void initState() {
    super.initState();

    final p = widget.product;
    if (p != null) {
      nameController.text = p.name;
      descriptionController.text = p.description ?? '';
      priceController.text = p.price.toString();
      oldPriceController.text = p.oldPrice?.toString() ?? '';
      stockController.text = p.stock.toString();
      brandController.text = p.brand ?? '';
      imageUrlController.text = p.imageUrl ?? '';
      categoryIdController.text = p.categoryId.toString();
    } else {
      categoryIdController.text = '1';
    }
  }

  Future<void> saveProduct() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final data = {
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "price": double.tryParse(priceController.text) ?? 0,
      "oldPrice": oldPriceController.text.trim().isEmpty
          ? null
          : double.tryParse(oldPriceController.text),
      "stock": int.tryParse(stockController.text) ?? 0,
      "brand": brandController.text.trim(),
      "imageUrl": imageUrlController.text.trim(),
      "categoryId": int.tryParse(categoryIdController.text) ?? 1,
      "isFeatured": isFeatured,
    };

    setState(() => isSaving = true);

    try {
      final provider = context.read<AdminProductProvider>();

      if (widget.product == null) {
        await provider.createProduct(token, data);
      } else {
        await provider.updateProduct(token, widget.product!.id, data);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _input(nameController, 'Tên sản phẩm'),
          _input(descriptionController, 'Mô tả'),
          _input(priceController, 'Giá', number: true),
          _input(oldPriceController, 'Giá cũ', number: true),
          _input(stockController, 'Số lượng', number: true),
          _input(brandController, 'Thương hiệu'),
          _input(imageUrlController, 'Link ảnh'),
          _input(categoryIdController, 'Category ID', number: true),
          SwitchListTile(
            title: const Text('Sản phẩm nổi bật'),
            value: isFeatured,
            onChanged: (v) => setState(() => isFeatured = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isSaving ? null : saveProduct,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEdit ? 'Cập nhật sản phẩm' : 'Thêm sản phẩm'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
      TextEditingController controller,
      String label, {
        bool number = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}