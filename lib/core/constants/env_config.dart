// =============================================================================
//  NYESCALL — Environment / Endpoint Configuration
//  Non-secret settings that vary between dev and production.
// =============================================================================

enum CamPayEnvironment { dev, prod }

abstract final class EnvConfig {
  // ── OpenAI ────────────────────────────────────────────────────────────────
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String openAiChatModel = 'gpt-4o';
  static const String openAiWhisperModel = 'whisper-1';

  // ── ElevenLabs ────────────────────────────────────────────────────────────
  static const String elevenLabsBaseUrl = 'https://api.elevenlabs.io/v1';
  // Multilingual v2 — best coverage for African + major world languages
  static const String elevenLabsTtsModel = 'eleven_multilingual_v2';

  // ── Twilio Lookup ─────────────────────────────────────────────────────────
  static const String twilioLookupBaseUrl =
      'https://lookups.twilio.com/v2/PhoneNumbers';

  // ── CamPay ────────────────────────────────────────────────────────────────
  // Toggle between sandbox and production here.
  // DEMO  → https://demo.campay.net/api
  // PROD  → https://campay.net/api
  static const CamPayEnvironment camPayEnvironment = CamPayEnvironment.dev;

  static String get camPayBaseUrl => camPayEnvironment == CamPayEnvironment.dev
      ? 'https://demo.campay.net/api'
      : 'https://campay.net/api';

  // Individual endpoint paths
  static String get camPayTokenUrl => '$camPayBaseUrl/token/';
  static String get camPayCollectUrl => '$camPayBaseUrl/collect/';
  static String get camPayStatusUrl => '$camPayBaseUrl/transaction/';
  static String get camPayBalanceUrl => '$camPayBaseUrl/balance/';

  // ── Cloudinary ────────────────────────────────────────────────────────────
  static String cloudinaryUploadUrl(String cloudName) =>
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';

  static String cloudinaryTransform(
    String cloudName,
    String publicId, {
    int width = 400,
    int height = 400,
    String crop = 'fill',
  }) =>
      'https://res.cloudinary.com/$cloudName/image/upload/'
      'w_$width,h_$height,c_$crop,f_auto,q_auto/$publicId';

  // ── App timeouts ──────────────────────────────────────────────────────────
  static const Duration apiConnectTimeout = Duration(seconds: 20);
  static const Duration apiReceiveTimeout = Duration(seconds: 60);
}
