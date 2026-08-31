import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/widgets.dart';
import '../../../home/data/models/subscription_model.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/billing_provider.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  PlanOption _selectedPlan = PlanOption.monthly;
  final _mobileCtrl = TextEditingController();

  @override
  void dispose() {
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    await ref.read(paymentProvider.notifier).pay(
          plan: _selectedPlan,
          phoneNumber: _mobileCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final payState = ref.watch(paymentProvider);
    final subAsync = ref.watch(subscriptionProvider);

    ref.listen<PaymentState>(paymentProvider, (_, next) {
      if (next is PaymentSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('✓ Payment confirmed! ${next.plan.label} is now active.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      } else if (next is PaymentFailed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(paymentProvider.notifier).reset();
      }
    });

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
                Text('Billing & Plans', style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (payState) {
          PaymentAwaitingConfirmation() => _UssdWaitingView(
              state: payState,
              onCancel: () => ref.read(paymentProvider.notifier).reset(),
            ),
          PaymentSuccess() => _SuccessView(
              state: payState,
              onDone: () => ref.read(paymentProvider.notifier).reset(),
            ),
          _ => subAsync.when(
              loading: () => const NyLoading(fullScreen: true),
              error: (_, __) => _BillingBody(
                subscription: null,
                selectedPlan: _selectedPlan,
                mobileCtrl: _mobileCtrl,
                isLoading: payState is PaymentLoading,
                loadingMessage:
                    payState is PaymentLoading ? payState.message : null,
                onPlanSelected: (p) => setState(() => _selectedPlan = p),
                onPay: _pay,
              ),
              data: (sub) => _BillingBody(
                subscription: sub,
                selectedPlan: _selectedPlan,
                mobileCtrl: _mobileCtrl,
                isLoading: payState is PaymentLoading,
                loadingMessage:
                    payState is PaymentLoading ? payState.message : null,
                onPlanSelected: (p) => setState(() => _selectedPlan = p),
                onPay: _pay,
              ),
            ),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main billing body — aware of whether a plan is active
// ─────────────────────────────────────────────────────────────────────────────

class _BillingBody extends StatelessWidget {
  const _BillingBody({
    required this.subscription,
    required this.selectedPlan,
    required this.mobileCtrl,
    required this.isLoading,
    required this.onPlanSelected,
    required this.onPay,
    this.loadingMessage,
  });

  final SubscriptionModel? subscription;
  final PlanOption selectedPlan;
  final TextEditingController mobileCtrl;
  final bool isLoading;
  final String? loadingMessage;
  final void Function(PlanOption) onPlanSelected;
  final VoidCallback onPay;

  bool get _hasActivePlan {
    final sub = subscription;
    if (sub == null) return false;
    return (sub.status == SubscriptionStatus.active ||
            sub.status == SubscriptionStatus.trial) &&
        sub.daysLeft > 0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Active plan card (shown only when a plan is valid) ──────────
          if (_hasActivePlan) ...[
            _ActivePlanCard(sub: subscription!),
            const SizedBox(height: 20),
            // Divider with "Add a plan" label
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.cardBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'EXTEND OR ADD A PLAN',
                    style: AppTextStyles.overline,
                  ),
                ),
                Expanded(child: Divider(color: AppColors.cardBorder)),
              ],
            ),
            const SizedBox(height: 16),
          ] else ...[
            // No active plan — show normal heading
            Text(AppStrings.chooseYourPlan,
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 4),
            Text(AppStrings.billingSubtitle, style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
          ],

          // ── Plan options ────────────────────────────────────────────────
          ...PlanOption.values.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlanCard(
                  plan: plan,
                  isSelected: selectedPlan == plan,
                  onTap: () => onPlanSelected(plan),
                ),
              )),

          const SizedBox(height: 16),

          // ── Payment form ────────────────────────────────────────────────
          NyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B4D8).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.payment_rounded,
                          color: Color(0xFF00B4D8), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pay via CamPay',
                            style: AppTextStyles.titleMedium),
                        Text('MTN MoMo · Orange Money',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(AppStrings.mobileMoneyNumber,
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: '237 6XX XX XX XX',
                    prefixIcon: Icon(Icons.phone_android_rounded,
                        color: AppColors.textTertiary, size: 20),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter your MTN or Orange number. '
                  'You will receive a USSD prompt to confirm.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 20),
                NyButton(
                  label: isLoading
                      ? (loadingMessage ?? 'Processing…')
                      : '${_hasActivePlan ? 'Add' : AppStrings.pay} '
                          '${_fmtPrice(selectedPlan.priceXaf)} XAF',
                  onPressed: isLoading ? null : onPay,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security_rounded,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(AppStrings.verifiedByProvider,
                        style: AppTextStyles.labelSmall),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _fmtPrice(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '\u202F');
}

// ─────────────────────────────────────────────────────────────────────────────
// Active plan card
// ─────────────────────────────────────────────────────────────────────────────

class _ActivePlanCard extends StatelessWidget {
  const _ActivePlanCard({required this.sub});
  final SubscriptionModel sub;

  @override
  Widget build(BuildContext context) {
    final isTrial = sub.status == SubscriptionStatus.trial;
    final fmt = DateFormat('dd MMM yyyy');
    final usagePercent = sub.usagePercent;

    return NyCard(
      borderColor: AppColors.primary,
      backgroundColor: AppColors.primaryLighter,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color:
                      isTrial ? AppColors.primaryContainer : AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTrial
                          ? Icons.hourglass_top_rounded
                          : Icons.check_circle_rounded,
                      size: 13,
                      color: isTrial ? AppColors.primary : Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isTrial ? 'Free Trial' : 'Active',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isTrial ? AppColors.primary : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${sub.daysLeft} day${sub.daysLeft == 1 ? '' : 's'} left',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Plan name & dates ────────────────────────────────────────
          Text(
            isTrial ? '7-Day Free Trial' : sub.planLabel,
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${fmt.format(sub.startDate)}  →  ${fmt.format(sub.endDate)}',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          // ── Call usage bar ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Calls used', style: AppTextStyles.bodySmall),
              Text(
                '${sub.callsUsed} / ${sub.callsIncluded}',
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usagePercent,
              backgroundColor: AppColors.primaryContainer,
              color:
                  usagePercent > 0.85 ? AppColors.warning : AppColors.primary,
              minHeight: 7,
            ),
          ),

          // ── Expiry note ──────────────────────────────────────────────
          if (sub.isExpiringSoon) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: AppColors.warning),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Expires ${fmt.format(sub.endDate)} — add a plan below to avoid interruption.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USSD waiting view
// ─────────────────────────────────────────────────────────────────────────────

class _UssdWaitingView extends StatelessWidget {
  const _UssdWaitingView({required this.state, required this.onCancel});
  final PaymentAwaitingConfirmation state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: NyCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLighter,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_android_rounded,
                    color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              Text('Check your phone',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'A payment prompt has been sent to your '
                '${_operatorLabel(state.operator_)} number.\n\n'
                'Enter your PIN to confirm the payment and wait for confirmation.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text('Waiting for confirmation…', style: AppTextStyles.bodySmall),
              const SizedBox(height: 24),
              NyButton(
                label: 'Cancel',
                onPressed: onCancel,
                variant: NyButtonVariant.outlined,
                height: 44,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _operatorLabel(String op) =>
      op == 'ORANGE' ? 'Orange Money' : 'MTN MoMo';
}

// ─────────────────────────────────────────────────────────────────────────────
// Success view
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.state, required this.onDone});
  final PaymentSuccess state;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: NyCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Payment confirmed!',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                '${state.plan.label} is now active.\nRef: ${state.reference}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              NyButton(
                label: 'Back to billing',
                onPressed: onDone,
                height: 44,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan card
// ─────────────────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final PlanOption plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priceStr = _fmtPrice(plan.priceXaf);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLighter : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.label, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmt(plan.calls)} calls · ${plan.days} days',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.thenPerExtraCall,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$priceStr XAF',
              style: AppTextStyles.priceLarge.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

  String _fmtPrice(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '\u202F');
}
