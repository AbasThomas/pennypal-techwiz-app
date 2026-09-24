import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';
import '../controllers/auth_controller.dart';
import '../../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(email: _email.text.trim(), password: _password.text);
    if (!ok && mounted) {
      AppSnackbar.error(
        context,
        ref.read(authControllerProvider).errorMessage ?? 'Unable to sign in.',
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
                    // TODO: Lottie.asset('assets/animations/login.json',
                    //   width: double.infinity, height: 180)
                    const LottiePlaceholder(height: 180, label: 'login.json'),
                    const SizedBox(height: 32),

                    // ── Headline ──────────────────────────────────
                    const Text(
                      'Welcome back 👋',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Let's get your finances back on track.",
                      style: TextStyle(fontSize: 15, color: AppColors.muted),
                    ),
                    const SizedBox(height: 28),

                    // ── Fields ────────────────────────────────────
                    AppTextField(
                      controller: _email,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    AppPasswordField(
                      controller: _password,
                      label: 'Password',
                      validator: Validators.password,
                      textInputAction: TextInputAction.done,
                    ),

                    // ── Forgot password ───────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                        ),
                        child: const Text('Forgot password?',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Login button ──────────────────────────────
                    AppButton(
                      text: 'Login',
                      loading: loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 28),

                    // ── Divider ───────────────────────────────────
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text('or',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.muted.withValues(alpha: 0.8))),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 24),

                    // ── Create account ────────────────────────────
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Don't have an account?",
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.muted)),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                            ),
                            child: const Text('Create account',
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
