import 'package:flutter/material.dart';

class AppColors {
  // --- SHARED COLORS ---
  static const Color primaryRed = Color(0xFFE50914);

  // --- LEGACY COLORS (Required for Home Screen) ---
  // These were missing and causing your error
  static const Color textGrey = Color(0xFF8E8E93);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color background = Color(0xFF0D0D0D);

  // --- LIGHT THEME COLORS ---
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF000000);

  // --- DARK THEME COLORS ---
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkText = Color(0xFFFFFFFF);
}
