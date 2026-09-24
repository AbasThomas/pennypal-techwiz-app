import '../../../../core/storage/auth_storage.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_user.dart';

class AuthRepository {
  const AuthRepository(this._remote, this._storage);
  final AuthRemoteDataSource _remote;
  final AuthStorage _storage;

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final result = await _remote.login(email: email, password: password);
    await _storage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    return result.user;
  }

  Future<AuthUser> register(Map<String, dynamic> data) async {
    final result = await _remote.register(data);
    await _storage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    return result.user;
  }

  Future<AuthUser?> restoreSession() async {
    if (!await _storage.hasSession()) return null;
    try {
      return await _remote.me();
    } catch (_) {
      await _storage.clearTokens();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _remote.logout();
    } finally {
      await _storage.clearTokens();
    }
  }

  Future<void> forgotPassword(String email) => _remote.forgotPassword(email);
  Future<void> resetPassword(Map<String, dynamic> data) =>
      _remote.resetPassword(data);
  Future<void> verifyEmail(Map<String, dynamic> data) =>
      _remote.verifyEmail(data);
  Future<void> resendVerification() => _remote.resendVerification();
}
