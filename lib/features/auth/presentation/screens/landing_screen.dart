import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/widgets.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App name header ──────────────────────────────────────────
              Row(
                children: [
                  const AppLogo(size: 44),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: AppTextStyles.headlineSmall,
                      ),
                      Text(
                        AppConstants.appTagline,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Hero headline ────────────────────────────────────────────
              Text(
                AppStrings.landingHeadline,
                style: AppTextStyles.displayLarge,
              ),

              const SizedBox(height: 16),

              Text(
                AppStrings.landingSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              // ── Feature highlights ───────────────────────────────────────
              NyFeatureRow(
                icon: Icons.translate_rounded,
                title: AppStrings.feature12Languages,
                subtitle: AppStrings.feature12LanguagesDesc,
              ),
              const SizedBox(height: 12),
              NyFeatureRow(
                icon: Icons.autorenew_rounded,
                title: AppStrings.featureSubscription,
                subtitle: AppStrings.featureSubscriptionDesc,
              ),
              const SizedBox(height: 12),
              NyFeatureRow(
                icon: Icons.security_rounded,
                title: AppStrings.featureLocalPayments,
                subtitle: AppStrings.featureLocalPaymentsDesc,
              ),

              const SizedBox(height: 28),

              // ── Pricing cards ────────────────────────────────────────────
              _PricingRow(
                label: 'Monthly',
                sublabel: '1,000 calls included',
                price:
                    '${AppConstants.monthlyPrice.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '\u202F')} XAF',
              ),
              const SizedBox(height: 8),
              _PricingRow(
                label: '6 months',
                sublabel: '6,000 calls included',
                price:
                    '${AppConstants.sixMonthsPrice.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '\u202F')} XAF',
              ),
              const SizedBox(height: 8),
              _PricingRow(
                label: 'Yearly',
                sublabel: '12,000 calls included',
                price:
                    '${AppConstants.yearlyPrice.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '\u202F')} XAF',
              ),

              const SizedBox(height: 32),

              // ── CTAs ─────────────────────────────────────────────────────
              NyButton(
                label: AppStrings.startFreeTrial,
                onPressed: () => context.push(AppRoutes.signUp),
              ),

              const SizedBox(height: 12),

              NyButton(
                label: AppStrings.alreadyHaveAccount,
                onPressed: () => context.push(AppRoutes.signIn),
                variant: NyButtonVariant.outlined,
              ),

              const SizedBox(height: 24),

              // ── Footer ───────────────────────────────────────────────────
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall,
                    children: const [
                      TextSpan(text: AppStrings.poweredBy),
                      TextSpan(text: '  ·  '),
                      TextSpan(text: AppStrings.pricesInXaf),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  const _PricingRow({
    required this.label,
    required this.sublabel,
    required this.price,
  });

  final String label;
  final String sublabel;
  final String price;

  @override
  Widget build(BuildContext context) {
    return NyCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.titleMedium),
              const SizedBox(height: 2),
              Text(sublabel, style: AppTextStyles.bodySmall),
            ],
          ),
          Text(price, style: AppTextStyles.priceLarge),
        ],
      ),
    );
  }
}
