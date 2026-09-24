import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _token = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  bool _loading = false, _done = false;
  @override
  void dispose() {
    _token.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword({
        'token': _token.text.trim(),
        'password': _password.text,
      });
      if (mounted) setState(() => _done = true);
    } catch (e) {
      if (mounted) AppSnackbar.error(context, ApiErrorHandler.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Choose a new password',
    body: _done
        ? const AppEmptyState(
            icon: Icons.check_circle_outline,
            message: 'Your password has been reset. You can now sign in.',
          )
        : Form(
            key: _form,
            child: ListView(
              children: [
                const Text(
                  'The token field supports API contracts that use a reset token. It can be prefilled from a deep link later.',
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _token,
                  label: 'Reset token',
                  validator: (v) =>
                      Validators.required(v, label: 'Reset token'),
                ),
                const SizedBox(height: 16),
                AppPasswordField(
                  controller: _password,
                  label: 'New password',
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                AppPasswordField(
                  controller: _confirm,
                  label: 'Confirm new password',
                  validator: (v) =>
                      Validators.confirmPassword(v, _password.text),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Reset password',
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
  );
}
