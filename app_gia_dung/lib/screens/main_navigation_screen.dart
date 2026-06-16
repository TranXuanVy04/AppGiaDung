import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

import 'cart/cart_screen.dart';
import 'home/home_screen.dart';
import 'order/order_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';
import 'wishlist/wishlist_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    SearchScreen(),
    WishlistScreen(),
    CartScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false, // Cho phép nội dung tràn xuống dưới thanh điều hướng
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textGray,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              onTap: (index) {
                setState(() => currentIndex = index);
              },
              items: [
                _buildNavItem(
                  Icons.home_rounded,
                  Icons.home_outlined,
                  'Trang chủ',
                  0,
                ),
                _buildNavItem(
                  Icons.search_rounded,
                  Icons.search_rounded,
                  'Tìm kiếm',
                  1,
                ),
                _buildNavItem(
                  Icons.favorite_rounded,
                  Icons.favorite_border_rounded,
                  'Yêu thích',
                  2,
                ),
                _buildNavItem(
                  Icons.shopping_cart_rounded,
                  Icons.shopping_cart_outlined,
                  'Giỏ hàng',
                  3,
                ),
                _buildNavItem(
                  Icons.receipt_long_rounded,
                  Icons.receipt_long_outlined,
                  'Đơn hàng',
                  4,
                ),
                _buildNavItem(
                  Icons.person_rounded,
                  Icons.person_outline,
                  'Tài khoản',
                  5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
  ) {
    bool isSelected = currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          // Hiệu ứng highlight khi được chọn
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(isSelected ? activeIcon : inactiveIcon, size: 24),
      ),
      label: label,
    );
  }
}
