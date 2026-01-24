import 'package:flutter/material.dart';

/// Centralized typography definitions.
/// Provides font sizes, weights, and text styles.
abstract final class AppTypography {
  // Font sizes
  static const double fontSizeXs = 10;
  static const double fontSizeSm = 12;
  static const double fontSizeMd = 14;
  static const double fontSizeLg = 16;
  static const double fontSizeXl = 20;
  static const double fontSizeXxl = 24;
  static const double fontSizeXxxl = 32;
  static const double fontSizeDisplay = 48;

  // Line heights (multipliers)
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0;
  static const double letterSpacingWide = 0.5;

  // Font weights
  static const FontWeight weightThin = FontWeight.w100;
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightBlack = FontWeight.w900;

  // Text styles (base styles without color - apply color from theme)
  static const TextStyle displayLarge = TextStyle(
    fontSize: fontSizeDisplay,
    fontWeight: weightBold,
    height: lineHeightTight,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: fontSizeXxxl,
    fontWeight: weightBold,
    height: lineHeightTight,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: fontSizeXxl,
    fontWeight: weightSemiBold,
    height: lineHeightTight,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: fontSizeXxl,
    fontWeight: weightSemiBold,
    height: lineHeightTight,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: fontSizeXl,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: fontSizeXl,
    fontWeight: weightMedium,
    height: lineHeightNormal,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: weightMedium,
    height: lineHeightNormal,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: weightMedium,
    height: lineHeightNormal,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: weightRegular,
    height: lineHeightNormal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: weightRegular,
    height: lineHeightNormal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: weightRegular,
    height: lineHeightNormal,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: fontSizeXs,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontSizeXs,
    fontWeight: weightRegular,
    height: lineHeightNormal,
  );

  static const TextStyle button = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  /// Returns a TextTheme using AppTypography styles.
  /// Use this in ThemeData to apply custom typography globally.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
