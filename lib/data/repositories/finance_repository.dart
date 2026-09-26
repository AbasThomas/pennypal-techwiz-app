import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/financial_models.dart';

/// Repository boundary: UI never calls Firestore or Storage directly.
class FinanceRepository {
  FinanceRepository(this._db, this._storage);
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  Stream<List<FinanceTransaction>> transactions(String uid) => _db
      .collection('transactions')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final items = s.docs.map(FinanceTransaction.fromDoc).toList();
        items.sort((a, b) => b.date.compareTo(a.date));
        return items;
      });
  Stream<List<Budget>> budgets(String uid) => _db
      .collection('budgets')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map(Budget.fromDoc).toList());
  Stream<List<SavingsGoal>> goals(String uid) => _db
      .collection('savingsGoals')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map(SavingsGoal.fromDoc).toList());
  Future<void> saveTransaction(FinanceTransaction item) async {
    final data = item.toMap()..['createdAt'] = FieldValue.serverTimestamp();
    await _db
        .collection('transactions')
        .doc(item.id.isEmpty ? null : item.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deleteTransaction(String id) =>
      _db.collection('transactions').doc(id).delete();
  Future<void> deleteBudget(String id) =>
      _db.collection('budgets').doc(id).delete();
  Future<void> deleteGoal(String id) =>
      _db.collection('savingsGoals').doc(id).delete();
  Future<void> submitFeedback(String uid, Map<String, dynamic> data) => _db
      .collection('feedback')
      .add({...data, 'userId': uid, 'createdAt': FieldValue.serverTimestamp()});
  Future<void> submitSupport(String uid, Map<String, dynamic> data) =>
      _db.collection('supportQueries').add({
        ...data,
        'userId': uid,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
  Future<void> markNotificationRead(String id) =>
      _db.collection('notifications').doc(id).update({'read': true});
  Future<void> saveBudget(Budget item) => _db
      .collection('budgets')
      .doc(item.id.isEmpty ? null : item.id)
      .set(
        item.toMap()..['createdAt'] = FieldValue.serverTimestamp(),
        SetOptions(merge: true),
      );
  Future<void> saveGoal(SavingsGoal item) => _db
      .collection('savingsGoals')
      .doc(item.id.isEmpty ? null : item.id)
      .set(
        item.toMap()..['createdAt'] = FieldValue.serverTimestamp(),
        SetOptions(merge: true),
      );
  Future<String> uploadReceipt(
    String uid,
    String filename,
    Uint8List bytes,
  ) async {
    final ref = _storage.ref(
      'receipts/$uid/${DateTime.now().microsecondsSinceEpoch}_$filename',
    );
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> addNotification(
    String uid, {
    required String title,
    required String body,
    required String type,
  }) => _db.collection('notifications').add({
    'userId': uid,
    'title': title,
    'body': body,
    'type': type,
    'read': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
