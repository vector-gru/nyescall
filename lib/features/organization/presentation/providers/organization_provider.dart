import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/organization_model.dart';

final organizationProvider = StreamProvider<OrganizationModel?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('organizations')
      .where('ownerId', isEqualTo: uid)
      .limit(1)
      .snapshots()
      .map((s) =>
          s.docs.isEmpty ? null : OrganizationModel.fromFirestore(s.docs.first));
});

// ── Save org notifier ──────────────────────────────────────────────────────

sealed class SaveOrgState { const SaveOrgState(); }
final class SaveOrgIdle extends SaveOrgState { const SaveOrgIdle(); }
final class SaveOrgLoading extends SaveOrgState { const SaveOrgLoading(); }
final class SaveOrgSuccess extends SaveOrgState { const SaveOrgSuccess(); }
final class SaveOrgError extends SaveOrgState {
  const SaveOrgError(this.message);
  final String message;
}

class SaveOrgNotifier extends StateNotifier<SaveOrgState> {
  SaveOrgNotifier() : super(const SaveOrgIdle());

  Future<void> save(OrganizationModel org) async {
    state = const SaveOrgLoading();
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated.');

      final col = FirebaseFirestore.instance.collection('organizations');

      if (org.id.isEmpty) {
        await col.add(org.copyWith().toFirestore()..['ownerId'] = uid);
      } else {
        await col.doc(org.id).update(org.toFirestore());
      }
      state = const SaveOrgSuccess();
    } catch (e) {
      state = SaveOrgError('$e');
    }
  }

  void reset() => state = const SaveOrgIdle();
}

final saveOrgProvider =
    StateNotifierProvider<SaveOrgNotifier, SaveOrgState>(
  (_) => SaveOrgNotifier(),
);
