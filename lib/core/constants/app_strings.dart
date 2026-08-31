/// Localizable UI strings — centralised so they're easy to extract later.
library;

class AppStrings {
  AppStrings._();

  // ── Onboarding ───────────────────────────────────────────────────────────
  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingGetStarted = 'Get started';

  static const String onboarding1Title = 'AI calls in any language';
  static const String onboarding1Body =
      'NYESCALL dials out on your behalf and holds the full conversation — '
      'reminders, confirmations, follow-ups — in the language your contact speaks.';

  static const String onboarding2Title = 'Your voice, your words';
  static const String onboarding2Body =
      'Upload or record your own voice sample. Set the tone, speed and '
      'language, then let the AI carry it naturally across every call.';

  static const String onboarding3Title = '7 days free, no card needed';
  static const String onboarding3Body =
      'Start your trial instantly — 20 included calls, full access to all '
      'features, and local payment options when you\'re ready to subscribe.';

  // Landing
  static const String landingHeadline =
      'Let AI make your calls — in the language your customer speaks.';
  static const String landingSubtitle =
      'Enter a name, number, language and the reason for the call. '
      'NYESCALL dials out and handles the conversation. Reminders, confirmations, follow-ups.';
  static const String feature12Languages = '12 languages, 90+ countries';
  static const String feature12LanguagesDesc =
      'Every African country plus major international dial codes.';
  static const String featureSubscription = 'Subscription + fair overage';
  static const String featureSubscriptionDesc =
      'Included calls each cycle, then only 25 XAF per extra call.';
  static const String featureLocalPayments = 'Local payments';
  static const String featureLocalPaymentsDesc =
      'MTN MoMo, Orange Money or bank transfer — confirmed by our team.';
  static const String startFreeTrial = 'Start 7-day free trial';
  static const String alreadyHaveAccount = 'I already have an account';
  static const String poweredBy = 'Powered by AI';
  static const String pricesInXaf = 'Prices in XAF';

  // Auth
  static const String welcomeBack = 'Welcome back';
  static const String trialIncluded = '7-day free trial · 20 calls included';
  static const String email = 'Email';
  static const String emailHint = 'you@company.com';
  static const String password = 'Password';
  static const String signIn = 'Sign in';
  static const String continueWithGoogle = 'Continue with Google';
  static const String newHereCreateAccount = 'New here? Create an account';
  static const String alreadyHaveAccountSignIn =
      'Already have an account? Sign in';

  static const String createYourAccount = 'Create your account';
  static const String step1AccountType = 'Step 1 — Account type';
  static const String individual = 'INDIVIDUAL';
  static const String individualDesc =
      'Personal calls, your own voice and usage.';
  static const String organization = 'ORGANIZATION';
  static const String organizationDesc =
      'Institution profile, staff IDs and team roles.';
  static const String chooseAccountTypeNote =
      'Choose how you will use NYESCALL. This cannot be changed later.';
  static const String startFreeTrial2 = 'Start free trial';

  static const String confirmYourEmail = 'Confirm your email';
  static const String confirmEmailDesc =
      'We sent a confirmation link to your email. Click it to activate your 7-day trial, then sign in.';
  static const String backToSignIn = 'Back to sign in';
  static const String backToHome = 'Back to home';

  // Home / Dashboard
  static const String organizationSetupPending = 'Organization setup pending';
  static const String finishInstitutionProfile =
      'Finish your institution profile to add staff.';
  static const String subscription = 'SUBSCRIPTION';
  static const String trial = 'Trial';
  static const String callsUsed = 'Calls used';
  static const String extraCalls = 'Extra calls';
  static const String overageDue = 'Overage due';
  static const String placeAnAiCall = 'Place an AI call';
  static const String renewalHistory = 'RENEWAL HISTORY';
  static const String payments = 'PAYMENTS';
  static const String noPaymentsYet = 'No payments submitted yet.';
  static const String planExpires = 'Your plan expires in';
  static const String renewBefore = 'Renew before';
  static const String toAvoidInterruption = 'to avoid interruption.';
  static const String renew = 'Renew';
  static const String days = 'days';

  // Call screen
  static const String recipientName = 'Recipient name';
  static const String recipientNameHint = 'e.g. Jane Cooper';
  static const String phoneNumber = 'Phone number';
  static const String language = 'Language';
  static const String reasonForCall = 'Reason for the call';
  static const String reasonForCallHint =
      "Remind them about tomorrow's dentist appointment at 3pm and confirm they can make it.";
  static const String placeAiCall = 'Place AI call';

