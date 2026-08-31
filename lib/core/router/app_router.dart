import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/landing_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/email_confirmation_screen.dart';
import '../../features/billing/presentation/screens/billing_screen.dart';
import '../../features/call/presentation/screens/call_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/organization/presentation/screens/organization_screen.dart';
import '../../features/staff/presentation/screens/staff_screen.dart';
import '../../features/voices/presentation/screens/voices_screen.dart';
import '../theme/app_colors.dart';
import 'app_routes.dart';
import 'main_shell.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.landing,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      return authState.when(
        data: (user) {
          final isLoggedIn = user != null;
          final isOnAuthRoute = state.matchedLocation == AppRoutes.landing ||
              state.matchedLocation == AppRoutes.signIn ||
              state.matchedLocation == AppRoutes.signUp ||
              state.matchedLocation == AppRoutes.emailConfirmation;

          if (!isLoggedIn && !isOnAuthRoute) return AppRoutes.landing;
          if (isLoggedIn && isOnAuthRoute) return AppRoutes.home;
          return null;
        },
        loading: () => null,
        error: (_, __) => AppRoutes.landing,
      );
    },
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    routes: [
      // ── Auth routes (no shell) ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.landing,
        builder: (_, __) => const LandingScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailConfirmation,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailConfirmationScreen(email: email);
        },
      ),

      // ── Main shell with bottom navigation ──────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'organization',
                builder: (_, __) => const OrganizationScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.call,
            builder: (_, __) => const CallScreen(),
          ),
          GoRoute(
            path: AppRoutes.voices,
            builder: (_, __) => const VoicesScreen(),
          ),
          GoRoute(
            path: AppRoutes.billing,
            builder: (_, __) => const BillingScreen(),
          ),
          GoRoute(
            path: AppRoutes.staff,
            builder: (_, __) => const StaffScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}

/// Bridges a Stream to a [Listenable] so GoRouter can react to auth changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    // ignore: avoid_dynamic_calls
    _subscription.cancel();
    super.dispose();
  }
}
