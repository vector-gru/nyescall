// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'authstate_hash_placeholder';

/// Streams the current Firebase [User] (null when signed out).
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;

String _$currentUserHash() => r'currentuser_hash_placeholder';

/// Convenience: synchronous current user.
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRef = AutoDisposeProviderRef<User?>;

String _$isEmailVerifiedHash() => r'isemailverified_hash_placeholder';

/// Whether the signed-in user's email has been verified.
///
/// Copied from [isEmailVerified].
@ProviderFor(isEmailVerified)
final isEmailVerifiedProvider = AutoDisposeProvider<bool>.internal(
  isEmailVerified,
  name: r'isEmailVerifiedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isEmailVerifiedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsEmailVerifiedRef = AutoDisposeProviderRef<bool>;
