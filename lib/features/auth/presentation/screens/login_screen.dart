import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../providers/auth_providers.dart';
import '../controllers/auth_controller.dart';

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
    if (!(_form.currentState?.validate() ?? false)) return;
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
          const _BrandBar(),
          Expanded(child: _formSheet(loading)),
        ],
      ),
    );
  }

  Widget _formSheet(bool loading) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: PennyPalColors.surface,
          border: Border(top: BorderSide(color: PennyPalColors.border)),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            16 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeroAnimation(),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          height: 1.1,
                          color: PennyPalColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to keep your budget, goals and spending in sync.',
                        style: TextStyle(
                          fontSize: 14.5,
                          color: PennyPalColors.gray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _AuthInput(
                        controller: _email,
                        focusNode: _emailFocus,
                        label: 'Email address',
                        hint: 'you@example.com',
                        prefixIcon: AppIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.email,
                        enabled: !loading,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_passwordFocus),
                      ),
                      const SizedBox(height: 16),

                      _AuthInput(
                        controller: _password,
                        focusNode: _passwordFocus,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: AppIcons.lock,
                        obscure: true,
                        autofillHints: const [AutofillHints.password],
                        validator: Validators.password,
                        textInputAction: TextInputAction.done,
                        enabled: !loading,
                        onFieldSubmitted: (_) => _submit(),
                        labelTrailing: TextButton(
                          onPressed: loading
                              ? null
                              : () => context.go('/forgot-password'),
                          style: TextButton.styleFrom(
                            foregroundColor: PennyPalColors.lightGray,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _PrimaryButton(
                        label: 'Sign In',
                        loading: loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 22),

                      const _OrDivider(),
                      const SizedBox(height: 18),

                      _SecondaryButton(
                        label: 'Create an account',
                        onPressed: () => context.go('/register'),
                      ),
                      const SizedBox(height: 18),

                      const _TrustNote(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandBar extends StatelessWidget {
  const _BrandBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
        child: Row(
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
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroAnimation extends StatelessWidget {
  const _HeroAnimation();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 18),
      child: SizedBox(
        height: 250,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const _HeroGlow(),
              Lottie.asset(
                'assets/animations/login.json',
                width: 240,
                height: 240,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroGlow extends StatelessWidget {
  const _HeroGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            PennyPalColors.elevated.withValues(alpha: 0.75),
            PennyPalColors.black.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _AuthInput extends StatefulWidget {
  const _AuthInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.focusNode,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.obscure = false,
    this.labelTrailing,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final List<List<dynamic>> prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscure;
  final Widget? labelTrailing;
  final bool enabled;

  @override
  State<_AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<_AuthInput> {
  late final FocusNode _node = widget.focusNode ?? FocusNode();
  late bool _obscure = widget.obscure;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() => _focused = _node.hasFocus);

  @override
  void dispose() {
    _node.removeListener(_onFocusChanged);
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _focused ? PennyPalColors.white : PennyPalColors.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color:
                      _focused ? PennyPalColors.lightGray : PennyPalColors.gray,
                ),
              ),
            ),
            if (widget.labelTrailing != null) widget.labelTrailing!,
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _node,
          enabled: widget.enabled,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          autocorrect: false,
          enableSuggestions: false,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
          cursorColor: PennyPalColors.white,
          cursorWidth: 1.6,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            color: PennyPalColors.white,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 14.5,
              color: PennyPalColors.muted,
            ),
            prefixIcon: SizedBox(
              width: 34,
              height: 34,
              child: Center(
                child: AppIcon(widget.prefixIcon, size: 13, color: accent),
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 34, minHeight: 34, maxWidth: 34, maxHeight: 34),
            suffixIcon: widget.obscure
                ? SizedBox(
                    width: 34,
                    height: 34,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _obscure = !_obscure),
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      icon: AppIcon(
                        _obscure ? AppIcons.view : AppIcons.viewOff,
                        size: 13,
                        color: accent,
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 34, minHeight: 34, maxWidth: 34, maxHeight: 34),
            filled: true,
            fillColor: PennyPalColors.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: _fieldBorder(PennyPalColors.border),
            enabledBorder: _fieldBorder(PennyPalColors.border),
            disabledBorder: _fieldBorder(PennyPalColors.mutedBorder),
            focusedBorder: _fieldBorder(PennyPalColors.white, width: 1.5),
            errorBorder: _fieldBorder(PennyPalColors.danger),
            focusedErrorBorder: _fieldBorder(PennyPalColors.danger, width: 1.5),
            errorStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              height: 1.3,
              letterSpacing: 0.1,
              color: PennyPalColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}

OutlineInputBorder _fieldBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );

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
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: PennyPalColors.white,
          foregroundColor: PennyPalColors.black,
          disabledBackgroundColor: PennyPalColors.darkGray,
          disabledForegroundColor: PennyPalColors.gray,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  strokeCap: StrokeCap.round,
                  color: PennyPalColors.black,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15.5,
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
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: PennyPalColors.white,
          side: const BorderSide(color: PennyPalColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
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
          child: Divider(
            color: PennyPalColors.mutedBorder,
            thickness: 1,
            height: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 12.5,
              color: PennyPalColors.muted,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: PennyPalColors.mutedBorder,
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _TrustNote extends StatelessWidget {
  const _TrustNote();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(AppIcons.lock, size: 13, color: PennyPalColors.muted),
          SizedBox(width: 7),
          Flexible(
            child: Text(
              'Your data is encrypted and stored securely.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: PennyPalColors.muted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
