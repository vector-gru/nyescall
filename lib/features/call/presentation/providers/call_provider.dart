import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/services/elevenlabs_service.dart';
import '../../../../shared/data/services/firestore_service.dart';
import '../../../../shared/data/services/openai_service.dart';
import '../../../../shared/data/services/twilio_service.dart';
import '../../../../shared/presentation/providers/service_providers.dart';
import '../../data/models/call_model.dart';

// ── State ──────────────────────────────────────────────────────────────────

sealed class PlaceCallState {
  const PlaceCallState();
}

final class PlaceCallIdle extends PlaceCallState {
  const PlaceCallIdle();
}

final class PlaceCallLoading extends PlaceCallState {
  const PlaceCallLoading(this.step);
  final String step; // e.g. 'Validating number…', 'Placing call…'
}

final class PlaceCallSuccess extends PlaceCallState {
  const PlaceCallSuccess(this.callId);
  final String callId;
}

final class PlaceCallError extends PlaceCallState {
  const PlaceCallError(this.message);
  final String message;
}

// ── Script suggestion state ────────────────────────────────────────────────

sealed class ScriptSuggestionState {
  const ScriptSuggestionState();
}

final class ScriptIdle extends ScriptSuggestionState {
  const ScriptIdle();
}

final class ScriptLoading extends ScriptSuggestionState {
  const ScriptLoading();
}

final class ScriptReady extends ScriptSuggestionState {
  const ScriptReady(this.text);
  final String text;
}

final class ScriptError extends ScriptSuggestionState {
  const ScriptError(this.message);
  final String message;
}

// ── Place Call Notifier ────────────────────────────────────────────────────

class PlaceCallNotifier extends StateNotifier<PlaceCallState> {
  PlaceCallNotifier({
    required FirestoreService firestore,
    required TwilioService twilio,
    required ElevenLabsService elevenLabs,
  })  : _firestore = firestore,
        _twilio = twilio,
        _elevenLabs = elevenLabs,
        super(const PlaceCallIdle());

  final FirestoreService _firestore;
  final TwilioService _twilio;
  final ElevenLabsService _elevenLabs;

  Future<void> placeCall({
    required String recipientName,
    required String phoneNumber,
    required String language,
    required String reason,
    String? elevenLabsVoiceId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = const PlaceCallError('You must be signed in to place a call.');
      return;
    }

    try {
      // Step 1 — validate the number via Twilio Lookup
      state = const PlaceCallLoading('Validating phone number…');
      TwilioLookupResult? lookup;
      try {
        lookup = await _twilio.lookupNumber(phoneNumber);
        if (!lookup.valid) {
          state = PlaceCallError(
            'Invalid phone number: ${lookup.validationErrors.join(', ')}',
          );
          return;
        }
      } catch (_) {
        // If Twilio keys aren't set yet, skip validation gracefully
        lookup = null;
      }

      // Step 2 — generate a TTS preview (optional, fire-and-forget)
      // In production a Cloud Function will handle the actual call dispatch
      // using ElevenLabs TTS + a SIP/VoIP provider.
      state = const PlaceCallLoading('Preparing AI call…');

      // Step 3 — log the call to Firestore
      state = const PlaceCallLoading('Placing call…');
      final docRef = await _firestore.logCall({
        'userId': uid,
        'recipientName': recipientName,
        'phoneNumber': lookup?.phoneNumber ?? phoneNumber,
        'nationalFormat': lookup?.nationalFormat ?? phoneNumber,
        'language': language,
        'reason': reason,
        'status': CallStatus.pending.name,
        'elevenLabsVoiceId': elevenLabsVoiceId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Increment calls used on active subscription
      final subSnap = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: uid)
          .where('status', whereIn: ['trial', 'active'])
          .orderBy('startDate', descending: true)
          .limit(1)
          .get();

      if (subSnap.docs.isNotEmpty) {
        await _firestore.incrementCallsUsed(subSnap.docs.first.id);
      }

      state = PlaceCallSuccess(docRef.id);
    } catch (e) {
      state = PlaceCallError(e.toString());
    }
  }

  void reset() => state = const PlaceCallIdle();
}

final placeCallProvider =
    StateNotifierProvider<PlaceCallNotifier, PlaceCallState>((ref) {
  return PlaceCallNotifier(
    firestore: ref.watch(firestoreServiceProvider),
    twilio: ref.watch(twilioServiceProvider),
    elevenLabs: ref.watch(elevenLabsServiceProvider),
  );
});

// ── Script suggestion notifier (GPT-4o) ───────────────────────────────────

class ScriptSuggestionNotifier extends StateNotifier<ScriptSuggestionState> {
  ScriptSuggestionNotifier({required OpenAiService openAi})
      : _openAi = openAi,
        super(const ScriptIdle());

  final OpenAiService _openAi;

  Future<void> suggest({
    required String recipientName,
    required String context,
    required String language,
  }) async {
    state = const ScriptLoading();
    try {
      final suggestion = await _openAi.suggestCallReason(
        recipientName: recipientName,
        context: context,
        language: language,
      );
      state = ScriptReady(suggestion);
    } catch (e) {
      state = ScriptError(e.toString());
    }
  }

  void clear() => state = const ScriptIdle();
}

final scriptSuggestionProvider =
    StateNotifierProvider<ScriptSuggestionNotifier, ScriptSuggestionState>(
  (ref) => ScriptSuggestionNotifier(
    openAi: ref.watch(openAiServiceProvider),
  ),
);

// ── Call history ───────────────────────────────────────────────────────────

final callHistoryProvider = StreamProvider<List<CallModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('calls')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((s) => s.docs.map(CallModel.fromFirestore).toList());
});
