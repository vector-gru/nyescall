import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/widgets.dart';
import '../providers/auth_notifier.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _accountType = AppConstants.accountTypeIndividual;
  String _fullPhone = '';
  bool _phoneValid = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          accountType: _accountType,
        );
  }

  Future<void> _googleSignUp() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthActionLoading;

    ref.listen<AuthActionState>(authNotifierProvider, (_, next) {
      if (next is AuthActionError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(authNotifierProvider.notifier).reset();
      } else if (next is AuthActionSuccess && next.emailSent) {
        context.pushReplacement(
          AppRoutes.emailConfirmation,
          extra: _emailCtrl.text.trim(),
        );
      }
    });

    final isIndividual = _accountType == AppConstants.accountTypeIndividual;

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
                    Text(
                      AppStrings.backToHome,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Header ────────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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

              const SizedBox(height: 24),

              // ── Form card ─────────────────────────────────────────────────
              NyCard(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Step 1 — Account type ─────────────────────────────
                      Text(
                        AppStrings.step1AccountType,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _AccountTypeCard(
                              title: AppStrings.individual,
                              subtitle: AppStrings.individualDesc,
                              isSelected: isIndividual,
                              onTap: () => setState(() => _accountType =
                                  AppConstants.accountTypeIndividual),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _AccountTypeCard(
                              title: AppStrings.organization,
                              subtitle: AppStrings.organizationDesc,
                              isSelected: !isIndividual,
                              onTap: () => setState(() => _accountType =
                                  AppConstants.accountTypeOrganization),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Selected type label
                      Text(
                        isIndividual
                            ? 'INDIVIDUAL ACCOUNT'
                            : 'ORGANIZATION ACCOUNT',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Step 2 — Your details ─────────────────────────────
                      Text(
                        'Step 2 — Your name',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 10),

                      // Name
                      TextFormField(
                        controller: _nameCtrl,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyMedium,
                        validator: (v) => Validators.required(v, 'Full name'),
                        decoration: const InputDecoration(
                          hintText: 'Jane Cooper',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone
                      Text(AppStrings.phoneNumber,
                          style: AppTextStyles.titleMedium),
                      const SizedBox(height: 6),
                      IntlPhoneField(
                        initialCountryCode: 'CM',
                        decoration: const InputDecoration(
                          hintText: '6XX XX XX XX',
                        ),
                        style: AppTextStyles.bodyMedium,
                        onChanged: (phone) {
                          _fullPhone = phone.completeNumber;
                          try {
                            _phoneValid = phone.isValidNumber();
                          } catch (_) {
                            _phoneValid = false;
                          }
                        },
                        onCountryChanged: (_) {},
                      ),

                      const SizedBox(height: 16),

                      // Email
                      NyTextField(
                        label: AppStrings.email,
                        hint: AppStrings.emailHint,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),

                      const SizedBox(height: 16),

                      // Password
                      NyTextField(
                        label: AppStrings.password,
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
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

                      const SizedBox(height: 16),

                      // Confirm password
                      NyTextField(
                        label: 'Confirm password',
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please confirm your password.';
                          }
                          if (v != _passwordCtrl.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── CTA ───────────────────────────────────────────────
                      NyButton(
                        label: AppStrings.startFreeTrial2,
                        onPressed: _submit,
                        isLoading: isLoading,
                      ),

                      const SizedBox(height: 16),

                      const NyDivider(label: AppStrings.or),

                      const SizedBox(height: 16),

                      NyButton(
                        label: AppStrings.continueWithGoogle,
                        onPressed: isLoading ? null : _googleSignUp,
                        variant: NyButtonVariant.outlined,
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.signIn),
                          child: Text(
                            AppStrings.alreadyHaveAccountSignIn,
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

// ── Account type card ──────────────────────────────────────────────────────

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLighter : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.overline.copyWith(
                color: AppColors.primary,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
