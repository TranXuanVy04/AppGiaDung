import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../models/product_model.dart';
import '../../models/voucher_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/order_provider.dart';
import '../../services/voucher_service.dart';
import '../payment/payment_qr_screen.dart';

class BuyNowCheckoutScreen extends StatefulWidget {
  final ProductModel product;
  final int quantity;

  const BuyNowCheckoutScreen({
    super.key,
    required this.product,
    required this.quantity,
  });

  @override
  State<BuyNowCheckoutScreen> createState() => _BuyNowCheckoutScreenState();
}

class _BuyNowCheckoutScreenState extends State<BuyNowCheckoutScreen> {
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();
  final shippingAddressController = TextEditingController();
  final voucherController = TextEditingController();

  final VoucherService _voucherService = VoucherService();

  String paymentMethod = 'COD';
  double shippingFee = 30000;
  bool isSubmitting = false;
  bool isApplyingVoucher = false;

  VoucherModel? appliedVoucher;
  double discountAmount = 0;

  double get subTotal => widget.product.price * widget.quantity;

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> handleApplyVoucher() async {
    if (voucherController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập mã voucher');
      return;
    }

    try {
      setState(() => isApplyingVoucher = true);

      final voucher = await _voucherService.applyVoucher(
        code: voucherController.text.trim(),
        orderAmount: subTotal,
      );

      setState(() {
        appliedVoucher = voucher;
        discountAmount = voucher.discountAmount ?? 0;
      });

      _showSnackBar('Áp dụng ${voucher.code} thành công');
    } catch (e) {
      setState(() {
        appliedVoucher = null;
        discountAmount = 0;
      });
      _showSnackBar('$e');
    } finally {
      if (mounted) setState(() => isApplyingVoucher = false);
    }
  }

  Future<void> handleOrder() async {
    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    final total = subTotal + shippingFee - discountAmount;
    final double finalTotal = total < 0 ? 0 : total;

    if (auth.token == null || auth.token!.isEmpty) {
      _showSnackBar('Bạn chưa đăng nhập');
      return;
    }

    if (receiverNameController.text.trim().isEmpty ||
        receiverPhoneController.text.trim().isEmpty ||
        shippingAddressController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin nhận hàng');
      return;
    }

    try {
      setState(() => isSubmitting = true);

      if (paymentMethod != 'COD') {
        final paid = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentQrScreen(
              orderCode: 'DH${DateTime.now().millisecondsSinceEpoch}',
              amount: finalTotal,
              bankName: paymentMethod,
            ),
          ),
        );

        if (paid != true) {
          setState(() => isSubmitting = false);
          return;
        }
      }

      await orderProvider.createBuyNowOrder(
        token: auth.token!,
        productId: widget.product.id,
        quantity: widget.quantity,
        receiverName: receiverNameController.text.trim(),
        receiverPhone: receiverPhoneController.text.trim(),
        shippingAddress: shippingAddressController.text.trim(),
        paymentMethod: paymentMethod,
        shippingFee: shippingFee,
        voucherCode: appliedVoucher?.code,
      );

      _showSnackBar('Đặt hàng thành công');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Đặt hàng thất bại: $e');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moneyFormat = NumberFormat('#,###', 'vi_VN');
    final total = subTotal + shippingFee - discountAmount;
    final double finalTotal = total < 0 ? 0 : total;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mua ngay'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header('Sản phẩm'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: widget.product.imageUrl != null
                      ? Image.network(
                    widget.product.imageUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 70,
                    height: 70,
                    color: AppColors.secondary,
                    child: const Icon(Icons.image),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Số lượng: ${widget.quantity}',
                        style: const TextStyle(color: AppColors.textGray),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${moneyFormat.format(subTotal)} đ',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _header('Thông tin giao hàng'),
          const SizedBox(height: 12),
          _input(receiverNameController, 'Tên người nhận', Icons.person),
          const SizedBox(height: 12),
          _input(receiverPhoneController, 'Số điện thoại', Icons.phone),
          const SizedBox(height: 12),
          _input(
            shippingAddressController,
            'Địa chỉ giao hàng',
            Icons.location_on,
            maxLines: 2,
          ),

          const SizedBox(height: 24),
          _header('Phương thức thanh toán'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: paymentMethod,
            decoration: _decor('Chọn phương thức thanh toán', Icons.payments),
            items: const [
              DropdownMenuItem(value: 'COD', child: Text('Thanh toán khi nhận hàng')),
              DropdownMenuItem(value: 'VCB', child: Text('Chuyển khoản Vietcombank')),
              DropdownMenuItem(value: 'MBBANK', child: Text('Chuyển khoản MB Bank')),
              DropdownMenuItem(value: 'MOMO', child: Text('Ví MoMo')),
              DropdownMenuItem(value: 'VNPAY', child: Text('VNPay')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => paymentMethod = v);
            },
          ),

          const SizedBox(height: 24),
          _header('Khuyến mãi'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: voucherController,
                  decoration: _decor('Nhập mã voucher', Icons.discount),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: isApplyingVoucher ? null : handleApplyVoucher,
                  child: isApplyingVoucher
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Áp dụng'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _priceRow('Tạm tính', subTotal, moneyFormat),
                _priceRow('Phí giao hàng', shippingFee, moneyFormat),
                _priceRow('Giảm giá', -discountAmount, moneyFormat, isDiscount: true),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${moneyFormat.format(finalTotal)} đ',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : handleOrder,
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('XÁC NHẬN ĐẶT HÀNG'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _input(TextEditingController c, String label, IconData icon, {int maxLines = 1}) {
    return TextField(controller: c, maxLines: maxLines, decoration: _decor(label, icon));
  }

  InputDecoration _decor(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: const Color(0xFFEAF8FF),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _priceRow(String label, double amount, NumberFormat f, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${f.format(amount)} đ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}