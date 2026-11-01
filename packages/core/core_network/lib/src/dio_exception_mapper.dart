import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';

AppException mapDioException(DioException exception) {
  return AppException(_failure(exception), cause: exception);
}

Failure _failure(DioException exception) {
  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout =>
      const NetworkFailure('The request timed out.'),
    DioExceptionType.connectionError =>
      const NetworkFailure('No internet connection.'),
    DioExceptionType.badResponse => NetworkFailure(
      _statusMessage(exception.response?.statusCode),
    ),
    DioExceptionType.cancel => const NetworkFailure(
      'The request was cancelled.',
    ),
    DioExceptionType.badCertificate => const NetworkFailure(
      'The server certificate was rejected.',
    ),
    DioExceptionType.unknown => const NetworkFailure(
      'The request could not be completed.',
    ),
  };
}

String _statusMessage(int? status) {
  return switch (status) {
    401 => 'Your session has expired. Sign in again.',
    403 => 'You do not have access to this service.',
    404 => 'The requested information was not found.',
    408 => 'The request timed out.',
    500 || 502 || 503 || 504 => 'The service is unavailable. Try again later.',
    _ => 'The request could not be completed.',
  };
}
