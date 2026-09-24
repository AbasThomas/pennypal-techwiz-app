import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';

/// Separate, role-guarded administration surface. Firestore rules enforce the role too.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('PennyPal Admin'), actions: [IconButton(tooltip: 'Sign out', onPressed: () => ref.read(authControllerProvider.notifier).logout(), icon: const Icon(Icons.logout))]),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      Text('Administration', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8), const Text('Manage the student experience and keep an eye on application activity.'), const SizedBox(height: 24),
      Wrap(spacing: 14, runSpacing: 14, children: const [
        ('Students', Icons.people_outline, 'Search users and review activity'), ('Transactions', Icons.receipt_long_outlined, 'Monitor financial usage summaries'), ('Learning content', Icons.menu_book_outlined, 'Create, edit, deactivate, and publish lessons'), ('Support', Icons.support_agent_outlined, 'Respond and change query status'), ('Feedback', Icons.forum_outlined, 'Review student feedback'), ('Analytics', Icons.insights_outlined, 'Activity, categories, budgets, and savings')
      ].map((item) => SizedBox(width: 270, child: Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 25, child: Icon(item.$2, size: 28)), const SizedBox(height: 18), Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), const SizedBox(height: 6), Text(item.$3)]))))).toList())
    ]),
  );
}
