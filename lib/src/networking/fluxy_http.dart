import 'dart:convert';
import 'dart:io';
import 'dart:async';

/// The core networking engine for Fluxy.
/// A zero-dependency, high-performance HTTP client.
class FluxyHttp {
  static String? _baseUrl;
  static final List<FluxyInterceptor> _interceptors = [];
  static Duration _timeout = const Duration(seconds: 30);
  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Configure the global HTTP client.
  static void configure({
    String? baseUrl,
    Duration? timeout,
    Map<String, String>? headers,
    List<FluxyInterceptor>? interceptors,
  }) {
    if (baseUrl != null) _baseUrl = baseUrl;
    if (timeout != null) _timeout = timeout;
    if (headers != null) _headers.addAll(headers);
    if (interceptors != null) _interceptors.addAll(interceptors);
  }

  /// Perform a GET request.
  Future<FxResponse> get(String path, {Map<String, String>? headers, Map<String, dynamic>? query}) =>
      _request('GET', path, headers: headers, query: query);

  /// Perform a POST request.
  Future<FxResponse> post(String path, {dynamic body, Map<String, String>? headers}) =>
      _request('POST', path, body: body, headers: headers);

  /// Perform a PUT request.
  Future<FxResponse> put(String path, {dynamic body, Map<String, String>? headers}) =>
      _request('PUT', path, body: body, headers: headers);

  /// Perform a DELETE request.
  Future<FxResponse> delete(String path, {Map<String, String>? headers}) =>
      _request('DELETE', path, headers: headers);

  Future<FxResponse> _request(
    String method,
    String path, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = _timeout;

    try {
      final uri = _buildUri(path, query);
      var requestHeaders = {..._headers, ...?headers};

      // 1. Request Interceptors
      var req = FxRequest(
        method: method,
        uri: uri,
        headers: requestHeaders,
        body: body,
      );

      for (var interceptor in _interceptors) {
        req = await interceptor.onRequest(req);
      }

      final request = await client.openUrl(req.method, req.uri);
      
      // Apply headers from interceptors/args
      req.headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      if (req.body != null) {
        final encodedBody = jsonEncode(req.body);
        request.write(encodedBody);
      }

      final response = await request.close().timeout(_timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      
      dynamic decodedData;
      try {
        decodedData = jsonDecode(responseBody);
      } catch (_) {
        decodedData = responseBody;
      }

      var fxResponse = FxResponse(
        statusCode: response.statusCode,
        data: decodedData,
        headers: _extractHeaders(response.headers),
        request: req,
      );

      // 2. Response Interceptors
      for (var interceptor in _interceptors) {
        fxResponse = await interceptor.onResponse(fxResponse);
      }

      if (fxResponse.statusCode >= 400) {
        throw FxHttpException(
          message: 'HTTP ${fxResponse.statusCode}',
          response: fxResponse,
        );
      }

      return fxResponse;
    } on TimeoutException {
      throw FxHttpException(message: 'Request Timeout', isTimeout: true);
    } catch (e) {
      if (e is FxHttpException) rethrow;
      throw FxHttpException(message: e.toString());
    } finally {
      client.close();
    }
  }

  static Uri _buildUri(String path, Map<String, dynamic>? query) {
    var url = path;
    if (_baseUrl != null && !path.startsWith('http')) {
      url = _baseUrl!.endsWith('/') ? '$_baseUrl$path' : '$_baseUrl/$path';
    }
    
    final uri = Uri.parse(url);
    if (query != null && query.isNotEmpty) {
      return uri.replace(queryParameters: query.map((k, v) => MapEntry(k, v.toString())));
    }
    return uri;
  }

  static Map<String, String> _extractHeaders(HttpHeaders headers) {
    final Map<String, String> map = {};
    headers.forEach((name, values) {
      map[name] = values.join(', ');
    });
    return map;
  }
}

/// Represents an HTTP Request in Fluxy.
class FxRequest {
  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final dynamic body;

  FxRequest({
    required this.method,
    required this.uri,
    required this.headers,
    this.body,
  });

  FxRequest copyWith({
    String? method,
    Uri? uri,
    Map<String, String>? headers,
    dynamic body,
  }) => FxRequest(
    method: method ?? this.method,
    uri: uri ?? this.uri,
    headers: headers ?? this.headers,
    body: body ?? this.body,
  );
}

/// Represents an HTTP Response in Fluxy.
class FxResponse {
  final int statusCode;
  final dynamic data;
  final Map<String, String> headers;
  final FxRequest request;

  FxResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
    required this.request,
  });
}

/// Base class for Fluxy HTTP Interceptors.
abstract class FluxyInterceptor {
  Future<FxRequest> onRequest(FxRequest request) async => request;
  Future<FxResponse> onResponse(FxResponse response) async => response;
}

/// Specialized exception for Fluxy Networking.
class FxHttpException implements Exception {
  final String message;
  final FxResponse? response;
  final bool isTimeout;

  FxHttpException({required this.message, this.response, this.isTimeout = false});

  @override
  String toString() => 'FxHttpException: $message';
}
