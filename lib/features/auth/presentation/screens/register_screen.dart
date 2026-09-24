import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';
import '../controllers/auth_controller.dart';
import '../../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [_fullName, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).register({
      'fullName': _fullName.text.trim(),
      'phoneNumber': _phone.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
    });
    if (!ok && mounted) {
      AppSnackbar.error(
        context,
        ref.read(authControllerProvider).errorMessage ??
            'Unable to create account.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading =
        ref.watch(authControllerProvider).status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Brand mark ────────────────────────────────
                    _BrandMark(),
                    const SizedBox(height: 32),

                    // ── Lottie placeholder ────────────────────────
                    // TODO: Lottie.asset('assets/animations/register.json',
                    //   width: double.infinity, height: 160)
                    const LottiePlaceholder(
                        height: 160, label: 'register.json'),
                    const SizedBox(height: 32),

                    // ── Headline ──────────────────────────────────
                    const Text(
                      'Create your\nPennyPal account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.2,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Start building better money habits today.',
                      style: TextStyle(fontSize: 15, color: AppColors.muted),
                    ),
                    const SizedBox(height: 28),

                    // ── Fields ────────────────────────────────────
                    AppTextField(
                      controller: _fullName,
                      label: 'Full name',
                      validator: (v) =>
                          Validators.required(v, label: 'Full name'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _email,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _phone,
                      label: 'Mobile number',
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          Validators.required(v, label: 'Mobile number'),
                    ),
                    const SizedBox(height: 16),
                    AppPasswordField(
                      controller: _password,
                      label: 'Password',
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    AppPasswordField(
                      controller: _confirm,
                      label: 'Confirm password',
                      validator: (v) =>
                          Validators.confirmPassword(v, _password.text),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 28),

                    // ── Submit ────────────────────────────────────
                    AppButton(
                      text: 'Create Account',
                      loading: loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),

                    // ── Sign in link ──────────────────────────────
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Already have an account?',
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.muted)),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                            ),
                            child: const Text('Login',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.savings_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'PennyPal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.text,
            ),
          ),
        ],
      );
}
