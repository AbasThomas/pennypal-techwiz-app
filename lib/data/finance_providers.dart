import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/providers/auth_providers.dart';
import 'models/financial_models.dart';
import 'repositories/finance_repository.dart';

final financeRepositoryProvider = Provider<FinanceRepository>(
  (ref) =>
      FinanceRepository(FirebaseFirestore.instance, FirebaseStorage.instance),
);

final transactionsProvider = StreamProvider<List<FinanceTransaction>>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  return uid == null
      ? Stream.value([])
      : ref.watch(financeRepositoryProvider).transactions(uid);
});
final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  return uid == null
      ? Stream.value([])
      : ref.watch(financeRepositoryProvider).budgets(uid);
});
final savingsGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  return uid == null
      ? Stream.value([])
      : ref.watch(financeRepositoryProvider).goals(uid);
});

final notificationsProvider =
    StreamProvider<List<QueryDocumentSnapshot<Map<String, dynamic>>>>((ref) {
      final uid = ref.watch(currentUserProvider)?.id;
      if (uid == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .snapshots()
          .map((s) {
        final docs = s.docs.toList();
        docs.sort((a, b) {
          final aTime = a.data()['createdAt'] as Timestamp?;
          final bTime = b.data()['createdAt'] as Timestamp?;
          return (bTime?.millisecondsSinceEpoch ?? 0)
              .compareTo(aTime?.millisecondsSinceEpoch ?? 0);
        });
        return docs;
      });
    });
