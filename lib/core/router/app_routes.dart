/// Named route paths used throughout the app.
abstract final class AppRoutes {
  // ── Auth / onboarding ────────────────────────────────────────────────────
  static const String onboarding = '/onboarding';
  static const String landing = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String emailConfirmation = '/email-confirmation';

  // ── Main shell (bottom nav) ───────────────────────────────────────────────
  static const String home = '/home';
  static const String call = '/call';
  static const String voices = '/voices';
  static const String billing = '/billing';
  static const String staff = '/staff';

  // ── Nested ────────────────────────────────────────────────────────────────
  static const String organization = '/home/organization';
  static const String callHistory = '/call/history';
  static const String addVoice = '/voices/add';
  static const String choosePlan = '/billing/choose-plan';
}
