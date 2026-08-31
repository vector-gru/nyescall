import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/constants/api_keys.dart';
import '../../../core/constants/env_config.dart';
import '../../../core/errors/app_exception.dart';

/// OpenAI integration — covers two capabilities:
///   1. GPT-4o  →  call script / reason drafting assistant
///   2. Whisper →  speech-to-text transcription of call recordings
class OpenAiService {
  OpenAiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: EnvConfig.openAiBaseUrl,
              connectTimeout: EnvConfig.apiConnectTimeout,
              receiveTimeout: EnvConfig.apiReceiveTimeout,
            ));

  final Dio _dio;

  Options get _authHeaders => Options(
        headers: {'Authorization': 'Bearer ${ApiKeys.openAi}'},
      );

  // ── GPT-4o: Call script assistant ─────────────────────────────────────────

  /// Given a [recipientName], [context] and [language], returns a
  /// well-crafted call reason / script suggestion.
  Future<String> suggestCallReason({
    required String recipientName,
    required String context,
    required String language,
  }) async {
    _assertKeySet(ApiKeys.openAi, 'OpenAI');
    try {
      final response = await _dio.post(
        '/chat/completions',
        options: _authHeaders,
        data: {
          'model': EnvConfig.openAiChatModel,
          'max_tokens': 300,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional call script writer for NYESCALL, '
                  'an AI outbound calling service used by African businesses. '
                  'Write concise, polite, and natural-sounding call reasons. '
                  'Respond in $language.',
            },
            {
              'role': 'user',
              'content':
                  'Write a brief call reason for calling $recipientName. '
                  'Context: $context. Keep it under 150 words.',
            },
          ],
        },
      );
      return response.data['choices'][0]['message']['content'] as String;
    } on DioException catch (e) {
      throw ApiException(_extractOpenAiError(e));
    }
  }

  /// Generic chat completion — used for any future AI assistant features.
  Future<String> chat({
    required List<Map<String, String>> messages,
    int maxTokens = 500,
  }) async {
    _assertKeySet(ApiKeys.openAi, 'OpenAI');
    try {
      final response = await _dio.post(
        '/chat/completions',
        options: _authHeaders,
        data: {
          'model': EnvConfig.openAiChatModel,
          'max_tokens': maxTokens,
          'messages': messages,
        },
      );
      return response.data['choices'][0]['message']['content'] as String;
    } on DioException catch (e) {
      throw ApiException(_extractOpenAiError(e));
    }
  }

  // ── Whisper: Call transcription ────────────────────────────────────────────

  /// Transcribes an audio file at [audioPath] into text.
  /// [language] is the BCP-47 code, e.g. 'en', 'fr', 'sw'.
  Future<String> transcribeAudio({
    required String audioPath,
    String language = 'en',
  }) async {
    _assertKeySet(ApiKeys.openAi, 'OpenAI');
    try {
      final file = File(audioPath);
      final ext = audioPath.split('.').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioPath,
          filename: 'recording.$ext',
          contentType: MediaType('audio', ext),
        ),
        'model': EnvConfig.openAiWhisperModel,
        'language': language,
        'response_format': 'text',
      });

      final response = await _dio.post(
        '/audio/transcriptions',
        options: Options(
          headers: {'Authorization': 'Bearer ${ApiKeys.openAi}'},
        ),
        data: formData,
      );

      return response.data as String;
    } on DioException catch (e) {
      throw ApiException(_extractOpenAiError(e));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _assertKeySet(String key, String service) {
    if (key.startsWith('REPLACE')) {
      throw ApiException(
        '$service API key is not configured. '
        'Add it to lib/core/constants/api_keys.dart.',
      );
    }
  }

  String _extractOpenAiError(DioException e) {
    final msg = e.response?.data?['error']?['message'] as String?;
    return msg ?? 'OpenAI request failed (${e.response?.statusCode}).';
  }
}
