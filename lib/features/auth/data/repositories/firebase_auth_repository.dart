import 'dart:io';
import 'dart:typed_data';
import '../datasources/firebase_auth_data_source.dart';
import '../models/auth_user.dart';

abstract interface class AuthGateway {
  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> register(Map<String, dynamic> data);
  Future<AuthUser?> restoreSession();
  Future<void> logout();
  Future<AuthUser> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? institution,
    String? bio,
    String? photoUrl,
  });
  Future<AuthUser> uploadProfilePictureFile(File file);
  Future<AuthUser> uploadProfilePictureBytes(
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  });
  Future<void> deactivateAccount();
  Future<void> deleteAccount();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class FirebaseAuthRepository implements AuthGateway {
  FirebaseAuthRepository(this._source);
  final FirebaseAuthDataSource _source;

  @override
  Future<AuthUser> login({required String email, required String password}) =>
      _source.login(email, password);

  @override
  Future<AuthUser> register(Map<String, dynamic> data) =>
      _source.register(data);

  @override
  Future<AuthUser?> restoreSession() => _source.restore();

  @override
  Future<void> logout() => _source.logout();

  @override
  Future<AuthUser> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? institution,
    String? bio,
    String? photoUrl,
  }) => _source.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        institution: institution,
        bio: bio,
        photoUrl: photoUrl,
      );

  @override
  Future<AuthUser> uploadProfilePictureFile(File file) =>
      _source.uploadProfilePictureFile(file);

  @override
  Future<AuthUser> uploadProfilePictureBytes(
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) => _source.uploadProfilePictureBytes(bytes, contentType: contentType);

  @override
  Future<void> deactivateAccount() => _source.deactivateAccount();

  @override
  Future<void> deleteAccount() => _source.deleteAccount();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _source.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  Future<void> forgotPassword(String email) => _source.forgot(email);
  Future<void> resendVerification() => _source.verifyEmail();
  Future<void> resetPassword(Map<String, dynamic> data) => Future.error(
        UnsupportedError(
          'Firebase reset links are handled by Firebase email action links.',
        ),
      );
}
