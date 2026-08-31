import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlan { monthly, sixMonths, yearly }

enum SubscriptionStatus { trial, active, expired, cancelled }

class SubscriptionModel {
  const SubscriptionModel({
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.callsIncluded,
    required this.callsUsed,
    required this.extraCalls,
    required this.overageDueXaf,
  });

  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final int callsIncluded;
  final int callsUsed;
  final int extraCalls;
  final int overageDueXaf;

  int get daysLeft => endDate.difference(DateTime.now()).inDays.clamp(0, 9999);
  bool get isExpiringSoon => daysLeft <= 5;
  double get usagePercent =>
      callsIncluded == 0 ? 0 : (callsUsed / callsIncluded).clamp(0.0, 1.0);

  String get planLabel => switch (plan) {
        SubscriptionPlan.monthly => 'Monthly',
        SubscriptionPlan.sixMonths => '6 Months',
        SubscriptionPlan.yearly => 'Yearly',
      };

  String get statusLabel => switch (status) {
        SubscriptionStatus.trial => 'Trial',
        SubscriptionStatus.active => 'Active',
        SubscriptionStatus.expired => 'Expired',
        SubscriptionStatus.cancelled => 'Cancelled',
      };

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      plan: SubscriptionPlan.values.firstWhere(
        (p) => p.name == (d['plan'] as String? ?? 'monthly'),
        orElse: () => SubscriptionPlan.monthly,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (s) => s.name == (d['status'] as String? ?? 'trial'),
        orElse: () => SubscriptionStatus.trial,
      ),
      startDate: (d['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (d['endDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 7)),
      callsIncluded: (d['callsIncluded'] as int?) ?? 20,
      callsUsed: (d['callsUsed'] as int?) ?? 0,
      extraCalls: (d['extraCalls'] as int?) ?? 0,
      overageDueXaf: (d['overageDueXaf'] as int?) ?? 0,
    );
  }

  /// Placeholder used while loading.
  factory SubscriptionModel.trial() => SubscriptionModel(
        plan: SubscriptionPlan.monthly,
        status: SubscriptionStatus.trial,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        callsIncluded: 25,
        callsUsed: 0,
        extraCalls: 0,
        overageDueXaf: 0,
      );
}
