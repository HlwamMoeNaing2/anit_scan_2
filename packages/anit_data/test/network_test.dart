import 'package:anit_core/anit_core.dart';
import 'package:anit_data/src/network/dio_exception_mapper.dart';
import 'package:anit_data/src/network/interceptors/auth_interceptor.dart';
import 'package:anit_data/src/network/interceptors/redacting_log_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('network errors use a fixed message and drop the server body', () {
    const secret = 'token-value';
    final exception = mapDioException(
      DioException(
        requestOptions: RequestOptions(path: '/accounts'),
        type: DioExceptionType.badResponse,
        response: Response<Map<String, String>>(
          requestOptions: RequestOptions(path: '/accounts'),
          statusCode: 500,
          data: {'detail': secret},
        ),
      ),
    );

    expect(exception.failure, isA<NetworkFailure>());
    expect(exception.failure.message, 'The service is unavailable. Try again later.');
    expect(exception.failure.message, isNot(contains(secret)));
  });

  test('401 tells the user the session expired', () {
    final exception = mapDioException(
      DioException(
        requestOptions: RequestOptions(path: '/me'),
        type: DioExceptionType.badResponse,
        response: Response<void>(
          requestOptions: RequestOptions(path: '/me'),
          statusCode: 401,
        ),
      ),
    );

    expect(
      exception.failure.message,
      'Your session has expired. Sign in again.',
    );
  });

  test('log label keeps the path and drops the query', () {
    final uri = Uri.parse('https://api.example.com/accounts?token=query-secret');
    final label = RedactingLogInterceptor.label(method: 'GET', uri: uri);

    expect(label, 'HTTP GET /accounts');
    expect(label, isNot(contains('query-secret')));
  });

  test('access token is attached only when one is stored', () async {
    final session = _MemorySession();
    final withToken = RequestOptions(path: '/me');
    await attachAccessToken(withToken, session);
    expect(withToken.headers.containsKey('Authorization'), isFalse);

    await session.saveAccessToken('abc');
    final authorized = RequestOptions(path: '/me');
    await attachAccessToken(authorized, session);
    expect(authorized.headers['Authorization'], 'Bearer abc');
  });
}

class _MemorySession implements SessionStore {
  String? _token;

  @override
  Future<void> clearSession() async => _token = null;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> saveAccessToken(String token) async => _token = token;
}
