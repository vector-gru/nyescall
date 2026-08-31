import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// The green circular phone icon used in the app bar and landing screen.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.phone_rounded,
        color: Colors.white,
        size: size * 0.52,
      ),
    );
  }
}
