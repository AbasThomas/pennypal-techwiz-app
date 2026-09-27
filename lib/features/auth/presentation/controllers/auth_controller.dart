import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_error_handler.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/firebase_auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    bool clearError = false,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState());
  final AuthGateway _repository;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    state = const AuthState(status: AuthStatus.loading);
    final user = await _repository.restoreSession();
    state = user == null
        ? const AuthState(status: AuthStatus.unauthenticated)
        : AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<bool> login({required String email, required String password}) =>
      _authenticate(() => _repository.login(email: email, password: password));

  Future<bool> register(Map<String, dynamic> data) =>
      _authenticate(() => _repository.register(data));

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? institution,
    String? bio,
    String? photoUrl,
  }) async {
    try {
      final updatedUser = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        institution: institution,
        bio: bio,
        photoUrl: photoUrl,
      );
      state = state.copyWith(user: updatedUser);
      return true;
    } catch (error) {
      state = state.copyWith(
        errorMessage: ApiErrorHandler.from(error).message,
      );
      return false;
    }
  }

  Future<bool> uploadProfilePictureFile(File file) async {
    try {
      final updatedUser = await _repository.uploadProfilePictureFile(file);
      state = state.copyWith(user: updatedUser);
      return true;
    } catch (error) {
      state = state.copyWith(
        errorMessage: ApiErrorHandler.from(error).message,
      );
      return false;
    }
  }

  Future<bool> uploadProfilePictureBytes(
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    try {
      final updatedUser = await _repository.uploadProfilePictureBytes(
        bytes,
        contentType: contentType,
      );
      state = state.copyWith(user: updatedUser);
      return true;
    } catch (error) {
      state = state.copyWith(
        errorMessage: ApiErrorHandler.from(error).message,
      );
      return false;
    }
  }

  Future<bool> deactivateAccount() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await _repository.deactivateAccount();
      state = const AuthState(status: AuthStatus.unauthenticated);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: ApiErrorHandler.from(error).message,
      );
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await _repository.deleteAccount();
      state = const AuthState(status: AuthStatus.unauthenticated);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: ApiErrorHandler.from(error).message,
      );
      return false;
    }
  }

  Future<bool> _authenticate(Future<AuthUser> Function() action) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final user = await action();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (error) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: ApiErrorHandler.from(error).message,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState(status: AuthStatus.loading);
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
