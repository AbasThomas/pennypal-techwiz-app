import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../controllers/auth_controller.dart';
import '../../providers/auth_providers.dart';

class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final loading =
        ref.watch(authControllerProvider).status == AuthStatus.loading;
    return AppScaffold(
      title: 'Home',
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 52),
            const SizedBox(height: 16),
            Text(
              'Authentication succeeded',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(user?.email ?? ''),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: loading
                  ? null
                  : () => ref.read(authControllerProvider.notifier).logout(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
