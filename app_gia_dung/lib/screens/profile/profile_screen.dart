import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';

import '../../provider/auth_provider.dart';
import '../auth/login_screen.dart';

import '../admin/admin_product_screen.dart';
import '../admin/admin_order_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../chat/chat_screen.dart';
import '../admin/admin_chat_users_screen.dart';
import '../admin/admin_voucher_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Header Profile ---
            _buildHeader(user),

            const SizedBox(height: 24),

            // --- Menu Options ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông tin cá nhân",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard([
                    _buildMenuTile(
                      Icons.person_outline,
                      'Họ tên',
                      user?.fullName ?? 'Chưa cập nhật',
                    ),
                    _buildMenuTile(
                      Icons.email_outlined,
                      'Email',
                      user?.email ?? 'Chưa cập nhật',
                    ),
                    _buildMenuTile(
                      Icons.phone_outlined,
                      'Số điện thoại',
                      user?.phone ?? 'Chưa cập nhật',
                    ),
                    if ((user?.role ?? '') == 'Customer')
                    _buildMenuTile(
                      Icons.chat_bubble_outline,
                      'Liên hệ Admin',
                      'Nhắn tin hỗ trợ khách hàng',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatScreen(
                              receiverId: 8,
                              receiverName: 'Admin',
                            ),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),
                  const Text(
                    "Quản trị & Hệ thống",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard([
                    if ((user?.role ?? '') == 'Admin')
                      _buildMenuTile(
                        Icons.add_box_outlined,
                        'Quản lý sản phẩm',
                        'Dành cho người quản trị',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminProductScreen(),
                            ),
                          );
                        },
                      ),
                    if ((user?.role ?? '') == 'Admin')
                      _buildMenuTile(
                        Icons.receipt_long_outlined,
                        'Quản lý đơn hàng',
                        'Cập nhật trạng thái đơn hàng',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminOrderScreen(),
                            ),
                          );
                        },
                      ),
                    if ((user?.role ?? '') == 'Admin')
                      _buildMenuTile(
                        Icons.discount_outlined,
                        'Quản lý voucher',
                        'Thêm và xoá mã giảm giá',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminVoucherScreen(),
                            ),
                          );
                        },
                      ),
                    if ((user?.role ?? '') == 'Admin')
                      _buildMenuTile(
                        Icons.dashboard_outlined,
                        'Dashboard',
                        'Thống kê doanh thu & đơn hàng',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminDashboardScreen(),
                            ),
                          );
                        },
                      ),
                    if ((user?.role ?? '') == 'Admin')
                      _buildMenuTile(
                        Icons.mark_chat_unread_outlined,
                        'Tin nhắn khách hàng',
                        'Xem và trả lời khách hàng',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminChatUsersScreen(),
                            ),
                          );
                        },
                      ),

                    _buildMenuTile(
                      Icons.logout,
                      'Đăng xuất',
                      'Hẹn gặp lại bạn sớm',
                      iconColor: AppColors.danger,
                      textColor: AppColors.danger,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Người dùng',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.role?.toUpperCase() ?? 'CUSTOMER',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: AppColors.textGray),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textDark,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppColors.textGray)
          : null,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xác nhận"),
        content: const Text("Bạn có thực sự muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
