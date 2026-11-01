import 'dart:io';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
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
    expect(
      exception.failure.message,
      'The service is unavailable. Try again later.',
    );
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

  test('httpsCall request keeps the host and drops the query and token', () {
    final options = RequestOptions(
      method: 'GET',
      path: '/posts',
      baseUrl: 'https://jsonplaceholder.typicode.com',
      queryParameters: {'token': 'query-secret'},
      headers: {'Authorization': 'Bearer secret-token'},
      data: {'title': 'Hello'},
    );
    final line = HttpsCallLog.describeRequest(options);

    expect(line, contains('GET https://jsonplaceholder.typicode.com/posts'));
    expect(line, contains('Hello'));
    expect(line, isNot(contains('query-secret')));
    expect(line, isNot(contains('secret-token')));
  });

  test('httpsCall failure keeps the socket cause', () {
    final error = DioException(
      requestOptions: RequestOptions(
        path: 'https://jsonplaceholder.typicode.com/posts',
      ),
      type: DioExceptionType.connectionError,
      message: 'The connection errored',
      error: const SocketException('Failed host lookup'),
    );
    final line = HttpsCallLog.describeFailure(error);

    expect(line, contains('connectionError'));
    expect(line, contains('Failed host lookup'));
    expect(line, contains('https://jsonplaceholder.typicode.com/posts'));
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

    final publicHost = RequestOptions(
      path: 'https://jsonplaceholder.typicode.com/posts',
    );
    publicHost.extra['authenticated'] = false;
    await attachAccessToken(publicHost, session);
    expect(publicHost.headers.containsKey('Authorization'), isFalse);
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
