import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';

/// Attaches the access token. The header is never written to logs.
Future<void> attachAccessToken(
  RequestOptions options,
  SessionStore sessionStore,
) async {
  if (options.extra['authenticated'] == false) return;
  final token = await sessionStore.readAccessToken();
  if (token == null || token.isEmpty) return;
  options.headers['Authorization'] = 'Bearer $token';
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._sessionStore);

  final SessionStore _sessionStore;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    attachAccessToken(options, _sessionStore).then(
      (_) => handler.next(options),
      onError: (Object error) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: error,
            type: DioExceptionType.unknown,
          ),
        );
      },
    );
  }
}
