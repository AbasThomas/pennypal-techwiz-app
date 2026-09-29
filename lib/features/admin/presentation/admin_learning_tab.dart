import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';

class AdminLearningTab extends StatelessWidget {
  const AdminLearningTab({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('learningContent')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (_, s) {
          if (s.hasError) {
            return Center(child: Text('Could not load learning content: ${s.error}', style: const TextStyle(color: PennyPalColors.gray)));
          }
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final docs = s.data!.docs;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Learning Content', style: TextStyle(color: PennyPalColors.white, fontSize: 25, fontWeight: FontWeight.w800))),
                  IconButton(
                    onPressed: () => _editContent(context, null),
                    icon: const AppIcon(AppIcons.add, color: PennyPalColors.white),
                    tooltip: 'Add content',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (docs.isEmpty)
                const Text('No content yet. Add your first article or guide.', style: TextStyle(color: PennyPalColors.gray))
              else
                for (final d in docs) _contentCard(context, d),
            ],
          );
        },
      );

  Widget _contentCard(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final title = '${data['title'] ?? 'Untitled'}';
    final category = '${data['category'] ?? ''}';
    final summary = '${data['summary'] ?? data['content'] ?? ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (category.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: PennyPalColors.elevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(category, style: const TextStyle(color: PennyPalColors.lightGray, fontSize: 11)),
                ),
              const Spacer(),
              IconButton(
                onPressed: () => _editContent(context, doc),
                icon: const AppIcon(AppIcons.edit, color: PennyPalColors.gray, size: 17),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _confirmDelete(context, doc),
                icon: const AppIcon(AppIcons.delete, color: PennyPalColors.danger, size: 17),
                tooltip: 'Delete',
              ),
            ],
          ),
          Text(title, style: const TextStyle(color: PennyPalColors.white, fontWeight: FontWeight.w700)),
          if (summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                summary.length > 140 ? '${summary.substring(0, 140)}…' : summary,
                style: const TextStyle(color: PennyPalColors.gray, fontSize: 12.5, height: 1.5),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editContent(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>>? doc) async {
    final title = TextEditingController(text: doc?.data()['title']?.toString() ?? '');
    final category = TextEditingController(text: doc?.data()['category']?.toString() ?? '');
    final summary = TextEditingController(text: doc?.data()['summary']?.toString() ?? '');
    final content = TextEditingController(text: doc?.data()['content']?.toString() ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(doc == null ? 'New content' : 'Edit content', style: const TextStyle(color: PennyPalColors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                style: const TextStyle(color: PennyPalColors.white),
                decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: PennyPalColors.gray)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: category,
                style: const TextStyle(color: PennyPalColors.white),
                decoration: const InputDecoration(labelText: 'Category (e.g. Budgeting, Saving)', labelStyle: TextStyle(color: PennyPalColors.gray)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: summary,
                maxLines: 2,
                style: const TextStyle(color: PennyPalColors.white),
                decoration: const InputDecoration(labelText: 'Summary', labelStyle: TextStyle(color: PennyPalColors.gray)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: content,
                minLines: 5,
                maxLines: 10,
                style: const TextStyle(color: PennyPalColors.white),
                decoration: const InputDecoration(labelText: 'Content', alignLabelWithHint: true, labelStyle: TextStyle(color: PennyPalColors.gray)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Save')),
        ],
      ),
    );
    if (saved == true && title.text.trim().isNotEmpty) {
      final data = <String, dynamic>{
        'title': title.text.trim(),
        'category': category.text.trim(),
        'summary': summary.text.trim(),
        'content': content.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (doc == null) {
        await FirebaseFirestore.instance.collection('learningContent').add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await doc.reference.set(data, SetOptions(merge: true));
      }
    }
    title.dispose();
    category.dispose();
    summary.dispose();
    content.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final title = '${doc.data()['title'] ?? 'this item'}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Delete content?', style: TextStyle(color: PennyPalColors.white)),
        content: Text('"$title" will be permanently removed. Students will no longer see it in the Learn section.', style: const TextStyle(color: PennyPalColors.gray, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Delete', style: TextStyle(color: PennyPalColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) await doc.reference.delete();
  }
}
