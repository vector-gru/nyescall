import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/widgets.dart';
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

    ref.listen<PaymentState>(paymentProvider, (_, next) {
      if (next is PaymentSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            '✓ Payment confirmed! ${next.plan.label} is now active.',
          ),
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
                Text('Nyescall Center', style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: payState is PaymentAwaitingConfirmation
            ? _UssdWaitingView(
                state: payState,
                onCancel: () => ref.read(paymentProvider.notifier).reset(),
              )
            : payState is PaymentSuccess
                ? _SuccessView(state: payState)
                : _PaymentForm(
                    selectedPlan: _selectedPlan,
                    mobileCtrl: _mobileCtrl,
                    isLoading: payState is PaymentLoading,
                    loadingMessage:
                        payState is PaymentLoading ? payState.message : null,
                    onPlanSelected: (p) => setState(() => _selectedPlan = p),
                    onPay: _pay,
                  ),
      ),
    );
  }
}

// ── Payment form ───────────────────────────────────────────────────────────

class _PaymentForm extends StatelessWidget {
  const _PaymentForm({
    required this.selectedPlan,
    required this.mobileCtrl,
    required this.isLoading,
    required this.onPlanSelected,
    required this.onPay,
    this.loadingMessage,
  });

  final PlanOption selectedPlan;
  final TextEditingController mobileCtrl;
  final bool isLoading;
  final String? loadingMessage;
  final void Function(PlanOption) onPlanSelected;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.chooseYourPlan, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(AppStrings.billingSubtitle, style: AppTextStyles.bodySmall),
          const SizedBox(height: 16),

          // ── Plan options ────────────────────────────────────────────
          ...PlanOption.values.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlanCard(
                  plan: plan,
                  isSelected: selectedPlan == plan,
                  onTap: () => onPlanSelected(plan),
                ),
              )),

          const SizedBox(height: 16),

          // ── Mobile money input ──────────────────────────────────────
          NyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CamPay logo row
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B4D8).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.payment_rounded,
                        color: Color(0xFF00B4D8),
                        size: 20,
                      ),
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
                      : '${AppStrings.pay} '
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

// ── USSD waiting view ──────────────────────────────────────────────────────

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
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_android_rounded,
                    color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'Check your phone',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'A payment prompt has been sent to your '
                '${state.operator_} number.\n\n'
                'Enter your PIN to confirm the payment of '
                '${_operatorLabel(state.operator_)} '
                'and wait for confirmation.',
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
              Text(
                'Waiting for confirmation…',
                style: AppTextStyles.bodySmall,
              ),
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

// ── Success view ───────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.state});
  final PaymentSuccess state;

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
                '${state.plan.label} is now active.\n'
                'Reference: ${state.reference}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Plan card ──────────────────────────────────────────────────────────────

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
    final priceStr = plan.priceXaf
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '\u202F');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            Row(
              children: [
                Text('$priceStr XAF', style: AppTextStyles.priceLarge),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 20),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}
