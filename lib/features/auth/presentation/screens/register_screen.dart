import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';
import '../controllers/auth_controller.dart';
import '../../providers/auth_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Register — 2-step wizard
//   Step 0 · Personal details  — full name, email, mobile
//   Step 1 · Set your password — password, confirm password
// ─────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _step0Form = GlobalKey<FormState>();
  final _step1Form = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int _step = 0; // 0 or 1

  @override
  void dispose() {
    for (final c in [_fullName, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _advance() {
    FocusScope.of(context).unfocus();
    if (_step0Form.currentState!.validate()) {
      setState(() => _step = 1);
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    setState(() => _step = 0);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_step1Form.currentState!.validate()) return;
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loading =
        ref.watch(authControllerProvider).status == AuthStatus.loading;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Green header ────────────────────────────────────────
          _RegisterHeader(step: _step),

          // ── Scrollable form area ────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _step == 0
                        ? _Step0(
                            key: const ValueKey('step0'),
                            formKey: _step0Form,
                            fullName: _fullName,
                            email: _email,
                            phone: _phone,
                            onNext: _advance,
                            onSignIn: () => context.go('/login'),
                          )
                        : _Step1(
                            key: const ValueKey('step1'),
                            formKey: _step1Form,
                            password: _password,
                            confirm: _confirm,
                            loading: loading,
                            onBack: _back,
                            onSubmit: _submit,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Green header with brand + step indicator + lottie
// ─────────────────────────────────────────────────────────────────────────────

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryDark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand row
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.savings_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'PennyPal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  // Step counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Step ${step + 1} of 2',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Step progress bar
              _StepBar(step: step),
              const SizedBox(height: 20),

              // Lottie zone — different animation per step
              // TODO: replace with:
              //   step 0 → Lottie.asset('assets/animations/register.json', height: 130)
              //   step 1 → Lottie.asset('assets/animations/onboarding_3.json', height: 130)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: LottiePlaceholder(
                  key: ValueKey(step),
                  height: 130,
                  label: step == 0 ? 'register.json' : 'onboarding_3.json',
                  tint: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(2, (i) {
        final active = i <= step;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 0 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 0 — Personal details
// ─────────────────────────────────────────────────────────────────────────────

class _Step0 extends StatelessWidget {
  const _Step0({
    super.key,
    required this.formKey,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.onNext,
    required this.onSignIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullName;
  final TextEditingController email;
  final TextEditingController phone;
  final VoidCallback onNext;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heading ───────────────────────────────────────────
          const Text(
            'Create your account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start by telling us a little about yourself.',
            style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 28),

          // ── Full name ─────────────────────────────────────────
          _FieldLabel('Full name'),
          const SizedBox(height: 8),
          _FormField(
            controller: fullName,
            hint: 'Thomas Abasienyene',
            prefixIcon: Icons.person_outline_rounded,
            validator: (v) => Validators.required(v, label: 'Full name'),
          ),
          const SizedBox(height: 18),

          // ── Email ─────────────────────────────────────────────
          _FieldLabel('Email address'),
          const SizedBox(height: 8),
          _FormField(
            controller: email,
            hint: 'you@example.com',
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 18),

          // ── Phone ─────────────────────────────────────────────
          _FieldLabel('Mobile number'),
          const SizedBox(height: 8),
          _FormField(
            controller: phone,
            hint: '+234 800 000 0000',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: (v) => Validators.required(v, label: 'Mobile number'),
          ),
          const SizedBox(height: 32),

          // ── Continue ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Sign in link ──────────────────────────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(fontSize: 14, color: AppColors.muted),
                ),
                TextButton(
                  onPressed: onSignIn,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Set your password
// ─────────────────────────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  const _Step1({
    super.key,
    required this.formKey,
    required this.password,
    required this.confirm,
    required this.loading,
    required this.onBack,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController password;
  final TextEditingController confirm;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heading ───────────────────────────────────────────
          const Text(
            'Set your password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose a strong password to protect your account.',
            style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 28),

          // ── Password requirements hint ────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.primary.withValues(alpha: 0.7)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'At least 8 characters with a mix of letters and numbers.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Password ──────────────────────────────────────────
          _FieldLabel('Password'),
          const SizedBox(height: 8),
          _PasswordFormField(
            controller: password,
            hint: 'Create a strong password',
            validator: Validators.password,
          ),
          const SizedBox(height: 18),

          // ── Confirm ───────────────────────────────────────────
          _FieldLabel('Confirm password'),
          const SizedBox(height: 8),
          _PasswordFormField(
            controller: confirm,
            hint: 'Re-enter your password',
            textInputAction: TextInputAction.done,
            validator: (v) => Validators.confirmPassword(v, password.text),
          ),
          const SizedBox(height: 32),

          // ── Create account button ─────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.5),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Back button ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.muted,
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Local field widgets (keeps step widgets clean)
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
          letterSpacing: 0.1,
        ),
      );
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: AppColors.text),
      decoration: _fieldDecoration(
        hint: hint,
        prefix: Icon(prefixIcon, size: 18, color: AppColors.muted),
      ),
    );
  }
}

class _PasswordFormField extends StatefulWidget {
  const _PasswordFormField({
    required this.controller,
    required this.hint,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  @override
  State<_PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<_PasswordFormField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      style: const TextStyle(fontSize: 15, color: AppColors.text),
      decoration: _fieldDecoration(
        hint: widget.hint,
        prefix:
            const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.muted),
        suffix: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 18,
            color: AppColors.muted,
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required String hint,
  Widget? prefix,
  Widget? suffix,
}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.muted.withValues(alpha: 0.5),
        fontSize: 14,
      ),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
