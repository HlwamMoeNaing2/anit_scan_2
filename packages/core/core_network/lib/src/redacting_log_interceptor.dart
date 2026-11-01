import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';

import 'https_call_log.dart';

/// Logs the method, path, and status only. Query and headers stay out so a
/// token in the URL cannot land in logcat or the Xcode console.
///
/// Debug builds also write the request and response to the `httpsCall` log tag.
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
    HttpsCallLog.request(options);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      label(
        method: response.requestOptions.method,
        uri: response.requestOptions.uri,
        statusCode: response.statusCode,
      ),
    );
    HttpsCallLog.response(response);
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
    HttpsCallLog.failure(err);
    handler.next(err);
  }
}
