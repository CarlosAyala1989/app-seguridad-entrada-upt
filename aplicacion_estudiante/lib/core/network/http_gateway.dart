import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/l10n/app_strings.dart';
import '../error/failure.dart';

final class HttpResponseData {
  const HttpResponseData({required this.statusCode, this.body});

  final int statusCode;
  final Map<String, Object?>? body;

  bool get esExitosa => statusCode >= 200 && statusCode < 300;
}

abstract interface class HttpGateway {
  Future<HttpResponseData> get(
    String path, {
    Map<String, String> headers = const {},
    Duration? timeout,
  });

  Future<HttpResponseData> post(
    String path, {
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
    Duration? timeout,
  });

  Future<HttpResponseData> delete(
    String path, {
    Map<String, String> headers = const {},
    Duration? timeout,
  });

  Future<HttpResponseData> patch(
    String path, {
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
    Duration? timeout,
  });
}

/// Gateway basado en `package:http`: funciona en Android, iOS, escritorio
/// y web (a diferencia de `dart:io`, que no existe en el navegador).
final class ApiHttpGateway implements HttpGateway {
  ApiHttpGateway({
    required String baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _baseUrlNormalizada = baseUrl.replaceAll(RegExp(r'/+$'), ''),
       _client = client ?? http.Client();

  final String _baseUrlNormalizada;
  final http.Client _client;
  final Duration timeout;

  Uri _construirUri(String path) {
    final pathLimpio = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrlNormalizada$pathLimpio');
  }

  @override
  Future<HttpResponseData> get(
    String path, {
    Map<String, String> headers = const {},
    Duration? timeout,
  }) {
    return _send('GET', path, headers: headers, timeout: timeout);
  }

  @override
  Future<HttpResponseData> post(
    String path, {
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
    Duration? timeout,
  }) {
    return _send('POST', path, headers: headers, body: body, timeout: timeout);
  }

  @override
  Future<HttpResponseData> delete(
    String path, {
    Map<String, String> headers = const {},
    Duration? timeout,
  }) {
    return _send('DELETE', path, headers: headers, timeout: timeout);
  }

  @override
  Future<HttpResponseData> patch(
    String path, {
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
    Duration? timeout,
  }) {
    return _send('PATCH', path, headers: headers, body: body, timeout: timeout);
  }

  Future<HttpResponseData> _send(
    String method,
    String path, {
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
    Duration? timeout,
  }) async {
    final limite = timeout ?? this.timeout;
    try {
      final request = http.Request(method, _construirUri(path));
      request.headers.addAll({'accept': 'application/json', ...headers});
      if (body != null) {
        request.headers['content-type'] = 'application/json; charset=utf-8';
        request.body = jsonEncode(body);
      }

      final streamed = await _client.send(request).timeout(limite);
      final response = await http.Response.fromStream(streamed).timeout(limite);
      final rawBody = utf8.decode(response.bodyBytes);

      Map<String, Object?>? decodedBody;
      if (rawBody.trim().isNotEmpty) {
        final decoded = jsonDecode(rawBody);
        if (decoded is! Map<String, dynamic>) throw const DataFailure();
        decodedBody = decoded.cast<String, Object?>();
      }

      return HttpResponseData(
        statusCode: response.statusCode,
        body: decodedBody,
      );
    } on Failure {
      rethrow;
    } on TimeoutException {
      throw const NetworkFailure(AppStrings.timeoutError);
    } on http.ClientException {
      throw const NetworkFailure();
    } on FormatException {
      throw const DataFailure();
    }
  }
}
