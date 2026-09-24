import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/api_error_handler.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../providers/auth_providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});
  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _loading = false;
  Future<void> _resend() async {
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).resendVerification();
      if (mounted) AppSnackbar.success(context, 'Verification email sent.');
    } catch (e) {
      if (mounted) AppSnackbar.error(context, ApiErrorHandler.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return AppScaffold(
      title: 'Verify email',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mark_email_unread_outlined, size: 52),
          const SizedBox(height: 20),
          Text(
            'Check your inbox',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We sent verification instructions to ${user?.email ?? 'your email address'}.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Resend verification email',
            loading: _loading,
            onPressed: _resend,
          ),
        ],
      ),
    );
  }
}
