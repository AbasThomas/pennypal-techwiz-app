import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConfig {
  static String get baseUrl {
    const dartDefine = String.fromEnvironment('API_BASE_URL');
    if (dartDefine.isNotEmpty) return dartDefine;
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
  }

  /// Groq API key — supply via `--dart-define=GROQ_API_KEY=...` or a
  /// `GROQ_API_KEY=` line in `.env`. Null when not configured.
  static String? get groqApiKey {
    const dartDefine = String.fromEnvironment('GROQ_API_KEY');
    if (dartDefine.isNotEmpty) return dartDefine;
    final env = dotenv.env['GROQ_API_KEY'];
    if (env == null || env.trim().isEmpty) return null;
    return env.trim();
  }

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}
