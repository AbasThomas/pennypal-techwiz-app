import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';
import '../../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false, _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).forgotPassword(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) AppSnackbar.error(context, ApiErrorHandler.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reset password',
      scrollable: false,
      body: _sent ? _SentState() : _FormState(
        formKey: _form,
        email: _email,
        loading: _loading,
        onSubmit: _submit,
      ),
    );
  }
}

// â”€â”€ Success state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SentState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: PennyPalColors.elevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: PennyPalColors.border,
                width: 1.5,
              ),
            ),
            child: const AppIcon(
              AppIcons.mail,
              size: 32,
              color: PennyPalColors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Check your inbox',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: PennyPalColors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'If an account exists for that email, reset\ninstructions will arrive shortly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: PennyPalColors.gray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Form state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FormState extends StatelessWidget {
  const _FormState({
    required this.formKey,
    required this.email,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LottiePlaceholder(
            height: 160,
            label: 'forgot_password.json',
            tint: PennyPalColors.white,
          ),

          const SizedBox(height: 28),

          const Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: PennyPalColors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your email and we\'ll send you reset instructions.',
            style: TextStyle(
              fontSize: 14,
              color: PennyPalColors.gray,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 28),

          AppTextField(
            controller: email,
            label: 'Email address',
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),

          AppButton(
            text: 'Send instructions',
            loading: loading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
