import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../../../core/errors/app_exception.dart';

/// The state of an auth action (sign in / sign up / Google).
sealed class AuthActionState {
  const AuthActionState();
}

final class AuthActionIdle extends AuthActionState {
  const AuthActionIdle();
}

final class AuthActionLoading extends AuthActionState {
  const AuthActionLoading();
}

final class AuthActionSuccess extends AuthActionState {
  const AuthActionSuccess({this.emailSent = false});
  final bool emailSent;
}

final class AuthActionError extends AuthActionState {
  const AuthActionError(this.message);
  final String message;
}

/// Provider for the datasource (allows injection in tests).
final authDatasourceProvider = Provider<AuthRemoteDatasource>(
  (_) => AuthRemoteDatasource(),
);

/// Drives all auth actions from the UI.
class AuthNotifier extends StateNotifier<AuthActionState> {
  AuthNotifier(this._ds) : super(const AuthActionIdle());

  final AuthRemoteDatasource _ds;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthActionLoading();
    try {
      await _ds.signInWithEmail(email: email, password: password);
      state = const AuthActionSuccess();
    } on AuthException catch (e) {
      state = AuthActionError(e.message);
    } catch (_) {
      state = const AuthActionError('Something went wrong. Please try again.');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String accountType = 'individual',
  }) async {
    state = const AuthActionLoading();
    try {
      final credential =
          await _ds.signUpWithEmail(email: email, password: password);

      // Write the user profile so accountType is available across the app.
      final uid = credential.user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'email': email.trim(),
          'accountType': accountType,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      state = const AuthActionSuccess(emailSent: true);
    } on AuthException catch (e) {
      state = AuthActionError(e.message);
    } catch (_) {
      state = const AuthActionError('Something went wrong. Please try again.');
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthActionLoading();
    try {
      await _ds.signInWithGoogle();
      state = const AuthActionSuccess();
    } on AuthException catch (e) {
      state = AuthActionError(e.message);
    } catch (_) {
      state = const AuthActionError('Google sign-in failed. Please try again.');
    }
  }

  Future<void> signOut() async {
    await _ds.signOut();
    state = const AuthActionIdle();
  }

  void reset() => state = const AuthActionIdle();
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthActionState>(
  (ref) => AuthNotifier(ref.watch(authDatasourceProvider)),
);
