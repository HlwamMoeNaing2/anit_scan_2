import 'package:anit_core/anit_core.dart';
import 'package:dio/dio.dart';

/// Logs the method, path, and status only. Query and headers stay out so a
/// token in the URL cannot land in logcat or the Xcode console.
class RedactingLogInterceptor extends Interceptor {
  RedactingLogInterceptor(this._logger);

  final AppLogger _logger;

  static String label({
    required String method,
    required Uri uri,
    int? statusCode,
  }) {
    final status = statusCode == null ? '' : ' $statusCode';
    return 'HTTP $method ${uri.path}$status';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug(label(method: options.method, uri: options.uri));
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _logger.debug(
      label(
        method: response.requestOptions.method,
        uri: response.requestOptions.uri,
        statusCode: response.statusCode,
      ),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warn(
      label(
        method: err.requestOptions.method,
        uri: err.requestOptions.uri,
        statusCode: err.response?.statusCode,
      ),
    );
    handler.next(err);
  }
}
