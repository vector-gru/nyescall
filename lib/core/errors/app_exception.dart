/// Typed exceptions used throughout the app.
library;

sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Firebase / network authentication errors.
final class AuthException extends AppException {
  const AuthException(super.message);
}

/// Firestore / data errors.
final class DataException extends AppException {
  const DataException(super.message);
}

/// Bland AI API errors.
final class ApiException extends AppException {
  const ApiException(super.message, {this.statusCode});
  final int? statusCode;
}

/// No internet connection.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

/// Feature not yet available or permission denied.
final class PermissionException extends AppException {
  const PermissionException(super.message);
}

/// Validation / business rule failure.
final class ValidationException extends AppException {
  const ValidationException(super.message);
}
