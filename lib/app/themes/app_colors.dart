import 'package:flutter/material.dart';

/// App Colors untuk Posbankum
/// Warna-warna ini diambil dari desain Figma
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2B3A67);
  static const Color primaryDark = Color(0xFF1F2940);
  static const Color primaryLight = Color(0xFF3D4E7A);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryLight = Color(0xFFFF8F6B);

  // Background
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundCard = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFB0B0B0);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF2B3A67);
  static const Color buttonSecondary = Color(0xFFFFFFFF);
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonText = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Shadow
  static const Color shadow = Color(0x1A000000);

  // Page Indicator (untuk onboarding)
  static const Color indicatorActive = Color(0xFF2B3A67);
  static const Color indicatorInactive = Color(0xFFD9D9D9);

  // Gradient (jika diperlukan)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2B3A67), Color(0xFF3D4E7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
