import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../providers/auth_providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  bool _done = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_current.text == _next.text) {
      AppSnackbar.error(
        context,
        'Your new password must be different from the current one.',
      );
      return;
    }
    setState(() => _saving = true);
    final ok = await ref
        .read(authControllerProvider.notifier)
        .changePassword(
          currentPassword: _current.text,
          newPassword: _next.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      setState(() => _done = true);
    } else {
      AppSnackbar.error(
        context,
        ref.read(authControllerProvider).errorMessage ??
            'Unable to change your password.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PennyPalColors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: _done ? _DoneView(onClose: () => context.pop()) : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PennyPalColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  child: const Row(
                    children: [
                      AppIcon(
                        AppIcons.lockCheck,
                        color: PennyPalColors.white,
                        size: 16,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Confirm your current password, then choose a new one.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: PennyPalColors.gray,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _PasswordField(
                  controller: _current,
                  label: 'Current password',
                  hint: 'Enter your current password',
                  validator: (v) =>
                      Validators.required(v, label: 'Current password'),
                  enabled: !_saving,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                _PasswordField(
                  controller: _next,
                  label: 'New password',
                  hint: 'At least 8 characters, letters and numbers',
                  validator: Validators.password,
                  enabled: !_saving,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                _PasswordField(
                  controller: _confirm,
                  label: 'Confirm new password',
                  hint: 'Re-enter your new password',
                  validator: (v) => Validators.confirmPassword(v, _next.text),
                  enabled: !_saving,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: _saving
                      ? null
                      : () => context.push('/forgot-password'),
                  style: TextButton.styleFrom(
                    foregroundColor: PennyPalColors.lightGray,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text("Don't remember your current password?"),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
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
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              strokeCap: StrokeCap.round,
                              color: PennyPalColors.black,
                            ),
                          )
                        : const Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: PennyPalColors.black,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                const Center(
                  child: Text(
                    'For your security you may be asked to sign in again on other devices.',
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
          ),
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PennyPalColors.elevated,
                shape: BoxShape.circle,
                border: Border.all(color: PennyPalColors.border),
              ),
              child: const AppIcon(
                AppIcons.check,
                color: PennyPalColors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Password Updated',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your password has been changed.\nUse it the next time you sign in.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: PennyPalColors.gray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PennyPalColors.white,
                  foregroundColor: PennyPalColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PennyPalColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?) validator;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: PennyPalColors.gray,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscure,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
          cursorColor: PennyPalColors.white,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            color: PennyPalColors.white,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 14.5,
              color: PennyPalColors.muted,
            ),
            prefixIcon: const AppIcon(
              AppIcons.lock,
              size: 14,
              color: PennyPalColors.muted,
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              tooltip: _obscure ? 'Show password' : 'Hide password',
              icon: AppIcon(
                _obscure ? AppIcons.view : AppIcons.viewOff,
                size: 14,
                color: PennyPalColors.muted,
              ),
            ),
            filled: true,
            fillColor: PennyPalColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: _border(PennyPalColors.border),
            enabledBorder: _border(PennyPalColors.border),
            focusedBorder: _border(PennyPalColors.white, width: 1.5),
            errorBorder: _border(PennyPalColors.danger),
            focusedErrorBorder: _border(PennyPalColors.danger, width: 1.5),
            errorStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: PennyPalColors.danger,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
}
