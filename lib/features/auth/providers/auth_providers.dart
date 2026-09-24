import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/datasources/firebase_auth_data_source.dart';
import '../data/repositories/firebase_auth_repository.dart';
import '../presentation/controllers/auth_controller.dart';

final authRepositoryProvider = Provider<FirebaseAuthRepository>((ref) => FirebaseAuthRepository(FirebaseAuthDataSource(FirebaseAuth.instance, FirebaseFirestore.instance)));
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);
final currentUserProvider = Provider(
  (ref) => ref.watch(authControllerProvider).user,
);
