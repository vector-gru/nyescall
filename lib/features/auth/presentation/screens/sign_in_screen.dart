import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/widgets.dart';
import '../providers/auth_notifier.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
  }

  Future<void> _googleSignIn() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthActionLoading;

    // Listen for errors.
    ref.listen<AuthActionState>(authNotifierProvider, (_, next) {
      if (next is AuthActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authNotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Back ──────────────────────────────────────────────────────
              GestureDetector(
                onTap: () => context.pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(AppStrings.backToHome,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
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
                      Text(AppStrings.welcomeBack,
                          style: AppTextStyles.displayMedium),
                      Text(AppStrings.trialIncluded,
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Form card ─────────────────────────────────────────────────
              NyCard(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NyTextField(
                        label: AppStrings.email,
                        hint: AppStrings.emailHint,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      NyTextField(
                        label: AppStrings.password,
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 20),
                      NyButton(
                        label: AppStrings.signIn,
                        onPressed: _submit,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 16),
                      const NyDivider(label: AppStrings.or),
                      const SizedBox(height: 16),
                      NyButton(
                        label: AppStrings.continueWithGoogle,
                        onPressed: isLoading ? null : _googleSignIn,
                        variant: NyButtonVariant.outlined,
                        icon: Image.network(
                          'https://www.google.com/favicon.ico',
                          width: 18,
                          height: 18,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.g_mobiledata_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.signUp),
                          child: Text(
                            AppStrings.newHereCreateAccount,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
