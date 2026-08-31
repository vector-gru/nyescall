import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// Small all-caps section label, e.g. "SUBSCRIPTION", "PAYMENTS".
class NySectionHeader extends StatelessWidget {
  const NySectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.overline,
    );
  }
}
