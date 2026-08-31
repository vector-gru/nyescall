import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/widgets.dart';
import '../../data/models/subscription_model.dart';
import '../providers/home_provider.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final subAsync = ref.watch(subscriptionProvider);
    final paymentsAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppConstants.appName, style: AppTextStyles.titleLarge),
                Text(
                  user?.displayName ?? user?.email ?? 'My Account',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: subAsync.when(
        loading: () => const NyLoading(),
        error: (e, _) => _HomeBody(
          sub: SubscriptionModel.trial(),
          paymentsAsync: const AsyncData([]),
          isOrg: ref.watch(isOrgAccountProvider),
        ),
        data: (sub) => _HomeBody(
          sub: sub,
          paymentsAsync: paymentsAsync,
          isOrg: ref.watch(isOrgAccountProvider),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.sub,
    required this.paymentsAsync,
    required this.isOrg,
  });

  final SubscriptionModel sub;
  final AsyncValue<List<Map<String, dynamic>>> paymentsAsync;
  final bool isOrg;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => Future.delayed(const Duration(milliseconds: 600)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Org setup banner — only for organisation accounts ───────
          if (isOrg) _OrgSetupBanner(),

          // ── Plan expiring warning ──────────────────────────────────────
          if (sub.isExpiringSoon) ...[
            const SizedBox(height: 12),
            _ExpiryWarning(sub: sub),
          ],

          const SizedBox(height: 12),

          // ── Subscription card ─────────────────────────────────────────
          NyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const NySectionHeader(AppStrings.subscription),
                    NyBadge(label: sub.statusLabel),
                  ],
                ),
                const SizedBox(height: 10),

                // Plan name
                Text(sub.planLabel, style: AppTextStyles.headlineMedium),

                const SizedBox(height: 4),

                // Date range + days left
                Text(
                  '${_fmt(sub.startDate)} → ${_fmt(sub.endDate)}  ·  ${sub.daysLeft} days left',
                  style: AppTextStyles.bodySmall,
                ),

                const SizedBox(height: 16),

                // Calls used
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.callsUsed, style: AppTextStyles.bodySmall),
                    Text('${sub.callsUsed} / ${sub.callsIncluded}',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: sub.usagePercent,
                    backgroundColor: AppColors.primaryLighter,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),

                const SizedBox(height: 14),

                // Extra calls + overage
                Row(
                  children: [
                    Expanded(
                      child: NyCard(
                        backgroundColor: AppColors.surfaceVariant,
                        borderColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.trending_up_rounded,
                                    size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(AppStrings.extraCalls,
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${sub.extraCalls}',
                                style: AppTextStyles.headlineSmall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NyCard(
                        backgroundColor: AppColors.surfaceVariant,
                        borderColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.overageDue,
                                style: AppTextStyles.bodySmall),
                            const SizedBox(height: 4),
                            Text('${sub.overageDueXaf} XAF',
                                style: AppTextStyles.headlineSmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Place an AI call CTA
                NyButton(
                  label: AppStrings.placeAnAiCall,
                  icon: const Icon(Icons.phone_rounded,
                      color: Colors.white, size: 18),
                  onPressed: () => context.go(AppRoutes.call),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Renewal history ───────────────────────────────────────────
          const NySectionHeader(AppStrings.renewalHistory),
          const SizedBox(height: 8),
          NyCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(sub.planLabel, style: AppTextStyles.bodyMedium),
                Text(
                  '${_fmt(sub.startDate)} → ${_fmt(sub.endDate)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Payments ──────────────────────────────────────────────────
          const NySectionHeader(AppStrings.payments),
          const SizedBox(height: 8),
          paymentsAsync.when(
            loading: () => const NyLoading(),
            error: (_, __) => const SizedBox.shrink(),
            data: (payments) => payments.isEmpty
                ? NyCard(
                    child: Text(AppStrings.noPaymentsYet,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  )
                : Column(
                    children:
                        payments.map((p) => _PaymentRow(payment: p)).toList(),
                  ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _OrgSetupBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: drive this from org profile completion state
    return NyCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NyBadge(
                    label: 'ORGANIZATION ACCOUNT',
                    variant: NyBadgeVariant.info),
                const SizedBox(height: 8),
                Text(AppStrings.organizationSetupPending,
                    style: AppTextStyles.headlineSmall),
                const SizedBox(height: 4),
                Text(AppStrings.finishInstitutionProfile,
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 12),
                NyButton(
                  label: 'Organization',
                  height: 38,
                  onPressed: () => context.push(AppRoutes.organization),
                  variant: NyButtonVariant.outlined,
                  fullWidth: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryWarning extends StatelessWidget {
  const _ExpiryWarning({required this.sub});
  final SubscriptionModel sub;

  @override
  Widget build(BuildContext context) {
    return NyCard(
      borderColor: AppColors.warning,
      backgroundColor: AppColors.planExpiresBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time_rounded,
              color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.planExpires} ${sub.daysLeft} ${AppStrings.days}',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.planExpiresText),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppStrings.renewBefore} ${DateFormat('dd MMM yyyy').format(sub.endDate)} ${AppStrings.toAvoidInterruption}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.planExpiresText),
                ),
                const SizedBox(height: 10),
                NyButton(
                  label: AppStrings.renew,
                  height: 36,
                  onPressed: () => context.go(AppRoutes.billing),
                  backgroundColor: AppColors.warning,
                  fullWidth: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});
  final Map<String, dynamic> payment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NyCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(payment['plan'] as String? ?? '—',
                style: AppTextStyles.bodyMedium),
            Text('${payment['amountXaf'] ?? 0} XAF',
                style: AppTextStyles.titleMedium),
          ],
        ),
      ),
    );
  }
}
