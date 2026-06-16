import 'package:flutter/material.dart';

class AppColors {
  // --- Màu chủ đạo (Brand Colors) ---
  static const Color primary = Color(0xFF28B6F6); // Xanh dương chính
  static const Color primaryLight = Color(
    0xFFE3F2FD,
  ); // Xanh dương nhạt (thay cho secondary cũ)
  static const Color secondary = Color(
    0xFFEAF8FF,
  ); // Xanh cực nhạt (background item)

  // --- Màu chữ (Text Colors) ---
  static const Color textDark = Color(0xFF1E1E1E); // Tiêu đề chính
  static const Color textBody = Color(0xFF4A5568); // Nội dung văn bản
  static const Color textGray = Color(0xFF8E8E93); // Chữ phụ, chú thích
  static const Color textLight = Color(0xFF9E9E9E); // Chữ rất nhạt

  // --- Màu trạng thái (Status Colors) ---
  static const Color danger = Color(0xFFFF4D6D); // Đỏ (Lỗi, Giá tiền)
  static const Color success = Color(
    0xFF10B981,
  ); // Xanh lá (Hoàn thành, Voucher)
  static const Color warning = Color(0xFFFF9800); // Cam (Chờ xác nhận)
  static const Color info = Color(0xFF673AB7); // Tím (Giao hàng)
  static const Color errorLight = Color(0xFFFFEBEE); // Đỏ nền nhạt

  // --- Màu giao diện & Background ---
  static const Color scaffoldBg = Color(
    0xFFF8F9FA,
  ); // Nền xám nhạt màn hình (trùng bgLight)
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // Nền trắng (Card, BottomSheet)
  static const Color searchBarFill = Color(0xFFF5F7FA); // Nền thanh search
  static const Color divider = Color(0xFFEEEEEE); // Đường kẻ chia cắt

  // --- Hiệu ứng (Effects) ---
  static const Color cardShadow = Color(
    0x0A000000,
  ); // Đổ bóng cực nhẹ (trùng shadowColor)
  static const Color iconColor = Color(0xFF748A9D); // Màu icon trầm
  // Thêm vào class AppColors của bạn
  static const Color shadow = Color(
    0x0A000000,
  ); // Đổ bóng cực nhẹ cho các thẻ Card
  static const Color overlayDanger = Color(
    0x0DFF4D6D,
  ); // Màu đỏ Danger với độ trong suốt 5% (dùng cho nền icon trống)
  static const Color overlayPrimary = Color(
    0x1A28B6F6,
  ); // Màu xanh Primary với độ trong suốt 10%
  // Thêm vào class AppColors của bạn
  static const Color navUnselected = Color(
    0xFF94A3B8,
  ); // Màu icon khi không chọn (xám xanh)
  static const Color navBackground = Color(
    0xFFFFFFFF,
  ); // Nền của thanh điều hướng
  static const Color starColor = Color(0xFFFFB300); // Màu vàng hổ phách cho sao
  static const Color priceColor = Color(
    0xFFE91E63,
  ); // Màu hồng đỏ hiện đại cho giá
  static const Color imageBg = Color(
    0xFFF8FAFC,
  ); // Màu nền ảnh sản phẩm cực nhạt
}
