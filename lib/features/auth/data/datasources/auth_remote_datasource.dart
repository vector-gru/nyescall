import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/app_exception.dart';

/// Wraps Firebase Auth + Google Sign-In calls.
class AuthRemoteDatasource {
  AuthRemoteDatasource({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email + password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseCode(e.code));
    }
  }

  /// Create account with email + password and send a verification email.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.sendEmailVerification();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseCode(e.code));
    }
  }

  /// Sign in / sign up with Google OAuth.
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const AuthException('Google sign-in cancelled.');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseCode(e.code));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  /// Send a password reset email.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseCode(e.code));
    }
  }

  /// Reload the current user and return whether email is now verified.
  Future<bool> reloadAndCheckVerification() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  String _mapFirebaseCode(String code) => switch (code) {
        'user-not-found' => 'No account found with that email.',
        'wrong-password' => 'Incorrect password.',
        'email-already-in-use' => 'An account already exists for that email.',
        'invalid-email' => 'Please enter a valid email address.',
        'weak-password' => 'Password must be at least 6 characters.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'network-request-failed' => 'Network error. Check your connection.',
        'user-disabled' => 'This account has been disabled.',
        _ => 'Authentication error. Please try again.',
      };
}
