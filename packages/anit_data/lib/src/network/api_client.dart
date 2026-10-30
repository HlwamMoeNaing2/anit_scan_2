import 'package:anit_core/anit_core.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config/api_config.dart';
import 'dio_exception_mapper.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/redacting_log_interceptor.dart';

class ApiClient {
  ApiClient({
    required ApiConfig config,
    required SessionStore sessionStore,
    required AppLogger logger,
    this.onUnauthorized,
    Dio? dio,
  }) : dio = dio ?? _create(config, sessionStore, logger);

  final Dio dio;
  final void Function()? onUnauthorized;

  static Dio _create(
    ApiConfig config,
    SessionStore sessionStore,
    AppLogger logger,
  ) {
    final client = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        headers: {Headers.acceptHeader: Headers.jsonContentType},
        followRedirects: true,
        maxRedirects: 3,
      ),
    );
    _applyCertificatePins(client, config.certificateSha256Pins);
    client.interceptors.add(AuthInterceptor(sessionStore));
    if (config.enableHttpLogs) {
      client.interceptors.add(RedactingLogInterceptor(logger));
    }
    return client;
  }

  static void _applyCertificatePins(Dio client, List<String> pins) {
    if (pins.isEmpty) return;
    final allowed = pins.map((pin) => pin.toLowerCase()).toSet();
    client.httpClientAdapter = IOHttpClientAdapter(
      validateCertificate: (certificate, host, port) {
        if (certificate == null) return false;
        final fingerprint = sha256.convert(certificate.der).toString();
        return allowed.contains(fingerprint);
      },
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _send(() => dio.get<T>(path, queryParameters: query));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) {
    return _send(() => dio.post<T>(path, data: body, queryParameters: query));
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? body,
  }) {
    return _send(() => dio.put<T>(path, data: body));
  }

  Future<Response<T>> delete<T>(String path) {
    return _send(() => dio.delete<T>(path));
  }

  Future<Response<T>> _send<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        onUnauthorized?.call();
      }
      throw mapDioException(error);
    }
  }

  void close() => dio.close(force: true);
}
