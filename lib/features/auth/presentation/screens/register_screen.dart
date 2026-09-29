import 'package:flutter/material.dart';
import 'package:pennypal/core/widgets/app_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../controllers/auth_controller.dart';
import '../../providers/auth_providers.dart';

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

  @override
  Widget build(BuildContext context) {
    final loading =
        ref.watch(authControllerProvider).status == AuthStatus.loading;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      body: Column(
        children: [
          // Header
          _RegisterHeader(step: _step),

          // Scrollable form area
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

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: PennyPalColors.nearBlack,
      child: SafeArea(
        bottom: false,
        child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand row
              Row(
                children: [
                  Image.asset(
                    'assets/images/app-logo.png',
                    width: 45,
                    height: 45,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PennyPal',
                    style: TextStyle(
                      color: PennyPalColors.white,
                      fontSize: 20,
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
                      color: PennyPalColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PennyPalColors.border),
                    ),
                    child: Text(
                      'Step ${step + 1} of 2',
                      style: const TextStyle(
                        color: PennyPalColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Step progress bar
              _StepBar(step: step),
              const SizedBox(height: 12),

              // Lottie zone
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Lottie.asset(
                    step == 0
                        ? 'assets/animations/register.json'
                        : 'assets/animations/onboarding3.json',
                    key: ValueKey(step),
                    height: 200,
                    fit: BoxFit.contain,
                  ),
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
                    ? PennyPalColors.white
                    : PennyPalColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}

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
          const Text(
            'Create your account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: PennyPalColors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start by telling us a little about yourself.',
            style: TextStyle(fontSize: 14, color: PennyPalColors.gray, height: 1.4),
          ),
          const SizedBox(height: 18),

          const _FieldLabel('Full name'),
          const SizedBox(height: 8),
          _FormField(
            controller: fullName,
            hint: 'Thomas Abasienyene',
            prefixIcon: AppIcons.user,
            validator: (v) => Validators.required(v, label: 'Full name'),
          ),
          const SizedBox(height: 12),

          const _FieldLabel('Email address'),
          const SizedBox(height: 8),
          _FormField(
            controller: email,
            hint: 'you@example.com',
            prefixIcon: AppIcons.mail,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 12),

          const _FieldLabel('Mobile number'),
          const SizedBox(height: 8),
          _FormField(
            controller: phone,
            hint: '+234 800 000 0000',
            prefixIcon: AppIcons.support,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: (v) => Validators.required(v, label: 'Mobile number'),
          ),
          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: PennyPalColors.white,
                foregroundColor: PennyPalColors.black,
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
                      color: PennyPalColors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  AppIcon(AppIcons.arrowForward, size: 18, color: PennyPalColors.black),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(fontSize: 14, color: PennyPalColors.muted),
                ),
                TextButton(
                  onPressed: onSignIn,
                  style: TextButton.styleFrom(
                    foregroundColor: PennyPalColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PennyPalColors.white),
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
          const Text(
            'Set your password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: PennyPalColors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose a strong password to protect your account.',
            style: TextStyle(fontSize: 14, color: PennyPalColors.gray, height: 1.4),
          ),
          const SizedBox(height: 28),

          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: PennyPalColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PennyPalColors.border),
            ),
            child: const Row(
              children: [
                AppIcon(AppIcons.info,
                    size: 16,
                    color: PennyPalColors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'At least 8 characters with a mix of letters and numbers.',
                    style: TextStyle(
                      fontSize: 12,
                      color: PennyPalColors.gray,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const _FieldLabel('Password'),
          const SizedBox(height: 8),
          _PasswordFormField(
            controller: password,
            hint: 'Create a strong password',
            validator: Validators.password,
          ),
          const SizedBox(height: 18),

          const _FieldLabel('Confirm password'),
          const SizedBox(height: 8),
          _PasswordFormField(
            controller: confirm,
            hint: 'Re-enter your password',
            textInputAction: TextInputAction.done,
            validator: (v) => Validators.confirmPassword(v, password.text),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: PennyPalColors.white,
                foregroundColor: PennyPalColors.black,
                disabledBackgroundColor: PennyPalColors.lightGray,
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
                        color: PennyPalColors.black,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: PennyPalColors.black,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton.icon(
              onPressed: onBack,
              icon: const AppIcon(AppIcons.arrowBack, size: 17, color: PennyPalColors.white),
              label: const Text('Back', style: TextStyle(color: PennyPalColors.white)),
              style: TextButton.styleFrom(
                foregroundColor: PennyPalColors.white,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: PennyPalColors.gray,
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
  final List<List<dynamic>> prefixIcon;
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
      style: const TextStyle(fontSize: 15, color: PennyPalColors.white),
      decoration: _fieldDecoration(
        hint: hint,
        prefix: SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: AppIcon(prefixIcon, size: 13, color: PennyPalColors.muted),
          ),
        ),
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
      style: const TextStyle(fontSize: 15, color: PennyPalColors.white),
      decoration: _fieldDecoration(
        hint: widget.hint,
        prefix: const SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: AppIcon(
              AppIcons.lock,
              size: 13,
              color: PennyPalColors.muted,
            ),
          ),
        ),
        suffix: SizedBox(
          width: 34,
          height: 34,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: AppIcon(
              _obscure ? AppIcons.view : AppIcons.viewOff,
              size: 13,
              color: PennyPalColors.muted,
            ),
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
      isDense: true,
      hintText: hint,
      hintStyle: const TextStyle(
        color: PennyPalColors.muted,
        fontSize: 14,
      ),
      prefixIcon: prefix,
      prefixIconConstraints:
          const BoxConstraints(minWidth: 34, minHeight: 34, maxWidth: 34, maxHeight: 34),
      suffixIcon: suffix,
      suffixIconConstraints:
          const BoxConstraints(minWidth: 34, minHeight: 34, maxWidth: 34, maxHeight: 34),
      filled: true,
      fillColor: PennyPalColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PennyPalColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PennyPalColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PennyPalColors.white, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PennyPalColors.danger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PennyPalColors.danger, width: 1.5),
      ),
      errorStyle: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: PennyPalColors.danger,
      ),
    );
