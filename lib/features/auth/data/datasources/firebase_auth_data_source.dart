import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/auth_user.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._auth, this._db, [FirebaseStorage? storage])
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  Future<AuthUser> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final profile = await _profile(credential.user!);
    if (profile.isDeactivated == true) {
      await _auth.signOut();
      throw const AppException(
        'This account has been deactivated. Please contact support.',
      );
    }
    return profile;
  }

  Future<AuthUser> register(Map<String, dynamic> data) async {
    final c = await _auth.createUserWithEmailAndPassword(
      email: data['email'],
      password: data['password'],
    );
    await c.user!.updateDisplayName(data['fullName']);
    final userMap = {
      'email': data['email'],
      'fullName': data['fullName'],
      'phoneNumber': data['phoneNumber'],
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
      'isDeactivated': false,
    };
    await _db.collection('users').doc(c.user!.uid).set(userMap);
    await _db.collection('userProfiles').doc(c.user!.uid).set({
      'userId': c.user!.uid,
      ...userMap,
    });
    await c.user!.sendEmailVerification();
    return _profile(c.user!);
  }

  Future<AuthUser?> restore() async =>
      _auth.currentUser == null ? null : _profile(_auth.currentUser!);

  Future<AuthUser> _profile(User user) async {
    // Prefer the detailed profile, but fall back to `users` so a manually
    // promoted administrator is recognised whichever account document was
    // updated in the Firebase console.
    final profileDoc =
        await _db.collection('userProfiles').doc(user.uid).get();
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final v = <String, dynamic>{
      ...?userDoc.data(),
      ...?profileDoc.data(),
    };
    // Visible in `flutter run` logs and useful when configuring an admin.
    debugPrint('PennyPal auth role for ${user.uid}: ${v['role'] ?? 'student'}');
    final names = (v['fullName'] ?? user.displayName ?? '')
        .toString()
        .trim()
        .split(RegExp(r'\s+'));

    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      firstName: names.isEmpty ? '' : names.first,
      lastName: names.length > 1 ? names.skip(1).join(' ') : '',
      isEmailVerified: user.emailVerified,
      role: (v['role'] ?? 'student').toString().trim().toLowerCase(),
      phoneNumber: v['phoneNumber'] as String?,
      photoUrl: (v['photoUrl'] ?? user.photoURL) as String?,
      institution: v['institution'] as String?,
      bio: v['bio'] as String?,
      isDeactivated: v['isDeactivated'] == true,
    );
  }

  Future<AuthUser> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? institution,
    String? bio,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No active user found to update profile.');
    }

    final fullName = [firstName, lastName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();

    if (fullName.isNotEmpty) {
      await user.updateDisplayName(fullName);
    }
    if (photoUrl != null && photoUrl.isNotEmpty) {
      await user.updatePhotoURL(photoUrl);
    }

    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      if (fullName.isNotEmpty) 'fullName': fullName,
      'firstName': ?firstName,
      'lastName': ?lastName,
      'phoneNumber': ?phoneNumber,
      'institution': ?institution,
      'bio': ?bio,
      'photoUrl': ?photoUrl,
    };

    await _db
        .collection('userProfiles')
        .doc(user.uid)
        .set(updateData, SetOptions(merge: true));
    await _db
        .collection('users')
        .doc(user.uid)
        .set(updateData, SetOptions(merge: true));

    return _profile(user);
  }

  Future<AuthUser> uploadProfilePictureFile(File file) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No active user found to upload profile picture.');
    }

    final ref = _storage
        .ref()
        .child('profile_pictures')
        .child(user.uid)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return updateProfile(photoUrl: downloadUrl);
  }

  Future<AuthUser> uploadProfilePictureBytes(
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No active user found to upload profile picture.');
    }

    final ref = _storage
        .ref()
        .child('profile_pictures')
        .child(user.uid)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return updateProfile(photoUrl: downloadUrl);
  }

  Future<void> deactivateAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      final deactData = {
        'isDeactivated': true,
        'status': 'deactivated',
        'deactivatedAt': FieldValue.serverTimestamp(),
      };
      await _db
          .collection('userProfiles')
          .doc(user.uid)
          .set(deactData, SetOptions(merge: true));
      await _db
          .collection('users')
          .doc(user.uid)
          .set(deactData, SetOptions(merge: true));
      await _auth.signOut();
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;

      // Clean up Firestore data
      try {
        await _db.collection('userProfiles').doc(uid).delete();
      } catch (_) {}
      try {
        await _db.collection('users').doc(uid).delete();
      } catch (_) {}

      // Delete user from Firebase Auth
      await user.delete();
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AppException(
        'No active user found. Please sign in again.',
      );
    }
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw const AppException(
        'This account has no email address to verify against.',
      );
    }

    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw const AppException('Your current password is incorrect.');
      }
      rethrow;
    }

    await user.updatePassword(newPassword);
  }

  Future<void> forgot(String email) => _auth.sendPasswordResetEmail(email: email);
  Future<void> verifyEmail() => _auth.currentUser!.sendEmailVerification();
}
