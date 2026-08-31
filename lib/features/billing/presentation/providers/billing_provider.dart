import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/data/services/campay_service.dart';
import '../../../../shared/data/services/firestore_service.dart';
import '../../../../shared/presentation/providers/service_providers.dart';

// ── Plan options ───────────────────────────────────────────────────────────

enum PlanOption { monthly, sixMonths, yearly }

extension PlanOptionX on PlanOption {
  String get label => switch (this) {
        PlanOption.monthly => 'NYESCALL Monthly',
        PlanOption.sixMonths => 'NYESCALL 6 Months',
        PlanOption.yearly => 'NYESCALL Yearly',
      };

  int get priceXaf => switch (this) {
        PlanOption.monthly => AppConstants.monthlyPrice,
        PlanOption.sixMonths => AppConstants.sixMonthsPrice,
        PlanOption.yearly => AppConstants.yearlyPrice,
      };

  int get calls => switch (this) {
        PlanOption.monthly => AppConstants.monthlyCallsIncluded,
        PlanOption.sixMonths => AppConstants.sixMonthsCallsIncluded,
        PlanOption.yearly => AppConstants.yearlyCallsIncluded,
      };

  int get days => switch (this) {
        PlanOption.monthly => 30,
        PlanOption.sixMonths => 180,
        PlanOption.yearly => 365,
      };
}

// ── Payment state ──────────────────────────────────────────────────────────

sealed class PaymentState {
  const PaymentState();
}

final class PaymentIdle extends PaymentState {
  const PaymentIdle();
}

final class PaymentLoading extends PaymentState {
  const PaymentLoading(this.message);

  /// Human-readable progress step shown in the UI.
  final String message;
}

/// CamPay returned a reference; user needs to confirm the USSD prompt.
final class PaymentAwaitingConfirmation extends PaymentState {
  const PaymentAwaitingConfirmation({
    required this.reference,
    required this.ussdCode,
    required this.operator_,
  });
  final String reference;
  final String ussdCode; // shown to the user so they know what to expect
  final String operator_; // 'MTN' or 'ORANGE'
}

final class PaymentSuccess extends PaymentState {
  const PaymentSuccess({required this.plan, required this.reference});
  final PlanOption plan;
  final String reference;
}

final class PaymentFailed extends PaymentState {
  const PaymentFailed(this.message);
  final String message;
}

