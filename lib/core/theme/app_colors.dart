import 'package:flutter/material.dart';

/// NYESCALL brand color palette — derived from the screenshots.
abstract final class AppColors {
  // ── Primary green ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF16A34A);        // main CTA green
  static const Color primaryLight = Color(0xFF22C55E);   // hover / active tint
  static const Color primaryLighter = Color(0xFFDCFCE7); // subtle bg tint
  static const Color primaryContainer = Color(0xFFBBF7D0);

  // ── Neutral / surface ──────────────────────────────────────────────────────
  static const Color background = Color(0xFFF0FDF4);     // very light green tint bg
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Bottom navigation ──────────────────────────────────────────────────────
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navSelected = Color(0xFF16A34A);
  static const Color navUnselected = Color(0xFF94A3B8);

  // ── Misc ───────────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
  static const Color trialBadge = Color(0xFF16A34A);
  static const Color orgBadge = Color(0xFFE0F2FE);   // light blue chip
  static const Color orgBadgeText = Color(0xFF0369A1);
  static const Color planExpiresBg = Color(0xFFFEF3C7);
  static const Color planExpiresText = Color(0xFFD97706);
}
