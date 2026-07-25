import 'package:flutter/material.dart';

/// Colors used throughout the app. These are now brightness-aware:
/// AppColors._isDark is flipped by ThemeProvider whenever the user
/// toggles Dark Mode, and every field below is a getter (not a
/// compile-time const) so it re-evaluates against the current
/// brightness each time it's read.
class AppColors {
  AppColors._();

  static bool _isDark = false;

  /// Called by ThemeProvider whenever the dark-mode preference
  /// changes, before it notifies listeners.
  static void setDarkMode(bool isDark) {
    _isDark = isDark;
  }

  // Backgrounds
  static Color get backgroundColor =>
      _isDark ? const Color(0xFF121212) : const Color(0xFFF5F9FF);
  static Color get surfaceColor =>
      _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  static Color get surfaceBorder =>
      _isDark ? const Color(0xFF2C2C2C) : const Color(0xFFD8E7F5);

  // Text
  static Color get textColor =>
      _isDark ? const Color(0xFFECEDEE) : const Color(0xFF1F2937);
  static Color get textSecondary =>
      _isDark ? const Color(0xFF9FB3C8) : const Color(0xFF5B7FA6);
  static Color get textMuted =>
      _isDark ? const Color(0xFF7C8591) : const Color(0xFF9CA3AF);

  // Brand — kept consistent across both modes (already has enough
  // contrast on both light and dark surfaces).
  static const Color blueColor = Color(0xFF4A90E2);
  static const Color blueDark = Color(0xFF2E5B9A);

  // Status — kept vivid/consistent across both modes.
  static const Color redColor = Color(0xFFE74C3C);
  static const Color yellowColor = Color(0xFFF4B400);
  static const Color greenColor = Color(0xFF34A853);
}
