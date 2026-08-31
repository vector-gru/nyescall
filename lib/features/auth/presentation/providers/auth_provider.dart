import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

/// Streams the current Firebase [User] (null when signed out).
@riverpod
Stream<User?> authState(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
}

/// Convenience: synchronous current user.
@riverpod
User? currentUser(Ref ref) {
  return ref.watch(authStateProvider).valueOrNull;
}

/// Whether the signed-in user's email has been verified.
@riverpod
bool isEmailVerified(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified ?? false;
}
