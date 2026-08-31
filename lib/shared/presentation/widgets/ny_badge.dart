import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum NyBadgeVariant { primary, success, warning, info, neutral }

/// Small label chip used for "Trial", "ORGANIZATION ACCOUNT", role tags, etc.
class NyBadge extends StatelessWidget {
  const NyBadge({
    super.key,
    required this.label,
    this.variant = NyBadgeVariant.success,
  });

  final String label;
  final NyBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      NyBadgeVariant.primary => (AppColors.primaryLighter, AppColors.primary),
      NyBadgeVariant.success => (AppColors.primaryLighter, AppColors.primary),
      NyBadgeVariant.warning => (AppColors.warningLight, AppColors.warning),
      NyBadgeVariant.info => (AppColors.orgBadge, AppColors.orgBadgeText),
      NyBadgeVariant.neutral => (
          AppColors.surfaceVariant,
          AppColors.textSecondary
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.overline.copyWith(color: fg, letterSpacing: 0.6),
      ),
    );
  }
}
