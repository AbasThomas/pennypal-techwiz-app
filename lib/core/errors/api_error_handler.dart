import 'package:dio/dio.dart';

import 'app_exception.dart';

abstract final class ApiErrorHandler {
  static AppException from(Object error) {
    if (error is AppException) return error;
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      final message = _message(data);
      final fields = _fieldErrors(data);
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return const AppException('The request timed out. Please try again.');
      }
      if (error.type == DioExceptionType.connectionError) {
        return const AppException(
          'Unable to reach the server. Check your connection.',
        );
      }
      return AppException(
        message ?? _defaultMessage(status),
        statusCode: status,
        fieldErrors: fields,
      );
    }
    return const AppException('Something went wrong. Please try again.');
  }

  static String? _message(dynamic data) {
    if (data is Map) {
      final value = data['message'] ?? data['error'];
      if (value is List) return value.join('\n');
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static Map<String, String> _fieldErrors(dynamic data) {
    if (data is! Map || data['errors'] is! Map) return const {};
    return Map<String, String>.fromEntries(
      (data['errors'] as Map).entries.map(
        (entry) => MapEntry(entry.key.toString(), entry.value.toString()),
      ),
    );
  }

  static String _defaultMessage(int? status) => switch (status) {
    400 => 'The request was invalid. Please check your details.',
    401 => 'Your session has expired. Please sign in again.',
    403 => 'You do not have permission to do that.',
    404 => 'The requested resource was not found.',
    409 => 'This conflicts with existing information.',
    422 => 'Please correct the highlighted information.',
    500 ||
    501 ||
    502 ||
    503 => 'The server is unavailable. Please try again later.',
    _ => 'Something went wrong. Please try again.',
  };
}
