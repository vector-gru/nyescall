import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/campay_service.dart';
import '../../data/services/cloudinary_service.dart';
import '../../data/services/elevenlabs_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/openai_service.dart';
import '../../data/services/twilio_service.dart';

/// All service singletons exposed as Riverpod providers.
/// Features import from here — never instantiate services directly.

final firestoreServiceProvider = Provider<FirestoreService>(
  (_) => FirestoreService(),
);

final openAiServiceProvider = Provider<OpenAiService>(
  (_) => OpenAiService(),
);

final elevenLabsServiceProvider = Provider<ElevenLabsService>(
  (_) => ElevenLabsService(),
);

final twilioServiceProvider = Provider<TwilioService>(
  (_) => TwilioService(),
);

/// CamPay payment service — handles MTN MoMo + Orange Money in XAF.
final camPayServiceProvider = Provider<CamPayService>(
  (_) => CamPayService(),
);

final cloudinaryServiceProvider = Provider<CloudinaryService>(
  (_) => CloudinaryService(),
);
