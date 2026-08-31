import 'package:equatable/equatable.dart';

/// Result pattern — used at the domain layer.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class DataFailure extends Failure {
  const DataFailure(super.message);
}

final class ApiFailure extends Failure {
  const ApiFailure(super.message, {this.statusCode});
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
