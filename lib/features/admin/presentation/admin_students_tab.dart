import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';

class AdminStudentsTab extends StatefulWidget {
  const AdminStudentsTab({super.key});

  @override
  State<AdminStudentsTab> createState() => _AdminStudentsTabState();
}

class _AdminStudentsTabState extends State<AdminStudentsTab> {
  String _query = '';
  String _filter = 'all';

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              style: const TextStyle(color: PennyPalColors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name, email or phone',
                hintStyle: const TextStyle(color: PennyPalColors.muted),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: AppIcon(AppIcons.search, color: PennyPalColors.gray, size: 18),
                ),
                filled: true,
                fillColor: PennyPalColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PennyPalColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PennyPalColors.border),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final f in [('all', 'All'), ('active', 'Active'), ('deactivated', 'Deactivated')])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f.$2, style: TextStyle(fontSize: 12, color: _filter == f.$1 ? PennyPalColors.black : PennyPalColors.gray)),
                      selected: _filter == f.$1,
                      selectedColor: PennyPalColors.white,
                      backgroundColor: PennyPalColors.surface,
                      side: const BorderSide(color: PennyPalColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) => setState(() => _filter = f.$1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('userProfiles')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (_, s) {
                if (s.hasError) {
                  return Center(child: Text('Could not load students: ${s.error}', style: const TextStyle(color: PennyPalColors.gray)));
                }
                if (!s.hasData) return const Center(child: CircularProgressIndicator());
                final docs = s.data!.docs.where((d) {
                  final data = d.data();
                  final deactivated = data['isDeactivated'] == true;
                  if (_filter == 'active' && deactivated) return false;
                  if (_filter == 'deactivated' && !deactivated) return false;
                  if (_query.isEmpty) return true;
                  return '${data['fullName'] ?? ''}'.toLowerCase().contains(_query) ||
                      '${data['email'] ?? ''}'.toLowerCase().contains(_query) ||
                      '${data['phoneNumber'] ?? ''}'.toLowerCase().contains(_query);
                }).toList();
                if (docs.isEmpty) {
                  return const Center(child: Text('No students found.', style: TextStyle(color: PennyPalColors.gray)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: docs.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _studentTile(docs[i]),
                );
              },
            ),
          ),
        ],
      );

  Widget _studentTile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final name = '${data['fullName'] ?? 'Unnamed'}';
    final deactivated = data['isDeactivated'] == true;
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join();
    return Material(
      color: PennyPalColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetail(doc),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PennyPalColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: PennyPalColors.elevated,
                child: Text(initials, style: const TextStyle(color: PennyPalColors.white, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: PennyPalColors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${data['email'] ?? ''}', style: const TextStyle(color: PennyPalColors.gray, fontSize: 12)),
                  ],
                ),
              ),
              _statusChip(deactivated),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(bool deactivated) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: deactivated ? PennyPalColors.dangerSurface : PennyPalColors.successSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          deactivated ? 'Deactivated' : 'Active',
          style: TextStyle(color: deactivated ? PennyPalColors.danger : PennyPalColors.success, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );

  Future<void> _showDetail(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    final deactivated = data['isDeactivated'] == true;
    final isSelf = doc.id == FirebaseAuth.instance.currentUser?.uid;
    final isAdminAccount = '${data['role'] ?? ''}'.toLowerCase() == 'admin';
    final joined = _formatDate(data['createdAt']);
    await showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('${data['fullName'] ?? 'Student'}', style: const TextStyle(color: PennyPalColors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(AppIcons.mail, 'Email', '${data['email'] ?? '—'}'),
              _detailRow(AppIcons.user, 'Role', '${data['role'] ?? 'student'}'),
              _detailRow(AppIcons.calendar, 'Joined', joined),
              _detailRow(AppIcons.info, 'Phone', '${data['phoneNumber'] ?? '—'}'),
              _detailRow(AppIcons.education, 'Institution', '${data['institution'] ?? '—'}'),
              _detailRow(AppIcons.info, 'Status', deactivated ? 'Deactivated' : 'Active'),
              const SizedBox(height: 8),
              Text('User ID: ${doc.id}', style: const TextStyle(color: PennyPalColors.muted, fontSize: 11)),
              if (isAdminAccount)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Administrator accounts cannot be managed here.', style: TextStyle(color: PennyPalColors.lightGray, fontSize: 12)),
                ),
            ],
          ),
        ),
        actions: [
          if (!isSelf && !isAdminAccount) ...[
            TextButton(
              onPressed: () async {
                Navigator.pop(d);
                await _setDeactivated(doc.id, !deactivated);
              },
              child: Text(deactivated ? 'Reactivate' : 'Deactivate', style: TextStyle(color: deactivated ? PennyPalColors.success : PennyPalColors.danger)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(d);
                _confirmDelete(doc);
              },
              child: const Text('Delete', style: TextStyle(color: PennyPalColors.danger)),
            ),
          ],
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailRow(List<List<dynamic>> icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(icon, color: PennyPalColors.gray, size: 16),
            const SizedBox(width: 10),
            SizedBox(
              width: 90,
              child: Text(label, style: const TextStyle(color: PennyPalColors.gray, fontSize: 13)),
            ),
            Expanded(child: Text(value, style: const TextStyle(color: PennyPalColors.white, fontSize: 13))),
          ],
        ),
      );

  Future<void> _setDeactivated(String uid, bool value) async {
    final update = {'isDeactivated': value, 'updatedAt': FieldValue.serverTimestamp()};
    final batch = FirebaseFirestore.instance.batch();
    batch.set(FirebaseFirestore.instance.collection('userProfiles').doc(uid), update, SetOptions(merge: true));
    batch.set(FirebaseFirestore.instance.collection('users').doc(uid), update, SetOptions(merge: true));
    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? 'Student deactivated.' : 'Student reactivated.'), backgroundColor: PennyPalColors.elevated),
      );
    }
  }

  Future<void> _confirmDelete(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final name = '${doc.data()['fullName'] ?? 'this student'}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Delete student?', style: TextStyle(color: PennyPalColors.white)),
        content: Text(
          'This permanently removes $name\'s profile and account data from Firestore. Their login account still exists in Firebase Authentication and must be removed from the Firebase console.',
          style: const TextStyle(color: PennyPalColors.gray, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Delete', style: TextStyle(color: PennyPalColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final batch = FirebaseFirestore.instance.batch();
    batch.delete(FirebaseFirestore.instance.collection('userProfiles').doc(doc.id));
    batch.delete(FirebaseFirestore.instance.collection('users').doc(doc.id));
    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student data deleted. Remove the auth user from the Firebase console.'), backgroundColor: PennyPalColors.elevated),
      );
    }
  }

  String _formatDate(dynamic v) {
    final dt = switch (v) {
      Timestamp t => t.toDate(),
      DateTime t => t,
      _ => null,
    };
    return dt == null ? '—' : DateFormat('d MMM yyyy').format(dt);
  }
}
