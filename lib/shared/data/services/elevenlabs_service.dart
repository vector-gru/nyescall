import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/constants/api_keys.dart';
import '../../../core/constants/env_config.dart';
import '../../../core/errors/app_exception.dart';

/// ElevenLabs integration — Text-to-Speech + Voice Cloning.
///
/// Used to:
///   • Preview how a call will sound before dispatching it.
///   • Clone a user's voice for personalised AI calls.
///   • List available voices to populate the Voices screen.
class ElevenLabsService {
  ElevenLabsService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: EnvConfig.elevenLabsBaseUrl,
              connectTimeout: EnvConfig.apiConnectTimeout,
              receiveTimeout: EnvConfig.apiReceiveTimeout,
            ));

  final Dio _dio;

  Options get _auth => Options(
        headers: {'xi-api-key': ApiKeys.elevenLabs},
        responseType: ResponseType.bytes,
      );

  Options get _authJson => Options(
        headers: {
          'xi-api-key': ApiKeys.elevenLabs,
          'Content-Type': 'application/json',
        },
      );

  // ── TTS ────────────────────────────────────────────────────────────────────

  /// Converts [text] to speech and returns raw MP3 bytes.
  /// [voiceId] is either a built-in ElevenLabs voice ID or a cloned voice ID.
  Future<Uint8List> textToSpeech({
    required String text,
    required String voiceId,
    String? modelId,
    double stability = 0.5,
    double similarityBoost = 0.75,
    double style = 0.0,
    bool useSpeakerBoost = true,
  }) async {
    _assertKey();
    try {
      final response = await _dio.post(
        '/text-to-speech/$voiceId',
        options: _auth,
        data: {
          'text': text,
          'model_id': modelId ?? EnvConfig.elevenLabsTtsModel,
          'voice_settings': {
            'stability': stability,
            'similarity_boost': similarityBoost,
            'style': style,
            'use_speaker_boost': useSpeakerBoost,
          },
        },
      );
      return Uint8List.fromList(response.data as List<int>);
    } on DioException catch (e) {
      throw ApiException('ElevenLabs TTS failed: ${e.message}');
    }
  }

  // ── Voices ─────────────────────────────────────────────────────────────────

  /// Returns the list of voices available on the account
  /// (includes built-in + any cloned voices).
  Future<List<ElevenLabsVoice>> listVoices() async {
    _assertKey();
    try {
      final response = await _dio.get(
        '/voices',
        options: Options(headers: {'xi-api-key': ApiKeys.elevenLabs}),
      );
      final voices =
          (response.data['voices'] as List).cast<Map<String, dynamic>>();
      return voices.map(ElevenLabsVoice.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException('Could not fetch voices: ${e.message}');
    }
  }

  // ── Voice cloning ──────────────────────────────────────────────────────────

  /// Clones a voice from [audioFilePaths] (1–25 high-quality samples).
  /// Returns the new [voiceId] assigned by ElevenLabs.
  Future<String> cloneVoice({
    required String name,
    required List<String> audioFilePaths,
    String description = '',
  }) async {
    _assertKey();
    try {
      final files = await Future.wait(
        audioFilePaths.map(
          (p) => MultipartFile.fromFile(p, filename: p.split('/').last),
        ),
      );

      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        'files': files,
      });

      final response = await _dio.post(
        '/voices/add',
        options: Options(headers: {'xi-api-key': ApiKeys.elevenLabs}),
        data: formData,
      );

      final voiceId = response.data['voice_id'] as String?;
      if (voiceId == null) throw const ApiException('Voice clone failed — no voice_id returned.');
      return voiceId;
    } on DioException catch (e) {
      throw ApiException('Voice clone failed: ${e.message}');
    }
  }

  /// Deletes a cloned voice by its [voiceId].
  Future<void> deleteVoice(String voiceId) async {
    _assertKey();
    try {
      await _dio.delete(
        '/voices/$voiceId',
        options: Options(headers: {'xi-api-key': ApiKeys.elevenLabs}),
      );
    } on DioException catch (e) {
      throw ApiException('Could not delete voice: ${e.message}');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _assertKey() {
    if (ApiKeys.elevenLabs.startsWith('REPLACE')) {
      throw const ApiException(
        'ElevenLabs API key is not configured. '
        'Add it to lib/core/constants/api_keys.dart.',
      );
    }
  }
}

// ── Model ──────────────────────────────────────────────────────────────────

class ElevenLabsVoice {
  const ElevenLabsVoice({
    required this.voiceId,
    required this.name,
    this.category,
    this.previewUrl,
  });

  final String voiceId;
  final String name;
  final String? category;
  final String? previewUrl;

  factory ElevenLabsVoice.fromJson(Map<String, dynamic> json) =>
      ElevenLabsVoice(
        voiceId: json['voice_id'] as String,
        name: json['name'] as String,
        category: json['category'] as String?,
        previewUrl: json['preview_url'] as String?,
      );

  bool get isCloned => category == 'cloned';
}
