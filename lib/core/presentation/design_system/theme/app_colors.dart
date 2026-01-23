import 'package:flutter/material.dart';

/// Centralized color definitions for the application.
/// Use these instead of direct Colors.xxx calls for consistency and maintainability.
abstract final class AppColors {
  // Neutral colors (defined first as they're referenced by other colors)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Primary colors
  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = white;
  static const Color primaryContainer = Color(0xFFEADDFF);

  // Secondary colors
  static const Color secondary = Color(0xFF625B71);
  static const Color onSecondary = white;
  static const Color secondaryContainer = Color(0xFFE8DEF8);

  // Tertiary colors
  static const Color tertiary = Color(0xFF7D5260);
  static const Color onTertiary = white;
  static const Color tertiaryContainer = Color(0xFFFFD8E4);

  // Error colors
  static const Color error = Color(0xFFB3261E);
  static const Color onError = white;
  static const Color errorContainer = Color(0xFFF9DEDC);

  // Surface colors
  static const Color surface = Color(0xFFFFFBFE);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // Background colors
  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = Color(0xFF1C1B1F);

  // Outline colors
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color danger = Color(0xFFF44336);
  static const Color dangerLight = Color(0xFFFFEBEE);

  // Stock indicator colors (aliases for semantic clarity)
  static const Color stockPositive = success;
  static const Color stockNegative = danger;

  // Grey shades
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

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
