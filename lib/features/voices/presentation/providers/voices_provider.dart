import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/services/elevenlabs_service.dart';
import '../../../../shared/data/services/firestore_service.dart';
import '../../../../shared/presentation/providers/service_providers.dart';
import '../../data/models/voice_model.dart';

// ── Firestore voices stream ────────────────────────────────────────────────

final voicesProvider = StreamProvider<List<VoiceModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('voices')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(VoiceModel.fromFirestore).toList());
});

// ── ElevenLabs voices (built-in + cloned) ─────────────────────────────────

/// Fetches all voices available on the ElevenLabs account.
/// These are shown as options when placing a call.
final elevenLabsVoicesProvider =
    FutureProvider<List<ElevenLabsVoice>>((ref) async {
  return ref.watch(elevenLabsServiceProvider).listVoices();
});

// ── Save voice state ───────────────────────────────────────────────────────

sealed class SaveVoiceState {
  const SaveVoiceState();
}

final class SaveVoiceIdle extends SaveVoiceState {
  const SaveVoiceIdle();
}

final class SaveVoiceLoading extends SaveVoiceState {
  const SaveVoiceLoading();
}

final class SaveVoiceSuccess extends SaveVoiceState {
  const SaveVoiceSuccess();
}

final class SaveVoiceError extends SaveVoiceState {
  const SaveVoiceError(this.message);
  final String message;
}

// ── Save voice notifier ────────────────────────────────────────────────────

class SaveVoiceNotifier extends StateNotifier<SaveVoiceState> {
  SaveVoiceNotifier({
    required FirestoreService firestore,
    required ElevenLabsService elevenLabs,
  })  : _firestore = firestore,
        _elevenLabs = elevenLabs,
        super(const SaveVoiceIdle());

  final FirestoreService _firestore;
  final ElevenLabsService _elevenLabs;

  Future<void> save({
    required String name,
    required String language,
    required String speakingSpeed,
    required String voiceTone,
    required bool consentGiven,
    String? audioPath,
  }) async {
    if (!consentGiven) {
      state = const SaveVoiceError(
          'You must confirm ownership before saving a voice.');
      return;
    }
    if (name.trim().isEmpty) {
      state = const SaveVoiceError('Voice name is required.');
      return;
    }

    state = const SaveVoiceLoading();
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated.');

      String? elevenLabsVoiceId;

      // If the user provided a sample, clone it via ElevenLabs.
      if (audioPath != null) {
        try {
          elevenLabsVoiceId = await _elevenLabs.cloneVoice(
            name: name.trim(),
            audioFilePaths: [audioPath],
          );
        } catch (_) {
          // Clone failed — save the record without an ElevenLabs ID.
          // The user can upload a sample later.
        }
      }

      await _firestore.addVoice({
        'userId': uid,
        'name': name.trim(),
        'type': VoiceType.myVoice.name,
        'language': language,
        'speakingSpeed': speakingSpeed,
        'voiceTone': voiceTone,
        if (elevenLabsVoiceId != null) 'elevenLabsVoiceId': elevenLabsVoiceId,
        if (audioPath != null) 'hasLocalSample': true,
        'isDefault': false,
      });

      state = const SaveVoiceSuccess();
    } catch (e) {
      state = SaveVoiceError('$e');
    }
  }

  void reset() => state = const SaveVoiceIdle();
}

final saveVoiceProvider =
    StateNotifierProvider<SaveVoiceNotifier, SaveVoiceState>(
  (ref) => SaveVoiceNotifier(
    firestore: ref.watch(firestoreServiceProvider),
    elevenLabs: ref.watch(elevenLabsServiceProvider),
  ),
);
