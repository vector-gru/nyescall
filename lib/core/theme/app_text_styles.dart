import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Named text styles using Inter via google_fonts.
/// All weights are sourced from the network on first use and cached on-device.
abstract final class AppTextStyles {
  // ── Helpers ────────────────────────────────────────────────────────────────
  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    double height = 1.4,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        color: color,
        letterSpacing: letterSpacing,
      );

  // ── Display / Hero ─────────────────────────────────────────────────────────
  static TextStyle get displayLarge => _inter(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => _inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      );

  // ── Headlines ──────────────────────────────────────────────────────────────
  static TextStyle get headlineLarge =>
      _inter(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3);

  static TextStyle get headlineMedium =>
      _inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35);

  static TextStyle get headlineSmall =>
      _inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  // ── Title ─────────────────────────────────────────────────────────────────
  static TextStyle get titleLarge =>
      _inter(fontSize: 15, fontWeight: FontWeight.w600);

  static TextStyle get titleMedium =>
      _inter(fontSize: 14, fontWeight: FontWeight.w500);

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge =>
      _inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodyMedium =>
      _inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodySmall => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  // ── Label ─────────────────────────────────────────────────────────────────
  static TextStyle get labelLarge =>
      _inter(fontSize: 14, fontWeight: FontWeight.w600);

  static TextStyle get labelMedium => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.4,
      );

  // ── Button ────────────────────────────────────────────────────────────────
  static TextStyle get buttonLarge => _inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: AppColors.textOnPrimary,
      );

  static TextStyle get buttonMedium =>
      _inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.25);

  // ── Overline / Badges ─────────────────────────────────────────────────────
  static TextStyle get overline => _inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      );

  static TextStyle get priceLarge =>
      _inter(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2);
}
