import 'package:flutter/material.dart';

/// Centralized color definitions for the application.
/// Use these instead of direct Colors.xxx calls for consistency and maintainability.
abstract final class AppColors {
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);

  // Primary colors
  static const Color primary = Color(0xFF6750A4);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color danger = Color(0xFFF44336);

  // Stock indicator colors (aliases for semantic clarity)
  static const Color stockPositive = success;
  static const Color stockNegative = danger;

  /// Returns success color with optional opacity
  static Color successWithOpacity([double opacity = 0.2]) =>
      success.withValues(alpha: opacity);

  /// Returns warning color with optional opacity
  static Color warningWithOpacity([double opacity = 0.2]) =>
      warning.withValues(alpha: opacity);

  /// Returns danger color with optional opacity
  static Color dangerWithOpacity([double opacity = 0.2]) =>
      danger.withValues(alpha: opacity);

  /// Returns info color with optional opacity
  static Color infoWithOpacity([double opacity = 0.2]) =>
      info.withValues(alpha: opacity);
}
