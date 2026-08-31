import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Horizontal line with optional centred label ("OR").
class NyDivider extends StatelessWidget {
  const NyDivider({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return const Divider(color: AppColors.divider, height: 1);
    }

    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label!,
            style: AppTextStyles.bodySmall,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
      ],
    );
  }
}
