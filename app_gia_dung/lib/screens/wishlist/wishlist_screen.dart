import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart'; // Đảm bảo đường dẫn này đúng với dự án của bạn

import '../../provider/wishlist_provider.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng watch để lắng nghe sự thay đổi từ WishlistProvider
    final wishlistProvider = context.watch<WishlistProvider>();
    final items = wishlistProvider.items;

    return Scaffold(
      // Sử dụng màu nền xám cực nhạt để làm nổi bật các Card trắng
      backgroundColor: AppColors.scaffoldBg,

      appBar: AppBar(
        title: const Text(
          'Sản phẩm yêu thích',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0, // Loại bỏ đường kẻ mặc định của AppBar
        centerTitle: true,
      ),

      body: items.isEmpty
          ? _buildEmptyState(context)
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72, // Tỉ lệ này giúp card cân đối hơn
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                // Bạn có thể bọc ProductCard vào một Container nếu muốn thêm hiệu ứng riêng
                return ProductCard(product: items[index]);
              },
            ),
    );
  }

  // --- Giao diện khi danh sách trống ---
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vòng tròn trang trí cho Icon
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight, // Sử dụng màu xanh nhạt vừa thêm
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 70,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có sản phẩm nào',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              'Hãy khám phá và lưu lại những sản phẩm bạn ưng ý nhất nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Nút kêu gọi hành động
          SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text(
                'Mua sắm ngay',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
