import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Đảm bảo import đúng file AppColors của bạn
import '../../core/app_colors.dart';
import 'package:intl/intl.dart';

import '../../models/product_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/cart_provider.dart';
import '../../provider/wishlist_provider.dart';
import '../cart/cart_screen.dart';
import '../order/buy_now_checkout_screen.dart';
import '../../services/review_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;


  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isSubmittingCart = false;
  bool isSubmittingBuyNow = false;
  final ReviewService reviewService = ReviewService();
  List<dynamic> reviews = [];
  bool isLoadingReviews = false;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      loadReviews();
    });
  }

  Future<void> loadReviews() async {
    setState(() => isLoadingReviews = true);

    try {
      reviews = await reviewService.getReviews(widget.product.id);
    } catch (e) {
      debugPrint('Lỗi tải đánh giá: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingReviews = false);
      }
    }
  }

  Future<void> handleAddToCart() async {
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    if (authProvider.token == null || authProvider.token!.isEmpty) {
      _showSnackBar('Bạn chưa đăng nhập', isError: true);
      return;
    }

    try {
      setState(() => isSubmittingCart = true);
      await cartProvider.addToCart(
        token: authProvider.token!,
        productId: widget.product.id,
        quantity: quantity,
      );
      if (!mounted) return;
      _showSnackBar('Đã thêm vào giỏ hàng thành công ✨');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Lỗi: $e', isError: true);
    } finally {
      if (mounted) setState(() => isSubmittingCart = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> handleBuyNow() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      _showSnackBar('Bạn chưa đăng nhập', isError: true);
      return;
    }

    setState(() => isSubmittingBuyNow = true);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BuyNowCheckoutScreen(product: widget.product, quantity: quantity),
      ),
    );
    if (mounted) setState(() => isSubmittingBuyNow = false);
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: AppColors.textGray),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final wishlistProvider = context.watch<WishlistProvider>();
    final isFavorite = wishlistProvider.isFavorite(product.id);
    final moneyFormat = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: const BackButton(color: AppColors.textDark),
          ),
        ),
        actions: [
          _buildCircleAction(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            iconColor: isFavorite ? AppColors.danger : AppColors.textDark,
            onTap: () => wishlistProvider.toggleWishlist(product),
          ),
          _buildCircleAction(
            icon: Icons.shopping_bag_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ================= IMAGE HEADER =================
                Stack(
                  children: [
                    Hero(
                      tag: 'product-${product.id}',
                      child: Container(
                        height: 400,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                        ),
                        child:
                            product.imageUrl != null &&
                                product.imageUrl!.isNotEmpty
                            ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 100,
                                  color: AppColors.textGray,
                                );
                              },
                            )
                            : const Icon(
                                Icons.image_not_supported,
                                size: 100,
                                color: AppColors.textGray,
                              ),
                      ),
                    ),
                    if (product.oldPrice != null)
                      Positioned(
                        left: 20,
                        bottom: 30,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'GIẢM SỐC',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= NAME & PRICE =================
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${moneyFormat.format(product.price)} đ',
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (product.oldPrice != null)
                            Text(
                              '${moneyFormat.format(product.oldPrice)} đ',
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ================= INFO CARDS =================
                      Row(
                        children: [
                          _buildInfoCard(
                            icon: Icons.star_rounded,
                            title: 'Đánh giá',
                            value: product.rating.toStringAsFixed(1),
                          ),

                          const SizedBox(width: 8),

                          _buildInfoCard(
                            icon: Icons.shopping_bag_rounded,
                            title: 'Đã bán',
                            value: '${product.soldCount}',
                          ),

                          const SizedBox(width: 8),

                          _buildInfoCard(
                            icon: Icons.verified_user_outlined,
                            title: 'Chính hãng',
                            value: product.brand ?? 'Gia Dụng',
                          ),

                          const SizedBox(width: 8),

                          _buildInfoCard(
                            icon: Icons.inventory_2_outlined,
                            title: 'Sẵn có',
                            value: '${product.stock} sp',
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // ================= QUANTITY SELECTOR =================
                      const Text(
                        'Số lượng đặt hàng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _qtyBtn(
                            Icons.remove,
                            () => setState(
                              () => quantity > 1 ? quantity-- : null,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _qtyBtn(
                            Icons.add,
                            () => setState(
                              () =>
                                  quantity < product.stock ? quantity++ : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // ================= DESCRIPTION =================
                      const Text(
                        'Mô tả sản phẩm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description?.isNotEmpty == true
                            ? product.description!
                            : 'Chưa có thông tin mô tả chi tiết cho sản phẩm này.',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textGray,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Đánh giá sản phẩm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (isLoadingReviews)
                        const Center(child: CircularProgressIndicator())
                      else if (reviews.isEmpty)
                        const Text('Chưa có đánh giá nào')
                      else
                        Column(
                          children: reviews.map((review) {
                            return Card(
                              child: ListTile(
                                title: Text(review['userName'] ?? 'Người dùng'),
                                subtitle: Text(review['comment'] ?? ''),
                                trailing: Text(
                                  '${review['rating']} ⭐',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 24),

                      // ================= SHIPPING TAG =================
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.2),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.local_shipping_rounded,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Giao hàng nhanh chóng và miễn phí đổi trả trong 7 ngày.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= BOTTOM ACTIONS =================
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          child: Icon(icon, color: iconColor ?? AppColors.textDark, size: 22),
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: isSubmittingCart ? null : handleAddToCart,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isSubmittingCart
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Icon(
                        Icons.add_shopping_cart_rounded,
                        color: AppColors.primary,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isSubmittingBuyNow ? null : handleBuyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isSubmittingBuyNow
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'MUA NGAY',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.1,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
