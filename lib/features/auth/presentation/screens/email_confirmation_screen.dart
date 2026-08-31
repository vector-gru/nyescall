import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/widgets.dart';

class EmailConfirmationScreen extends ConsumerStatefulWidget {
  const EmailConfirmationScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState
    extends ConsumerState<EmailConfirmationScreen> {
  Timer? _pollTimer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Poll every 4 seconds to see if the user clicked the link.
    _pollTimer =
        Timer.periodic(const Duration(seconds: 4), (_) => _checkVerification());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final verified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (verified && mounted) {
        _pollTimer?.cancel();
        context.go(AppRoutes.home);
      }
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _resendEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not resend: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Back ──────────────────────────────────────────────────────
              GestureDetector(
                onTap: () => context.go(AppRoutes.signIn),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.backToHome,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  const AppLogo(size: 44),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.createYourAccount,
                          style: AppTextStyles.displayMedium),
                      Text(AppStrings.trialIncluded,
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Confirmation card ─────────────────────────────────────────
              NyCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.confirmYourEmail,
                        style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium,
                        children: [
                          const TextSpan(
                              text: 'We sent a confirmation link to '),
                          TextSpan(
                            text: widget.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(
                              text:
                                  '. Click it to activate your 7-day trial, then sign in.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    NyButton(
                      label: AppStrings.backToSignIn,
                      onPressed: () => context.go(AppRoutes.signIn),
                      variant: NyButtonVariant.outlined,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: _resendEmail,
                        child: const Text('Resend email'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Checking indicator ────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Waiting for verification…',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
