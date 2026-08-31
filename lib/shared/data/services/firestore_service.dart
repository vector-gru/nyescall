import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_constants.dart';

/// Central Firestore helper. Thin wrappers so feature layers don't
/// hard-code collection paths or uid lookups.
class FirestoreService {
  FirestoreService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser?.uid ?? '';

  // ── Collections ──────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get users =>
      _db.collection(AppConstants.usersCollection);

  CollectionReference<Map<String, dynamic>> get organizations =>
      _db.collection(AppConstants.organizationsCollection);

  CollectionReference<Map<String, dynamic>> get calls =>
      _db.collection(AppConstants.callsCollection);

  CollectionReference<Map<String, dynamic>> get voices =>
      _db.collection(AppConstants.voicesCollection);

  CollectionReference<Map<String, dynamic>> get subscriptions =>
      _db.collection(AppConstants.subscriptionsCollection);

  CollectionReference<Map<String, dynamic>> get staff =>
      _db.collection(AppConstants.staffCollection);

  CollectionReference<Map<String, dynamic>> get payments =>
      _db.collection(AppConstants.paymentsCollection);

  // ── User profile ─────────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> get currentUserDoc =>
      users.doc(_uid);

  /// Creates or merges the user profile on first sign-in.
  Future<void> upsertUserProfile({
    required String email,
    String? displayName,
    String accountType = AppConstants.accountTypeIndividual,
  }) async {
    await currentUserDoc.set(
      {
        'uid': _uid,
        'email': email,
        if (displayName != null) 'displayName': displayName,
        'accountType': accountType,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final doc = await currentUserDoc.get();
    return doc.data();
  }

  // ── Subscriptions ─────────────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> activeSubscriptionStream() =>
      subscriptions
          .where('userId', isEqualTo: _uid)
          .orderBy('startDate', descending: true)
          .limit(1)
          .snapshots();

  Future<void> createTrialSubscription() async {
    final now = DateTime.now();
    await subscriptions.add({
      'userId': _uid,
      'plan': 'monthly',
      'status': 'trial',
      'callsIncluded': AppConstants.trialCallsIncluded,
      'callsUsed': 0,
      'extraCalls': 0,
      'overageDueXaf': 0,
      'startDate': Timestamp.fromDate(now),
      'endDate': Timestamp.fromDate(
          now.add(Duration(days: AppConstants.trialDurationDays))),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementCallsUsed(String subscriptionId) async {
    await subscriptions.doc(subscriptionId).update({
      'callsUsed': FieldValue.increment(1),
    });
  }

  // ── Calls ─────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> callHistoryStream({
    int limit = 20,
  }) =>
      calls
          .where('userId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots();

  Future<DocumentReference<Map<String, dynamic>>> logCall(
      Map<String, dynamic> data) =>
      calls.add({...data, 'userId': _uid, 'createdAt': FieldValue.serverTimestamp()});

  Future<void> updateCallStatus(String callId, String status,
      {int? durationSeconds, String? transcript}) async {
    await calls.doc(callId).update({
      'status': status,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      if (transcript != null) 'transcript': transcript,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Voices ────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> voicesStream() =>
      voices
          .where('userId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .snapshots();

  Future<DocumentReference<Map<String, dynamic>>> addVoice(
      Map<String, dynamic> data) =>
      voices.add({...data, 'userId': _uid, 'createdAt': FieldValue.serverTimestamp()});

  Future<void> deleteVoice(String voiceId) async =>
      voices.doc(voiceId).delete();

  Future<void> setDefaultVoice(String voiceId) async {
    // Clear any existing default first.
    final snap = await voices.where('userId', isEqualTo: _uid)
        .where('isDefault', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    batch.update(voices.doc(voiceId), {'isDefault': true});
    await batch.commit();
  }

  // ── Organizations ─────────────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> organizationStream() =>
      organizations
          .where('ownerId', isEqualTo: _uid)
          .limit(1)
          .snapshots();

  Future<DocumentReference<Map<String, dynamic>>> createOrganization(
      Map<String, dynamic> data) =>
      organizations.add({
        ...data,
        'ownerId': _uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> updateOrganization(
      String orgId, Map<String, dynamic> data) async =>
      organizations.doc(orgId).update(
          {...data, 'updatedAt': FieldValue.serverTimestamp()});

  // ── Staff ─────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> staffStream(String orgId) =>
      staff
          .where('orgId', isEqualTo: orgId)
          .orderBy('createdAt', descending: true)
          .snapshots();

  Future<DocumentReference<Map<String, dynamic>>> registerStaff(
      Map<String, dynamic> data) =>
      staff.add({...data, 'createdAt': FieldValue.serverTimestamp()});

  Future<int> staffCount(String orgId) async {
    final snap = await staff
        .where('orgId', isEqualTo: orgId)
        .count()
        .get();
    return snap.count ?? 0;
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> paymentsStream() =>
      payments
          .where('userId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .snapshots();

  Future<DocumentReference<Map<String, dynamic>>> submitPayment(
      Map<String, dynamic> data) =>
      payments.add({
        ...data,
        'userId': _uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
}