  // Voices
  static const String voiceForYourCall = 'Voice for your call';
  static const String defaultVoiceNotSet = 'Default voice: Not set';
  static const String speakingSpeed = 'Speaking speed';
  static const String voiceTone = 'Voice tone';
  static const String speedToneNote =
      'Speed and tone are delivered as spoken-style guidance to the AI agent on each call.';
  static const String myVoice = 'My voice';
  static const String aiMale = 'AI male';
  static const String aiFemale = 'AI female';
  static const String other = 'Other';
  static const String addANewVoice = 'Add a new voice';
  static const String addVoiceNote =
      'Record or upload a clear voice sample in a quiet environment.';
  static const String voiceName = 'Voice name';
  static const String voiceNameHint = 'My Professional Voice';
  static const String recordSample = 'Record sample';
  static const String uploadAudio = 'Upload audio';
  static const String voiceOwnershipConsent =
      'I confirm that I own this voice or have permission to use it, and I authorize NYESCALL to process it for voice generation and calling.';
  static const String saveVoice = 'Save voice';
  static const String recordingsPrivacyNote =
      'Recordings are stored privately, are only accessible to you, and are deleted permanently when you delete the voice.';
  static const String myVoices = 'My voices';
  static const String noVoicesYet = 'You haven\'t added a voice yet.';

  // Billing
  static const String chooseYourPlan = 'Choose your plan';
  static const String billingSubtitle =
      'Subscription + fair overage. Extra calls billed only when you exceed your bundle.';
  static const String monthly = 'Monthly';
  static const String sixMonths = '6 months';
  static const String yearly = 'Yearly';
  static const String callsIncluded = 'calls included';
  static const String thenPerExtraCall = 'Then 25 XAF per extra call';
  static const String mtnMomo = 'MTN MoMo';
  static const String orangeMoney = 'Orange Money';
  static const String bankTransfer = 'Bank transfer';
  static const String mobileMoneyNumber = 'Mobile Money number';
  static const String mobileMoneyHint = '237 6XX XX XX XX';
  static const String pay = 'Pay';
  static const String now = 'now';
  static const String verifiedByProvider =
      'Verified by the payment provider before activation.';

  // Organization / Institution
  static const String institution = 'Institution';
  static const String institutionSubtitle =
      'Your profile, departments and staff identity codes are built from this.';
  static const String uploadLogo = 'Upload logo';
  static const String organisationType = 'Organisation type';
  static const String institutionName = 'Institution name';
  static const String institutionCode = 'Institution code';
  static const String institutionCodeHint =
      'Used for staff codes, e.g. NC-SLS-0007';
  static const String phone = 'Phone';
  static const String address = 'Address';
  static const String workingHours = 'Working hours';
  static const String workingHoursHint = 'Mon–Fri 07:30–17:00, Sat 08:00–13:00';
  static const String servicesOffered = 'Services offered';
  static const String servicesOfferedHint =
      'Consultations, laboratory tests, maternity care…';
  static const String saveChanges = 'Save changes';
  static const String departments = 'Departments';
  static const String noDepartmentsYet =
      'No departments yet. Add one below, or use a suggestion.';
  static const String departmentName = 'Department name';
  static const String teamAndRoles = 'Team & roles';
  static const String teamAndRolesDesc =
      'Organization admins control everything, managers run departments and staff, agents get view-only access.';
  static const String addATeamMember = 'Add a team member';
  static const String teammateEmailHint = 'teammate@institution.cm';
  static const String addMember = 'Add member';

  // Staff
  static const String staff = 'Staff';
  static const String staffSubtitle = 'codes issued automatically';
  static const String registered = 'registered';
  static const String add = 'Add';
  static const String fullName = 'Full name';
  static const String department = 'Department';
  static const String generalNoDepartment = 'General (no department)';
  static const String position = 'Position';
  static const String passportPhoto = 'Passport photo';
  static const String employeeNo = 'Employee no.';
  static const String branch = 'Branch';
  static const String dateOfBirth = 'Date of birth';
  static const String dateEmployed = 'Date employed';
  static const String cardValidUntil = 'Card valid until';
  static const String registerStaffIssueCode = 'Register staff & issue code';

  // Nav
  static const String navHome = 'Home';
  static const String navCall = 'Call';
  static const String navVoices = 'Voices';
  static const String navBilling = 'Billing';
  static const String navStaff = 'Staff';

  // Generic
  static const String or = 'OR';
  static const String loading = 'Loading…';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String save = 'Save';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection.';
  static const String successSaved = 'Changes saved successfully.';
  static const String days30 = '30 days';
  static const String days180 = '180 days';
  static const String days365 = '365 days';
}
