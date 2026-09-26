import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/finance_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              for (final n in ref.read(notificationsProvider).value ?? []) {
                if (n.data()['read'] != true)
                  await ref
                      .read(financeRepositoryProvider)
                      .markNotificationRead(n.id);
              }
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not load notifications: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(color: PennyPalColors.gray),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final doc = items[i];
                  final data = doc.data();
                  final read = data['read'] == true;
                  final timestamp = data['createdAt'];
                  final date = timestamp == null
                      ? 'Just now'
                      : DateFormat.yMMMd().add_jm().format(timestamp.toDate());
                  return ListTile(
                    onTap: () => ref
                        .read(financeRepositoryProvider)
                        .markNotificationRead(doc.id),
                    tileColor: PennyPalColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: Icon(
                      read ? Icons.notifications_none : Icons.notifications,
                      color: Colors.white,
                    ),
                    title: Text(
                      '${data['title'] ?? 'Notification'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: read ? FontWeight.w500 : FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      '${data['body'] ?? ''}\n$date',
                      style: const TextStyle(color: PennyPalColors.gray),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
