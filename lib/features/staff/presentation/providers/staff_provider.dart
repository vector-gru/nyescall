import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/staff_model.dart';

/// Streams the staff list for a given org.
final staffListProvider =
    StreamProvider.family<List<StaffModel>, String>((ref, orgId) {
  if (orgId.isEmpty) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('staff')
      .where('orgId', isEqualTo: orgId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(StaffModel.fromFirestore).toList());
});

// ── Register staff notifier ────────────────────────────────────────────────

sealed class RegisterStaffState { const RegisterStaffState(); }
final class RegisterStaffIdle extends RegisterStaffState { const RegisterStaffIdle(); }
final class RegisterStaffLoading extends RegisterStaffState { const RegisterStaffLoading(); }
final class RegisterStaffSuccess extends RegisterStaffState {
  const RegisterStaffSuccess(this.staffCode);
  final String staffCode;
}
final class RegisterStaffError extends RegisterStaffState {
  const RegisterStaffError(this.message);
  final String message;
}

class RegisterStaffNotifier extends StateNotifier<RegisterStaffState> {
  RegisterStaffNotifier() : super(const RegisterStaffIdle());

  Future<void> register({
    required String orgId,
    required String orgCode,
    required String fullName,
    required String department,
    required String deptCode,
    required String position,
    required String phone,
    required String email,
    required String employeeNo,
    required String branch,
    DateTime? dateOfBirth,
    DateTime? dateEmployed,
    DateTime? cardValidUntil,
    String? photoUrl,
  }) async {
    if (fullName.trim().isEmpty) {
      state = const RegisterStaffError('Full name is required.');
      return;
    }
    state = const RegisterStaffLoading();
    try {
      // Generate staff code: ORGCODE-DEPTCODE-NNNN
      final countSnap = await FirebaseFirestore.instance
          .collection('staff')
          .where('orgId', isEqualTo: orgId)
          .count()
          .get();
      final seq = ((countSnap.count ?? 0) + 1).toString().padLeft(4, '0');
      final staffCode = '$orgCode-$deptCode-$seq';

      final model = StaffModel(
        id: '',
        orgId: orgId,
        fullName: fullName.trim(),
        department: department,
        position: position.trim(),
        phone: phone.trim(),
        email: email.trim(),
        employeeNo: employeeNo.trim(),
        branch: branch.trim(),
        staffCode: staffCode,
        createdAt: DateTime.now(),
        dateOfBirth: dateOfBirth,
        dateEmployed: dateEmployed,
        cardValidUntil: cardValidUntil,
        photoUrl: photoUrl,
      );

      await FirebaseFirestore.instance.collection('staff').add(model.toFirestore());
      state = RegisterStaffSuccess(staffCode);
    } catch (e) {
      state = RegisterStaffError('$e');
    }
  }

  void reset() => state = const RegisterStaffIdle();
}

final registerStaffProvider =
    StateNotifierProvider<RegisterStaffNotifier, RegisterStaffState>(
  (_) => RegisterStaffNotifier(),
);
