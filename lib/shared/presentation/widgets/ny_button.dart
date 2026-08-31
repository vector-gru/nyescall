import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/theme/app_colors.dart';

enum NyButtonVariant { filled, outlined, text }

/// Primary button component — covers filled (CTA), outlined, and text variants.
///
/// [fullWidth] defaults to true (expands to fill available width).
/// Set to false for compact inline buttons like "Organization" or "Renew"
/// where the button should only be as wide as its label.
class NyButton extends StatelessWidget {
  const NyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NyButtonVariant.filled,
    this.isLoading = false,
    this.icon,
    this.height = 52,
    this.borderRadius = 12,
    this.backgroundColor,
    this.foregroundColor,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final NyButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// When false the button shrink-wraps to its content width.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? LoadingAnimationWidget.threeArchedCircle(
            color: variant == NyButtonVariant.filled
                ? Colors.white
                : AppColors.primary,
            size: 22,
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
              )
            : Text(label, overflow: TextOverflow.ellipsis);

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    final double? width = fullWidth ? double.infinity : null;

    switch (variant) {
      case NyButtonVariant.filled:
        return SizedBox(
          height: height,
          width: width,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColors.primary,
              foregroundColor: foregroundColor ?? Colors.white,
              minimumSize: fullWidth ? null : Size(0, height),
              shape: shape,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            ),
            child: child,
          ),
        );

      case NyButtonVariant.outlined:
        return SizedBox(
          height: height,
          width: width,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: foregroundColor ?? AppColors.textPrimary,
              minimumSize: fullWidth ? null : Size(0, height),
              side: BorderSide(
                color: backgroundColor ?? AppColors.cardBorder,
                width: 1.5,
              ),
              shape: shape,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            ),
            child: child,
          ),
        );

      case NyButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }
  }
}
