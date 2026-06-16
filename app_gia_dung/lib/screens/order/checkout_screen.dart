import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/voucher_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/cart_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/payment_provider.dart';
import '../../services/voucher_service.dart';
import '../payment/payment_qr_screen.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  final List<int> selectedItemIds;

  const CheckoutScreen({
    super.key,
    required this.selectedItemIds,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {

  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();
  final shippingAddressController = TextEditingController();
  final voucherController = TextEditingController();

  final VoucherService _voucherService =
  VoucherService();

  String paymentMethod = 'COD';

  double shippingFee = 30000;

  bool isSubmitting = false;
  bool isApplyingVoucher = false;

  VoucherModel? appliedVoucher;

  double discountAmount = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {

      final paymentProvider =
      context.read<PaymentProvider>();

      await paymentProvider.fetchMethods();

      if (paymentProvider.selectedMethod != null) {

        setState(() {
          paymentMethod =
              paymentProvider.selectedMethod!.code;
        });
      }
    });
  }

  @override
  void dispose() {

    receiverNameController.dispose();
    receiverPhoneController.dispose();
    shippingAddressController.dispose();
    voucherController.dispose();

    super.dispose();
  }

  Future<void> handleApplyVoucher() async {

    final cartProvider = context.read<CartProvider>();

    final selectedItems = cartProvider.items
        .where((e) => widget.selectedItemIds.contains(e.id))
        .toList();

    final subTotal = selectedItems.fold<double>(
      0,
          (sum, item) => sum + item.unitPrice * item.quantity,
    );

    if (voucherController.text.trim().isEmpty) {

      _showSnackBar('Vui lòng nhập mã voucher');
      return;
    }

    try {

      setState(() {
        isApplyingVoucher = true;
      });

      final voucher =
      await _voucherService.applyVoucher(
        code: voucherController.text.trim(),
        orderAmount: subTotal,
      );

      setState(() {

        appliedVoucher = voucher;

        discountAmount =
            voucher.discountAmount ?? 0;
      });

      _showSnackBar(
        'Áp dụng ${voucher.code} thành công',
      );

    } catch (e) {

      setState(() {

        appliedVoucher = null;
        discountAmount = 0;
      });

      _showSnackBar('$e');

    } finally {

      if (mounted) {

        setState(() {
          isApplyingVoucher = false;
        });
      }
    }
  }

  Future<void> handleOrder() async {

    final cartProvider = context.read<CartProvider>();

    final selectedItems = cartProvider.items
        .where((e) => widget.selectedItemIds.contains(e.id))
        .toList();

    final subTotal = selectedItems.fold<double>(
      0,
          (sum, item) => sum + item.unitPrice * item.quantity,
    );

    final total = subTotal + shippingFee - discountAmount;
    final double finalTotal = total < 0 ? 0.0 : total;

    final auth =
    context.read<AuthProvider>();



    final orderProvider =
    context.read<OrderProvider>();



    if (auth.token == null ||
        auth.token!.isEmpty) {

      _showSnackBar('Bạn chưa đăng nhập');
      return;
    }

    if (receiverNameController.text.trim().isEmpty ||
        receiverPhoneController.text.trim().isEmpty ||
        shippingAddressController.text.trim().isEmpty) {

      _showSnackBar(
        'Vui lòng nhập đầy đủ thông tin nhận hàng',
      );

      return;
    }

    try {

      setState(() {
        isSubmitting = true;
      });



      if (
      paymentMethod == 'MOMO' ||
          paymentMethod == 'VNPAY' ||
          paymentMethod == 'VCB' ||
          paymentMethod == 'MBBANK'
      ) {
        print('selectedItemIds: ${widget.selectedItemIds}');
        print('subTotal: $subTotal');
        print('finalTotal: $finalTotal');

        final paid = await Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => PaymentQrScreen(

              orderCode:
              'DH${DateTime.now().millisecondsSinceEpoch}',

              amount: finalTotal,

              bankName: paymentMethod,
            ),
          ),
        );

        // User đã bấm xác nhận thanh toán
        if (paid == true) {

          await orderProvider.createOrder(

            token: auth.token!,

            receiverName:
            receiverNameController.text.trim(),

            receiverPhone:
            receiverPhoneController.text.trim(),

            shippingAddress:
            shippingAddressController.text.trim(),

            paymentMethod: paymentMethod,

            shippingFee: shippingFee,

            voucherCode: appliedVoucher?.code,
            selectedItemIds: widget.selectedItemIds,
          );

          await cartProvider.fetchCart(auth.token!);

          _showSnackBar('Thanh toán thành công');

          Navigator.pop(context);
        }

      } else {

        await orderProvider.createOrder(

          token: auth.token!,

          receiverName:
          receiverNameController.text.trim(),

          receiverPhone:
          receiverPhoneController.text.trim(),

          shippingAddress:
          shippingAddressController.text.trim(),

          paymentMethod: paymentMethod,

          shippingFee: shippingFee,

          voucherCode: appliedVoucher?.code,
          selectedItemIds: widget.selectedItemIds,
        );

        await cartProvider.fetchCart(auth.token!);

        _showSnackBar('Đặt hàng thành công');

        Navigator.pop(context);
      }

    } catch (e) {

      _showSnackBar(
        'Đặt hàng thất bại: $e',
      );

    } finally {

      if (mounted) {

        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _inputStyle(
      String label,
      IconData icon,
      ) {

    return InputDecoration(

      labelText: label,

      prefixIcon: Icon(
        icon,
        color: AppColors.primary,
      ),

      filled: true,

      fillColor: AppColors.secondary,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final moneyFormat = NumberFormat('#,###', 'vi_VN');

    final selectedItems = cartProvider.items
        .where((e) => widget.selectedItemIds.contains(e.id))
        .toList();

    final subTotal = selectedItems.fold<double>(
      0,
          (sum, item) => sum + item.unitPrice * item.quantity,
    );

    final total = subTotal + shippingFee - discountAmount;
    final double finalTotal = total < 0 ? 0.0 : total;



    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        title: const Text('Thanh toán'),

        backgroundColor: Colors.white,
      ),

      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          _buildHeader(
            'Thông tin giao hàng',
          ),

          const SizedBox(height: 12),

          TextField(
            controller: receiverNameController,
            decoration: _inputStyle(
              'Tên người nhận',
              Icons.person,
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: receiverPhoneController,

            keyboardType:
            TextInputType.phone,

            decoration: _inputStyle(
              'Số điện thoại',
              Icons.phone,
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller:
            shippingAddressController,

            maxLines: 2,

            decoration: _inputStyle(
              'Địa chỉ giao hàng',
              Icons.location_on,
            ),
          ),

          const SizedBox(height: 24),

          _buildHeader(
            'Phương thức thanh toán',
          ),

          const SizedBox(height: 14),

          Consumer<PaymentProvider>(
            builder: (
                context,
                paymentProvider,
                _,
                ) {

              if (paymentProvider.isLoading) {

                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              }

              if (paymentProvider.methods.isEmpty) {

                return const Text(
                  'Không có phương thức thanh toán',
                );
              }

              return Column(

                children:
                paymentProvider.methods
                    .map((method) {

                  final isSelected =
                      paymentProvider
                          .selectedMethod
                          ?.id ==
                          method.id;

                  return GestureDetector(

                    onTap: () {

                      paymentProvider
                          .selectMethod(method);

                      setState(() {
                        paymentMethod =
                            method.code;
                      });
                    },

                    child: AnimatedContainer(

                      duration:
                      const Duration(
                          milliseconds: 250),

                      margin:
                      const EdgeInsets.only(
                          bottom: 12),

                      padding:
                      const EdgeInsets.all(14),

                      decoration: BoxDecoration(

                        color: isSelected
                            ? AppColors.primary
                            .withOpacity(0.08)
                            : Colors.white,

                        borderRadius:
                        BorderRadius.circular(
                            16),

                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),

                      child: Row(
                        children: [

                          _buildPaymentIcon(
                              method.code),

                          const SizedBox(
                              width: 14),

                          Expanded(
                            child: Column(

                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                              children: [

                                Text(
                                  method.name,

                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),

                                const SizedBox(
                                    height: 4),

                                Text(
                                  _getPaymentDescription(
                                      method.code),

                                  style:
                                  const TextStyle(
                                    color: AppColors
                                        .textGray,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Radio<int>(

                            value: method.id,

                            groupValue:
                            paymentProvider
                                .selectedMethod
                                ?.id,

                            activeColor:
                            AppColors.primary,

                            onChanged: (_) {

                              paymentProvider
                                  .selectMethod(
                                  method);

                              setState(() {

                                paymentMethod =
                                    method.code;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          _buildHeader('Khuyến mãi'),

          const SizedBox(height: 12),

          Row(
            children: [

              Expanded(
                child: TextField(

                  controller:
                  voucherController,

                  decoration: _inputStyle(
                    'Nhập mã voucher',
                    Icons.discount,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              SizedBox(

                height: 54,

                child: ElevatedButton(

                  onPressed:
                  isApplyingVoucher
                      ? null
                      : handleApplyVoucher,

                  child: isApplyingVoucher
                      ? const SizedBox(
                    width: 20,
                    height: 20,

                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Áp dụng',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Container(

            padding:
            const EdgeInsets.all(16),

            decoration: BoxDecoration(

              color: AppColors.secondary,

              borderRadius:
              BorderRadius.circular(16),
            ),

            child: Column(
              children: [

                _buildPriceRow(
                  'Tạm tính',
                  subTotal,
                ),

                _buildPriceRow(
                  'Phí giao hàng',
                  shippingFee,
                ),

                _buildPriceRow(
                  'Giảm giá',
                  -discountAmount,
                  isDiscount: true,
                ),

                const Divider(height: 30),

                Row(

                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [

                    const Text(
                      'Tổng cộng',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    Text(
                      '${moneyFormat.format(finalTotal)} đ',

                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
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

            width: double.infinity,
            height: 55,

            child: ElevatedButton(

              onPressed:
              isSubmitting
                  ? null
                  : handleOrder,

              child: isSubmitting
                  ? const CircularProgressIndicator(
                color: Colors.white,
              )
                  : const Text(
                'XÁC NHẬN ĐẶT HÀNG',
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {

    return Text(
      title,

      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isDiscount = false}) {
    final moneyFormat = NumberFormat('#,###', 'vi_VN');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${moneyFormat.format(amount)} đ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(String code) {

    switch (code) {

      case 'MOMO':
        return _paymentIcon(
          Colors.pink,
          Icons.wallet,
        );

      case 'VNPAY':
        return _paymentIcon(
          Colors.blue,
          Icons.qr_code,
        );

      case 'VCB':
        return _paymentIcon(
          Colors.green,
          Icons.account_balance,
        );

      case 'MBBANK':
        return _paymentIcon(
          Colors.deepPurple,
          Icons.credit_card,
        );

      default:
        return _paymentIcon(
          Colors.orange,
          Icons.payments,
        );
    }
  }

  Widget _paymentIcon(
      Color color,
      IconData icon,
      ) {

    return Container(

      width: 50,
      height: 50,

      decoration: BoxDecoration(
        color: color,
        borderRadius:
        BorderRadius.circular(14),
      ),

      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }

  String _getPaymentDescription(
      String code,
      ) {

    switch (code) {

      case 'COD':
        return 'Thanh toán khi nhận hàng';

      case 'MOMO':
        return 'Ví điện tử MoMo';

      case 'VNPAY':
        return 'Thanh toán QR VNPay';

      case 'VCB':
        return 'Chuyển khoản Vietcombank';

      case 'MBBANK':
        return 'Chuyển khoản MB Bank';

      default:
        return 'Thanh toán online';
    }
  }
}