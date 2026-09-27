import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_config.dart';
import '../../../../core/errors/app_exception.dart';

final groqChatServiceProvider = Provider<GroqChatService>(
  (ref) => GroqChatService(
    Dio(
      BaseOptions(
        baseUrl: 'https://api.groq.com/openai/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Content-Type': 'application/json'},
      ),
    ),
  ),
);

class GroqChatMessage {
  const GroqChatMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class GroqChatService {
  GroqChatService(this._dio);

  final Dio _dio;

  static const _models = [
    'openai/gpt-oss-120b',
    'openai/gpt-oss-20b',
    'qwen/qwen3.8-27b',
  ];

  Future<String> send(List<GroqChatMessage> messages) async {
    final key = ApiConfig.groqApiKey;
    if (key == null) {
      throw const AppException(
        'PennyPal AI is not configured yet. Add GROQ_API_KEY to your .env file.',
      );
    }

    DioException? lastError;
    for (final model in _models) {
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '/chat/completions',
          options: Options(headers: {'Authorization': 'Bearer $key'}),
          data: {
            'model': model,
            'messages': messages.map((m) => m.toJson()).toList(),
            'temperature': 0.6,
            'max_tokens': 512,
          },
        );
        final choices = response.data?['choices'];
        if (choices is List && choices.isNotEmpty) {
          final first = choices.first;
          if (first is Map) {
            final message = first['message'];
            if (message is Map) {
              final content = message['content'];
              if (content is String && content.trim().isNotEmpty) {
                return content.trim();
              }
            }
          }
        }
        throw const AppException('The AI returned an unexpected response.');
      } on DioException catch (error) {
        lastError = error;
        if (!_shouldTryFallback(error)) {
          throw AppException(_dioErrorMessage(error));
        }
      }
    }

    throw AppException(_dioErrorMessage(lastError!));
  }

  static bool _shouldTryFallback(DioException error) {
    return switch (error.response?.statusCode) {
      400 || 404 || 429 || 500 || 502 || 503 => true,
      _ => false,
    };
  }

  String _dioErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'The AI is taking too long to respond. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Check your network and try again.';
    }
    final data = e.response?.data;
    String? serverMessage;
    if (data is Map && data['error'] is Map) {
      serverMessage = (data['error']['message'])?.toString();
    }
    return switch (e.response?.statusCode) {
      401 =>
        'The AI service key is invalid. Check GROQ_API_KEY in your .env file.',
      403 => 'The AI service refused the request. Please try again.',
      429 => 'The AI is busy right now. Please try again in a moment.',
      503 || 502 =>
        'The AI service is temporarily unavailable. Please try again shortly.',
      _ =>
        serverMessage ??
            'Something went wrong while contacting the AI. Please try again.',
    };
  }
}
