import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/subscription_model.dart';

/// Streams the current user's profile document from Firestore.
/// Returns null if no profile exists yet — handles permission errors gracefully.
final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? doc.data() : null)
      .handleError((_) => null);
});

/// Convenience: resolves the account type from the user profile.
/// Defaults to 'individual' if the profile hasn't been written yet.
final accountTypeProvider = Provider<String>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return profile?['accountType'] as String? ??
      AppConstants.accountTypeIndividual;
});

/// True when the current user signed up as an organisation.
final isOrgAccountProvider = Provider<bool>((ref) {
  return ref.watch(accountTypeProvider) == AppConstants.accountTypeOrganization;
});

/// Streams the current user's active subscription document.
/// Falls back to a trial model if no subscription exists yet.
final subscriptionProvider = StreamProvider<SubscriptionModel>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(SubscriptionModel.trial());

  return FirebaseFirestore.instance
      .collection('subscriptions')
      .where('userId', isEqualTo: uid)
      .orderBy('startDate', descending: true)
      .limit(1)
      .snapshots()
      .map((snap) => snap.docs.isEmpty
          ? SubscriptionModel.trial()
          : SubscriptionModel.fromFirestore(snap.docs.first))
      .handleError((_) => SubscriptionModel.trial());
});

/// Payment history for the current user.
final paymentHistoryProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('payments')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()..['id'] = d.id).toList())
      .handleError((_) => <Map<String, dynamic>>[]);
});
