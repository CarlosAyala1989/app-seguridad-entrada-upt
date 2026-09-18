import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../error/failure.dart';
import '../../shared/l10n/app_strings.dart';

final class HttpResponseData {
  const HttpResponseData({required this.statusCode, this.body});

  final int statusCode;
  final Map<String, Object?>? body;
}

abstract interface class HttpGateway {
  Future<HttpResponseData> get(
    String path, {
    Map<String, String> headers = const {},
  });

  Future<HttpResponseData> post(
    String path, {
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
  });
}

final class IoHttpGateway implements HttpGateway {
  IoHttpGateway({
    required String baseUrl,
    this.timeout = const Duration(seconds: 8),
  }) : _baseUri = Uri.parse(baseUrl);

  final Uri _baseUri;
  final Duration timeout;

  @override
  Future<HttpResponseData> get(
    String path, {
    Map<String, String> headers = const {},
  }) {
    return _send('GET', path, headers: headers);
  }

  @override
  Future<HttpResponseData> post(
    String path, {
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
  }) {
    return _send('POST', path, headers: headers, body: body);
  }

  Future<HttpResponseData> _send(
    String method,
    String path, {
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = timeout;

    try {
      final uri = _baseUri.resolve(path);
      final request = await client.openUrl(method, uri).timeout(timeout);
      headers.forEach(request.headers.set);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      if (body != null) {
        final encodedBody = utf8.encode(jsonEncode(body));
        request.headers.set(
          HttpHeaders.contentTypeHeader,
          'application/json; charset=utf-8',
        );
        request.headers.contentLength = encodedBody.length;
        request.add(encodedBody);
      }

      final response = await request.close().timeout(timeout);
      final rawBody = await utf8.decoder.bind(response).join().timeout(timeout);
      Map<String, Object?>? decodedBody;

      if (rawBody.trim().isNotEmpty) {
        final decoded = jsonDecode(rawBody);
        if (decoded is! Map<String, dynamic>) {
          throw const DataFailure();
        }
        decodedBody = decoded.cast<String, Object?>();
      }

      return HttpResponseData(
        statusCode: response.statusCode,
        body: decodedBody,
      );
    } on Failure {
      rethrow;
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure(AppStrings.timeoutError);
    } on FormatException {
      throw const DataFailure();
    } finally {
      client.close(force: true);
    }
  }
}
