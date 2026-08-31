import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/constants/api_keys.dart';
import '../../../core/constants/env_config.dart';
import '../../../core/errors/app_exception.dart';

/// Twilio Lookup API — validates phone numbers before placing a call.
///
/// Prevents wasted call credits on invalid / non-existent numbers.
/// Free for basic validation; line-type intelligence costs $0.005/lookup.
class TwilioService {
  TwilioService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: EnvConfig.twilioLookupBaseUrl,
              connectTimeout: EnvConfig.apiConnectTimeout,
              receiveTimeout: Duration(seconds: 10),
            ));

  final Dio _dio;

  Options get _auth {
    final credentials = base64Encode(
      utf8.encode(
        '${ApiKeys.twilioAccountSid}:${ApiKeys.twilioAuthToken}',
      ),
    );
    return Options(headers: {'Authorization': 'Basic $credentials'});
  }

  /// Validates a phone number in E.164 format (e.g. +237678509520).
  /// Returns a [TwilioLookupResult] or throws [ApiException].
  Future<TwilioLookupResult> lookupNumber(String phoneNumber) async {
    _assertKeys();
    try {
      final encoded = Uri.encodeComponent(phoneNumber);
      final response = await _dio.get(
        '/$encoded',
        options: _auth,
        queryParameters: {
          // 'line_type_intelligence' costs $0.005 but tells you if it's mobile/landline.
          // Leave commented out for free-tier usage:
          // 'Fields': 'line_type_intelligence',
        },
      );

      final data = response.data as Map<String, dynamic>;
      return TwilioLookupResult(
        phoneNumber: data['phone_number'] as String? ?? phoneNumber,
        nationalFormat: data['national_format'] as String? ?? phoneNumber,
        countryCode: data['country_code'] as String? ?? '',
        valid: data['valid'] as bool? ?? true,
        validationErrors:
            (data['validation_errors'] as List?)?.cast<String>() ?? [],
        lineType: data['line_type_intelligence']?['type'] as String?,
        carrier: data['line_type_intelligence']?['carrier_name'] as String?,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return TwilioLookupResult(
          phoneNumber: phoneNumber,
          nationalFormat: phoneNumber,
          countryCode: '',
          valid: false,
          validationErrors: ['NOT_FOUND'],
        );
      }
      throw ApiException(
        'Phone validation failed: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  void _assertKeys() {
    if (ApiKeys.twilioAccountSid.startsWith('REPLACE') ||
        ApiKeys.twilioAuthToken.startsWith('REPLACE')) {
      throw const ApiException(
        'Twilio credentials are not configured. '
        'Add them to lib/core/constants/api_keys.dart.',
      );
    }
  }
}

// ── Model ──────────────────────────────────────────────────────────────────

class TwilioLookupResult {
  const TwilioLookupResult({
    required this.phoneNumber,
    required this.nationalFormat,
    required this.countryCode,
    required this.valid,
    this.validationErrors = const [],
    this.lineType,
    this.carrier,
  });

  final String phoneNumber;
  final String nationalFormat;
  final String countryCode;
  final bool valid;
  final List<String> validationErrors;
  final String? lineType;  // 'mobile', 'landline', 'voip', etc.
  final String? carrier;

  bool get isMobile => lineType == null || lineType == 'mobile';
}
