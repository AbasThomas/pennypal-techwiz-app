import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_exception.dart';

abstract final class ApiErrorHandler {
  static AppException from(Object error) {
    if (error is AppException) return error;
    if (error is FirebaseAuthException) {
      return AppException(_authMessage(error.code));
    }
    if (error is FirebaseException) {
      return AppException(_firebaseMessage(error.code));
    }
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

  static String _authMessage(String code) => switch (code) {
    'invalid-email' =>
      'That email address doesn\u2019t look right. Please check it and try again.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' ||
    'invalid-login-credentials' ||
    'account-exists-with-different-credential' =>
      'Incorrect email or password. Please try again.',
    'email-already-in-use' =>
      'An account already exists with this email. Sign in instead.',
    'weak-password' =>
      'That password is too weak. Use at least 8 characters with a mix of letters and numbers.',
    'user-disabled' =>
      'This account has been disabled. Please contact support.',
    'network-request-failed' =>
      'No internet connection. Check your network and try again.',
    'too-many-requests' =>
      'Too many attempts. Please wait a moment and try again.',
    'user-token-expired' ||
    'requires-recent-login' ||
    'credential-expired' =>
      'Your session has expired. Please sign in again.',
    'operation-not-allowed' =>
      'This sign-in method is not enabled. Please contact support.',
    _ => 'Something went wrong. Please try again.',
  };

  static String _firebaseMessage(String code) => switch (code) {
    'network-request-failed' || 'unavailable' || 'deadline-exceeded' =>
      'No internet connection. Check your network and try again.',
    'permission-denied' => 'You do not have permission to do that.',
    'not-found' => 'The requested information was not found.',
    _ => 'Something went wrong. Please try again.',
  };
}