// ── Notifier ───────────────────────────────────────────────────────────────

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier({
    required CamPayService camPay,
    required FirestoreService firestore,
  })  : _camPay = camPay,
        _firestore = firestore,
        super(const PaymentIdle());

  final CamPayService _camPay;
  final FirestoreService _firestore;
  Timer? _pollTimer;
  int _pollCount = 0;
  static const _maxPolls = 24; // 24 × 5s = 2 minutes max

  // ── Initiate ──────────────────────────────────────────────────────────────

  Future<void> pay({
    required PlanOption plan,
    required String phoneNumber, // e.g. '237678509520' or '678509520'
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = const PaymentFailed('You must be signed in to make a payment.');
      return;
    }

    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) {
      state = const PaymentFailed('Enter your mobile money number.');
      return;
    }

    state = const PaymentLoading('Connecting to CamPay…');

    try {
      // Step 1 — get an access token
      await _camPay.getToken();

      state = const PaymentLoading('Sending payment request…');

      // Step 2 — initiate the collection
      // In sandbox mode CamPay caps transactions at 25 XAF; the real plan
      // amount is still recorded in Firestore so everything else behaves
      // as if the full amount was paid. Flip AppConstants.campayUseSandboxAmount
      // to false before going to production.
      final chargeAmount = AppConstants.campayUseSandboxAmount
          ? AppConstants.campayMaxSandboxAmount
          : plan.priceXaf;
      final result = await _camPay.collect(
        amount: chargeAmount.toString(),
        from: trimmed,
        description: 'NYESCALL ${plan.label} subscription',
      );

      // Step 3 — log a pending payment record in Firestore
      final docRef = await _firestore.submitPayment({
        'userId': uid,
        'plan': plan.name,
        'amountXaf': plan.priceXaf,
        'provider': 'campay',
        'phoneNumber': trimmed,
        'camPayReference': result.reference,
        'status': 'pending',
      });

      // Step 4 — notify the UI to show USSD waiting screen
      state = PaymentAwaitingConfirmation(
        reference: result.reference,
        ussdCode: result.ussdCode,
        operator_: _detectOperator(trimmed),
      );

      // Step 5 — start polling for the final status
      _startPolling(
        reference: result.reference,
        firestoreDocId: docRef.id,
        plan: plan,
      );
    } catch (e) {
      state = PaymentFailed(e.toString());
    }
  }

  // ── Polling ────────────────────────────────────────────────────────────────

  void _startPolling({
    required String reference,
    required String firestoreDocId,
    required PlanOption plan,
  }) {
    _pollCount = 0;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      _pollCount++;
      if (_pollCount > _maxPolls) {
        _pollTimer?.cancel();
        state = const PaymentFailed(
          'Payment timed out. Please check your mobile money app and try again.',
        );
        return;
      }

      try {
        final status = await _camPay.checkStatus(reference);

        if (status.isSuccessful) {
          _pollTimer?.cancel();
          // Update Firestore record
          await FirebaseFirestore.instance
              .collection('payments')
              .doc(firestoreDocId)
              .update({
            'status': 'successful',
            'operator': status.operator_,
            'confirmedAt': FieldValue.serverTimestamp(),
          });
          // Activate the subscription
          await _activateSubscription(plan: plan);
          state = PaymentSuccess(plan: plan, reference: reference);
        } else if (status.isFailed) {
          _pollTimer?.cancel();
          await FirebaseFirestore.instance
              .collection('payments')
              .doc(firestoreDocId)
              .update({'status': 'failed'});
          state = const PaymentFailed(
            'Payment was declined. Please check your balance and try again.',
          );
        }
        // still PENDING — keep polling
      } catch (_) {
        // Network hiccup — keep polling silently
      }
    });
  }

  /// Creates or renews a subscription document when payment is confirmed.
  Future<void> _activateSubscription({required PlanOption plan}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final end = now.add(Duration(days: plan.days));

    await FirebaseFirestore.instance.collection('subscriptions').add({
      'userId': uid,
      'plan': plan.name,
      'status': 'active',
      'callsIncluded': plan.calls,
      'callsUsed': 0,
      'extraCalls': 0,
      'overageDueXaf': 0,
      'startDate': Timestamp.fromDate(now),
      'endDate': Timestamp.fromDate(end),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void reset() {
    _pollTimer?.cancel();
    state = const PaymentIdle();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Detects MTN vs Orange from the phone number prefix (Cameroon).
  String _detectOperator(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final local = digits.startsWith('237') ? digits.substring(3) : digits;
    // MTN Cameroon prefixes: 67x, 68x, 650-659
    // Orange Cameroon prefixes: 69x, 655-659
    if (RegExp(r'^6[78]').hasMatch(local)) return 'MTN';
    if (RegExp(r'^69').hasMatch(local)) return 'ORANGE';
    return 'MTN'; // default
  }
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(
    camPay: ref.watch(camPayServiceProvider),
    firestore: ref.watch(firestoreServiceProvider),
  );
});

// Keep the old name as an alias so billing_screen.dart compiles unchanged
// until we update it below.
typedef SubmitPaymentState = PaymentState;
typedef SubmitPaymentIdle = PaymentIdle;
typedef SubmitPaymentLoading = PaymentLoading;
typedef SubmitPaymentSuccess = PaymentSuccess;
typedef SubmitPaymentError = PaymentFailed;
final submitPaymentProvider = paymentProvider;
