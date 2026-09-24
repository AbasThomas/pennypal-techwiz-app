import 'package:bootstrap_flutter/core/storage/auth_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('token storage contract saves, reads, and clears tokens', () async {
    final storage = _MemoryAuthStorage();
    expect(await storage.hasSession(), isFalse);
    await storage.saveTokens(accessToken: 'access', refreshToken: 'refresh');
    expect(await storage.getAccessToken(), 'access');
    expect(await storage.hasSession(), isTrue);
    await storage.clearTokens();
    expect(await storage.getRefreshToken(), isNull);
  });
}

class _MemoryAuthStorage implements AuthStorage {
  String? access;
  String? refresh;
  @override
  Future<void> clearTokens() async {
    access = null;
    refresh = null;
  }

  @override
  Future<String?> getAccessToken() async => access;
  @override
  Future<String?> getRefreshToken() async => refresh;
  @override
  Future<bool> hasSession() async => access != null && refresh != null;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }
}
