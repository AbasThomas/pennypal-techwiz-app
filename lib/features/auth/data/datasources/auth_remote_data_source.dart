import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/auth_storage.dart';
import 'package:dio/dio.dart';
import '../models/auth_user.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._api, this._storage);
  final ApiClient _api;
  final AuthStorage _storage;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async => _parseAuth(
    await _api.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    ),
  );

  Future<AuthResult> register(Map<String, dynamic> data) async =>
      _parseAuth(await _api.post(ApiEndpoints.register, data: data));

  Future<AuthUser> me() async {
    final response = await _api.get<dynamic>(ApiEndpoints.me);
    return AuthUser.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> forgotPassword(String email) =>
      _api.post(ApiEndpoints.forgotPassword, data: {'email': email});
  Future<void> resetPassword(Map<String, dynamic> data) =>
      _api.post(ApiEndpoints.resetPassword, data: data);
  Future<void> verifyEmail(Map<String, dynamic> data) =>
      _api.post(ApiEndpoints.verifyEmail, data: data);
  Future<void> resendVerification() =>
      _api.post(ApiEndpoints.resendVerification);
  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    await _api.post(
      ApiEndpoints.logout,
      data: refreshToken == null ? null : {'refreshToken': refreshToken},
      options: Options(extra: const {'skipAuth': true}),
    );
  }

  AuthResult _parseAuth(dynamic response) {
    final data = Map<String, dynamic>.from(response.data as Map);
    final userJson = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : data;
    return AuthResult(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: AuthUser.fromJson(userJson),
    );
  }
}

class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
  final String accessToken;
  final String refreshToken;
  final AuthUser user;
}
