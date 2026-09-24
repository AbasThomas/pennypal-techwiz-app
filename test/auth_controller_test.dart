import 'package:bootstrap_flutter/features/auth/data/models/auth_user.dart';
import 'package:bootstrap_flutter/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:bootstrap_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts initial and becomes unauthenticated with no session', () async {
    final controller = AuthController(_FakeRepository());
    expect(controller.state.status, AuthStatus.initial);
    await controller.initialize();
    expect(controller.state.status, AuthStatus.unauthenticated);
  });
}

class _FakeRepository implements AuthGateway {
  @override
  Future<AuthUser?> restoreSession() async => null;
  @override Future<AuthUser> login({required String email, required String password}) async => throw UnimplementedError();
  @override Future<AuthUser> register(Map<String, dynamic> data) async => throw UnimplementedError();
  @override Future<void> logout() async {}
}
