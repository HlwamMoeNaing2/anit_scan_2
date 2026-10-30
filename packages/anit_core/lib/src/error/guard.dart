import '../logging/app_logger.dart';
import 'app_exception.dart';
import 'failure.dart';
import 'result.dart';

/// Runs [action] and returns a [Result]. Unexpected errors keep a generic
/// message so a stack trace never reaches the screen.
Future<Result<T>> guardCall<T>(
  Future<T> Function() action, {
  AppLogger? logger,
}) async {
  try {
    return Success(await action());
  } on AppException catch (error, stackTrace) {
    logger?.warn(error.failure.message, error: error.cause, stackTrace: stackTrace);
    return ResultFailure(error.failure);
  } catch (error, stackTrace) {
    logger?.error('Unhandled error', error: error, stackTrace: stackTrace);
    return ResultFailure(UnexpectedFailure());
  }
}
