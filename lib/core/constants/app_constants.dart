/// Global app-wide constants.
library;

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'NYESCALL';
  static const String appTagline = 'AI outbound calls, in any language';
  static const String appBundleId = 'com.hifivetech.nyescall';

  // Bland AI
  static const String blandAiBaseUrl = 'https://api.bland.ai/v1';
  static const String blandAiCallsEndpoint = '/calls';
  static const String blandAiVoicesEndpoint = '/voices';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String organizationsCollection = 'organizations';
  static const String callsCollection = 'calls';
  static const String voicesCollection = 'voices';
  static const String subscriptionsCollection = 'subscriptions';
  static const String staffCollection = 'staff';
  static const String paymentsCollection = 'payments';

  // Shared preferences keys
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefThemeMode = 'theme_mode';

  // Trial
  static const int trialCallsIncluded = 20;
  static const int trialDurationDays = 7;

  // Subscription pricing (XAF)
  static const int monthlyPrice = 23500;
  static const int sixMonthsPrice = 100000;
  static const int yearlyPrice = 92000;
  static const int overagePricePerCall = 25;

  // Subscription call quotas
  static const int monthlyCallsIncluded = 1000;
  static const int sixMonthsCallsIncluded = 6000;
  static const int yearlyCallsIncluded = 12000;

  // Supported languages (12 languages)
  static const List<String> supportedLanguages = [
    'English',
    'French',
    'Arabic',
    'Swahili',
    'Hausa',
    'Yoruba',
    'Amharic',
    'Wolof',
    'Fulani',
    'Lingala',
    'Portuguese',
    'Spanish',
  ];

  // Voice tone options
  static const List<String> voiceTones = [
    'Professional',
    'Friendly',
    'Formal',
    'Casual',
    'Empathetic',
  ];

  // Speaking speed options
  static const List<String> speakingSpeeds = [
    'Slow',
    'Normal',
    'Fast',
  ];

  // Account types
  static const String accountTypeIndividual = 'individual';
  static const String accountTypeOrganization = 'organization';

  // Organisation roles
  static const String roleOwner = 'owner';
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleAgent = 'agent';

  // Payment methods
  static const String paymentMtnMomo = 'mtn_momo';
  static const String paymentOrangeMoney = 'orange_money';
  static const String paymentBankTransfer = 'bank_transfer';

  // Call reasons max length
  static const int callReasonMaxLength = 2000;
}
