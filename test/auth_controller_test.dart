import 'dart:io';
import 'dart:typed_data';
import 'package:pennypal/features/auth/data/models/auth_user.dart';
import 'package:pennypal/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:pennypal/features/auth/presentation/controllers/auth_controller.dart';
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
  @override Future<AuthUser> updateProfile({String? firstName, String? lastName, String? phoneNumber, String? institution, String? bio, String? photoUrl}) async => throw UnimplementedError();
  @override Future<AuthUser> uploadProfilePictureFile(File file) async => throw UnimplementedError();
  @override Future<AuthUser> uploadProfilePictureBytes(Uint8List bytes, {String contentType = 'image/jpeg'}) async => throw UnimplementedError();
  @override Future<void> deactivateAccount() async {}
  @override Future<void> deleteAccount() async {}
  @override Future<void> changePassword({required String currentPassword, required String newPassword}) async {}
}
