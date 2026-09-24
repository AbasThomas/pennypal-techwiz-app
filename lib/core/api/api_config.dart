import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConfig {
  static String get baseUrl {
    const dartDefine = String.fromEnvironment('API_BASE_URL');
    if (dartDefine.isNotEmpty) return dartDefine;
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
  }

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}
