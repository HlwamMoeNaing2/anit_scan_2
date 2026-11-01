import 'failure.dart';

/// Thrown by a data source. A use case converts it with [guardCall].
/// [cause] is for logs. The screen only receives [failure].
class AppException implements Exception {
  const AppException(this.failure, {this.cause});

  final Failure failure;
  final Object? cause;

  @override
  String toString() => failure.message;
}
