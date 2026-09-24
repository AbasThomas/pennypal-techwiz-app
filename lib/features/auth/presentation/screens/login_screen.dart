import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import 'package:flutter/services.dart';
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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
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

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      body: Column(
        children: [
          // Top panel â€” brand header with lottie
          _TopPanel(),

          // Form panel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: PennyPalColors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Enter your credentials to continue.',
                          style: TextStyle(
                            fontSize: 14,
                            color: PennyPalColors.gray,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Email
                        _AuthField(
                          controller: _email,
                          focusNode: _emailFocus,
                          label: 'Email address',
                          hint: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: AppIcons.mail,
                          validator: Validators.email,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_passwordFocus),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _AuthPasswordField(
                          controller: _password,
                          focusNode: _passwordFocus,
                          label: 'Password',
                          hint: 'Your password',
                          validator: Validators.password,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                        ),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go('/forgot-password'),
                            style: TextButton.styleFrom(
                              foregroundColor: PennyPalColors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 10),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: PennyPalColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sign in button
                        _PrimaryButton(
                          label: 'Sign In',
                          loading: loading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 32),

                        // Divider
                        const _OrDivider(),
                        const SizedBox(height: 24),

                        // Create account
                        _SecondaryButton(
                          label: 'Create an account',
                          onPressed: () => context.go('/register'),
                        ),
                        const SizedBox(height: 28),

                        // Trust note
                        const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(
                                AppIcons.lock,
                                size: 13,
                                color: PennyPalColors.muted,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Secured with end-to-end encryption.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: PennyPalColors.muted,
                                ),
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
        ],
      ),
    );
  }
}

class _TopPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: PennyPalColors.nearBlack,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: PennyPalColors.elevated,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: PennyPalColors.border),
                    ),
                    child: const AppIcon(
                      AppIcons.wallet,
                      color: PennyPalColors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'PennyPal',
                    style: TextStyle(
                      color: PennyPalColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lottie zone
              const LottiePlaceholder(
                height: 160,
                label: 'login.json',
                tint: PennyPalColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.focusNode,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
  }) : textInputAction = TextInputAction.next;

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final List<List<dynamic>> prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: PennyPalColors.gray,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: const TextStyle(fontSize: 15, color: PennyPalColors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: PennyPalColors.muted,
              fontSize: 14,
            ),
            prefixIcon: AppIcon(prefixIcon, size: 18, color: PennyPalColors.muted),
            filled: true,
            fillColor: PennyPalColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 15),
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
              borderSide:
                  const BorderSide(color: PennyPalColors.white, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: PennyPalColors.lightGray, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: PennyPalColors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthPasswordField extends StatefulWidget {
  const _AuthPasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    this.focusNode,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<_AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<_AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: PennyPalColors.gray,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscure,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: const TextStyle(fontSize: 15, color: PennyPalColors.white),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: PennyPalColors.muted,
              fontSize: 14,
            ),
            prefixIcon: const AppIcon(AppIcons.lock,
                size: 18, color: PennyPalColors.muted),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: AppIcon(
                _obscure
                    ? AppIcons.view
                    : AppIcons.viewOff,
                size: 18,
                color: PennyPalColors.muted,
              ),
            ),
            filled: true,
            fillColor: PennyPalColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 15),
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
              borderSide:
                  const BorderSide(color: PennyPalColors.white, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: PennyPalColors.lightGray, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: PennyPalColors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: PennyPalColors.white,
          foregroundColor: PennyPalColors.black,
          disabledBackgroundColor: PennyPalColors.lightGray,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: PennyPalColors.black,
                ),
              ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: PennyPalColors.card,
          foregroundColor: PennyPalColors.white,
          side: const BorderSide(color: PennyPalColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: PennyPalColors.white,
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(color: PennyPalColors.mutedBorder, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 13,
              color: PennyPalColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: PennyPalColors.mutedBorder, thickness: 1),
        ),
      ],
    );
  }
}
