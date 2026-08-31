import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/api_keys.dart';
import '../../../core/constants/env_config.dart';
import '../../../core/errors/app_exception.dart';

/// CamPay payment service — REST API wrapper for Flutter.
///
/// CamPay supports MTN Mobile Money and Orange Money for Cameroon (XAF).
/// This uses the REST API directly (not the Android SDK), so it works on
/// both Android and iOS.
///
/// API flow:
///   1. [getToken]    — authenticate and receive a short-lived access token
///   2. [collect]     — initiate a collection (payment request to the user)
///   3. [checkStatus] — poll until SUCCESSFUL / FAILED
///
/// Docs: https://documenter.getpostman.com/view/2779350/T1LJm8zt
class CamPayService {
  CamPayService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: EnvConfig.apiConnectTimeout,
              receiveTimeout: EnvConfig.apiReceiveTimeout,
            ));

  final Dio _dio;
  final _uuid = const Uuid();

  // Cached access token — refreshed on each session (tokens expire in 1 hour).
  String? _cachedToken;

  // ── Authentication ────────────────────────────────────────────────────────

  /// Fetches a short-lived Bearer token using username + password.
  /// Called automatically before any other request.
  Future<String> getToken() async {
    _assertKeys();
    try {
      final response = await _dio.post(
        EnvConfig.camPayTokenUrl,
        data: {
          'username': ApiKeys.camPayUsername,
          'password': ApiKeys.camPayPassword,
        },
        options: Options(contentType: Headers.jsonContentType),
      );

      final token = response.data['token'] as String?;
      if (token == null) {
        throw const ApiException('CamPay did not return a token.');
      }
      _cachedToken = token;
      return token;
    } on DioException catch (e) {
      throw ApiException(
        _extract(e, 'CamPay authentication failed.'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Collection (payment request) ──────────────────────────────────────────

  /// Sends a payment request (collect) to a mobile money number.
  ///
  /// [amount]    — amount in XAF as a string, e.g. '23500'
  /// [from]      — subscriber's number in international format: '237XXXXXXXXX'
  /// [description] — shown in the USSD prompt
  ///
  /// Returns a [CamPayCollectResult] with a [reference] you use for polling.
  Future<CamPayCollectResult> collect({
    required String amount,
    required String from,
    required String description,
    String? externalReference,
  }) async {
    final token = _cachedToken ?? await getToken();

    try {
      final response = await _dio.post(
        EnvConfig.camPayCollectUrl,
        options: _bearer(token),
        data: {
          'amount': amount,
          'from': _normalise(from),
          'description': description,
          'external_reference':
              externalReference ?? _uuid.v4().replaceAll('-', '').substring(0, 20),
          'currency': 'XAF',
        },
      );

      final data = response.data as Map<String, dynamic>;
      return CamPayCollectResult(
        reference: data['reference'] as String,
        ussdCode: data['ussd_code'] as String? ?? '',
        operatorReference: data['operator_reference'] as String? ?? '',
        status: data['status'] as String? ?? 'PENDING',
      );
    } on DioException catch (e) {
      // Token may have expired — retry once with a fresh token.
      if (e.response?.statusCode == 401) {
        _cachedToken = null;
        return collect(
          amount: amount,
          from: from,
          description: description,
          externalReference: externalReference,
        );
      }
      throw ApiException(
        _extract(e, 'Collection request failed.'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Transaction status ────────────────────────────────────────────────────

  /// Checks the status of a previously initiated collection.
  ///
  /// Poll every 5–10 seconds until [CamPayTransactionStatus.isFinal] is true.
  /// A SUCCESSFUL status means the payment was received.
  Future<CamPayTransactionStatus> checkStatus(String reference) async {
    final token = _cachedToken ?? await getToken();

    try {
      final response = await _dio.get(
        '${EnvConfig.camPayStatusUrl}$reference/',
        options: _bearer(token),
      );

      final data = response.data as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'PENDING';

      return CamPayTransactionStatus(
        reference: reference,
        status: status,
        amount: data['amount']?.toString() ?? '0',
        currency: data['currency'] as String? ?? 'XAF',
        operator_: data['operator'] as String? ?? '',
        externalReference: data['external_reference'] as String? ?? '',
        description: data['description'] as String? ?? '',
        isSuccessful: status == 'SUCCESSFUL',
        isFailed: status == 'FAILED',
        isFinal: status == 'SUCCESSFUL' || status == 'FAILED',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _cachedToken = null;
        return checkStatus(reference);
      }
      throw ApiException(
        _extract(e, 'Status check failed.'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Application balance ───────────────────────────────────────────────────

  /// Returns the current balance of the CamPay application wallet.
  Future<CamPayBalance> applicationBalance() async {
    final token = _cachedToken ?? await getToken();

    try {
      final response = await _dio.get(
        EnvConfig.camPayBalanceUrl,
        options: _bearer(token),
      );

      final data = response.data as Map<String, dynamic>;
      return CamPayBalance(
        balance: data['balance']?.toString() ?? '0',
        currency: data['currency'] as String? ?? 'XAF',
      );
    } on DioException catch (e) {
      throw ApiException(_extract(e, 'Could not fetch balance.'));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _assertKeys() {
    if (ApiKeys.camPayUsername.startsWith('REPLACE') ||
        ApiKeys.camPayPassword.startsWith('REPLACE')) {
      throw const ApiException(
        'CamPay credentials are not configured. '
        'Add them to lib/core/constants/api_keys.dart.',
      );
    }
  }

  Options _bearer(String token) => Options(
        headers: {'Authorization': 'Token $token'},
        contentType: Headers.jsonContentType,
      );

  /// Normalise a Cameroon number to 237XXXXXXXXX format.
  String _normalise(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('237')) return digits;
    return '237$digits';
  }

  String _extract(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail != null) return detail.toString();
    }
    return fallback;
  }
}

// ── Result models ──────────────────────────────────────────────────────────

class CamPayCollectResult {
  const CamPayCollectResult({
    required this.reference,
    required this.ussdCode,
    required this.operatorReference,
    required this.status,
  });

  /// CamPay reference — use this to poll [CamPayService.checkStatus].
  final String reference;
  final String ussdCode;
  final String operatorReference;
  final String status;
}

class CamPayTransactionStatus {
  const CamPayTransactionStatus({
    required this.reference,
    required this.status,
    required this.amount,
    required this.currency,
    required this.operator_,
    required this.externalReference,
    required this.description,
    required this.isSuccessful,
    required this.isFailed,
    required this.isFinal,
  });

  final String reference;
  /// 'SUCCESSFUL' | 'FAILED' | 'PENDING'
  final String status;
  final String amount;
  final String currency;
  final String operator_;    // 'MTN' | 'ORANGE'
  final String externalReference;
  final String description;
  final bool isSuccessful;
  final bool isFailed;
  /// True when no more polling is needed.
  final bool isFinal;
}

class CamPayBalance {
  const CamPayBalance({required this.balance, required this.currency});
  final String balance;
  final String currency;
}
