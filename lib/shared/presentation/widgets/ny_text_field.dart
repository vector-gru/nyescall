import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_text_styles.dart';

/// Standard labelled text field used throughout all forms.
class NyTextField extends StatelessWidget {
  const NyTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.initialValue,
    this.showCounter = false,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool showCounter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleMedium),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onTap: onTap,
          enabled: enabled,
          autofocus: autofocus,
          focusNode: focusNode,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            counterText: showCounter ? null : '',
          ),
        ),
      ],
    );
  }
}
