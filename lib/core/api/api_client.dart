import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../storage/auth_storage.dart';
import 'api_config.dart';

class ApiClient {
  ApiClient({required this.storage, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              headers: const {'Content-Type': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(_AuthenticationInterceptor(_dio, storage));
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  final Dio _dio;
  final AuthStorage storage;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _dio.get<T>(path, queryParameters: queryParameters);
  Future<Response<T>> post<T>(String path, {Object? data, Options? options}) =>
      _dio.post<T>(path, data: data, options: options);
}

class _AuthenticationInterceptor extends Interceptor {
  _AuthenticationInterceptor(this._dio, this._storage);
  final Dio _dio;
  final AuthStorage _storage;
  Completer<bool>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    if (error.response?.statusCode != 401 ||
        request.extra['skipAuth'] == true ||
        request.extra['retried'] == true) {
      return handler.next(error);
    }
    final refreshed = await _refresh();
    if (!refreshed) {
      return handler.next(error);
    }
    try {
      final token = await _storage.getAccessToken();
      request.headers['Authorization'] = 'Bearer $token';
      request.extra['retried'] = true;
      final response = await _dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refresh() async {
    if (_refreshing != null) {
      return _refreshing!.future;
    }
    _refreshing = Completer<bool>();
    final completer = _refreshing!;
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw StateError('No refresh token');
      }
      final response = await _dio.post<dynamic>(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
        options: Options(extra: const {'skipAuth': true}),
      );
      final data = response.data as Map?;
      final access = data?['accessToken'] as String?;
      final refresh = data?['refreshToken'] as String? ?? refreshToken;
      if (access == null || access.isEmpty) {
        throw StateError('Invalid refresh response');
      }
      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      completer.complete(true);
    } catch (_) {
      await _storage.clearTokens();
      completer.complete(false);
    } finally {
      scheduleMicrotask(() {
        if (identical(_refreshing, completer)) {
          _refreshing = null;
        }
      });
    }
    return completer.future;
  }
}
