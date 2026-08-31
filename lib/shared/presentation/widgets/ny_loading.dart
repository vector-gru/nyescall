import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/theme/app_colors.dart';

/// Full-screen or inline loading indicator.
class NyLoading extends StatelessWidget {
  const NyLoading({super.key, this.size = 36, this.fullScreen = false});

  final double size;
  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    final indicator = LoadingAnimationWidget.threeArchedCircle(
      color: AppColors.primary,
      size: size,
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: indicator),
      );
    }

    return Center(child: indicator);
  }
}
