// =============================================================================
// AeroYield — App Theme Constants
// Centralized color palette and typography styles for the entire application.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Color Palette
// ---------------------------------------------------------------------------
class AppColors {
  AppColors._();

  // Primary — agricultural greens
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryDark = Color(0xFF0D3B13);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primarySurface = Color(0xFFE8F5E9);

  // Splash screen gradient stops
  static const Color splashStart = Color(0xFF0D3B13);
  static const Color splashEnd = Color(0xFF1B5E20);

  // Crop Vital Score dynamic thresholds
  static const Color scoreGreen = Color(0xFF2E7D32);
  static const Color scoreAmber = Color(0xFFF57C00);
  static const Color scoreRed = Color(0xFFC62828);

  // Surface / chrome
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  // Accent & utility
  static const Color accent = Color(0xFFFFA726);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color helpline = Color(0xFF1565C0);
  static const Color micGlow = Color(0x404CAF50);

  /// Return the status color for a given Crop Vital Score (0–100).
  static Color scoreColor(int score) {
    if (score >= 75) return scoreGreen;
    if (score >= 45) return scoreAmber;
    return scoreRed;
  }
}

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------
class AppTextStyles {
  AppTextStyles._();

  /// Returns the correct font family based on the current locale.
  static TextStyle _localized(
    Locale locale, {
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    if (locale.languageCode == 'ur') {
      return GoogleFonts.notoNastaliqUrdu(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height ?? 1.8, // Urdu Nastaliq needs extra line height
      );
    }
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.4,
    );
  }

  // Convenience factory methods for each semantic text role.
  static TextStyle headline(Locale locale) =>
      _localized(locale, size: 28, weight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle title(Locale locale) =>
      _localized(locale, size: 22, weight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle subtitle(Locale locale) =>
      _localized(locale, size: 16, weight: FontWeight.w500, color: AppColors.textSecondary);

  static TextStyle body(Locale locale) =>
      _localized(locale, size: 15, weight: FontWeight.w400, color: AppColors.textPrimary);

  static TextStyle caption(Locale locale) =>
      _localized(locale, size: 13, weight: FontWeight.w400, color: AppColors.textSecondary);

  static TextStyle button(Locale locale) =>
      _localized(locale, size: 17, weight: FontWeight.w600, color: Colors.white);

  static TextStyle scoreLarge(Locale locale) =>
      _localized(locale, size: 48, weight: FontWeight.w700, color: AppColors.textPrimary);
}
