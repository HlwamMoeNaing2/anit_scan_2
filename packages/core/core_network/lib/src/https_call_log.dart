import 'dart:async';
import 'dart:math' show min;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Debug Logcat tag. Filter Android logcat with `tag:httpsCall`.
abstract final class HttpsCallLog {
  static const tag = 'httpsCall';
  static const _channel = MethodChannel('httpsCall');
  static const _chunkSize = 3000;

  static void request(RequestOptions options) {
    _write(describeRequest(options));
  }

  static void response(Response<dynamic> response) {
    _write(describeResponse(response));
  }

  static void failure(DioException error) {
    _write(describeFailure(error));
  }

  static String describeRequest(RequestOptions options) {
    final buffer = StringBuffer(
      '--> ${options.method} ${_visibleUri(options.uri)}',
    );
    final body = _body(options.data);
    if (body != null) {
      buffer
        ..writeln()
        ..write('body: $body');
    }
    return buffer.toString();
  }

  static String describeResponse(Response<dynamic> response) {
    final body = _body(response.data);
    return '''
<-- ${response.statusCode} ${response.requestOptions.method} ${_visibleUri(response.requestOptions.uri)}
body: ${body ?? '(empty)'}'''
        .trim();
  }

  static String describeFailure(DioException error) {
    final buffer = StringBuffer(
      '''
<-- FAIL ${error.requestOptions.method} ${_visibleUri(error.requestOptions.uri)}
type: ${error.type.name}
message: ${error.message}
cause: ${error.error}''',
    );
    final response = error.response;
    if (response != null) {
      buffer
        ..writeln()
        ..writeln('status: ${response.statusCode}')
        ..write('body: ${_body(response.data) ?? '(empty)'}');
    }
    return buffer.toString();
  }

  /// Host and path only. Query strings and user info can carry tokens.
  static String _visibleUri(Uri uri) {
    return uri.replace(query: '', fragment: '', userInfo: '').toString();
  }

  static String? _body(Object? data) {
    if (data == null) return null;
    if (data is Map || data is List || data is String || data is num) {
      return data.toString();
    }
    return data.runtimeType.toString();
  }

  static void _write(String message) {
    if (!kDebugMode) return;
    for (var start = 0; start < message.length; start += _chunkSize) {
      final end = min(start + _chunkSize, message.length);
      unawaited(_send(message.substring(start, end)));
    }
  }

  static Future<void> _send(String message) async {
    try {
      await _channel.invokeMethod<void>('log', {'message': message});
    } on MissingPluginException {
      debugPrint('$tag: $message');
    } on PlatformException {
      debugPrint('$tag: $message');
    }
  }
}
