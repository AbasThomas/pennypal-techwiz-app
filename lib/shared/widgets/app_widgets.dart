import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// General-purpose scaffold used across the app.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.scrollable = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;

  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding,
            vertical: 24,
          ),
          child: body,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: title == null
          ? null
          : AppBar(
              backgroundColor: PennyPalColors.black,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              titleSpacing: 4,
              title: Text(
                title!,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: PennyPalColors.white,
                ),
              ),
              iconTheme: const IconThemeData(color: PennyPalColors.white),
              actions: actions,
            ),
      body: SafeArea(
        child: scrollable
            ? SingleChildScrollView(child: content)
            : content,
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.icon,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final List<List<dynamic>>? icon;

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: loading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: PennyPalColors.white,
      foregroundColor: PennyPalColors.black,
      disabledBackgroundColor: PennyPalColors.darkGray,
      disabledForegroundColor: PennyPalColors.gray,
      elevation: 0,
      minimumSize: const Size.fromHeight(54),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    icon: loading
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: PennyPalColors.black,
            ),
          )
        : icon == null
            ? const SizedBox.shrink()
            : AppIcon(icon!, color: PennyPalColors.black),
    label: Text(text),
  );
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
  });
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    style: const TextStyle(color: PennyPalColors.white, fontSize: 15),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: PennyPalColors.gray),
      filled: true,
      fillColor: PennyPalColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PennyPalColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PennyPalColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PennyPalColors.white, width: 1.5),
      ),
    ),
    validator: validator,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
  );
}

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: _obscure,
    validator: widget.validator,
    textInputAction: widget.textInputAction,
    style: const TextStyle(color: PennyPalColors.white, fontSize: 15),
    decoration: InputDecoration(
      labelText: widget.label,
      labelStyle: const TextStyle(color: PennyPalColors.gray),
      filled: true,
      fillColor: PennyPalColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PennyPalColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PennyPalColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PennyPalColors.white, width: 1.5),
      ),
      suffixIcon: IconButton(
        icon: AppIcon(
          _obscure ? AppIcons.view : AppIcons.viewOff,
          color: PennyPalColors.gray,
          size: 20,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    ),
  );
}

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: PennyPalColors.white));
}

/// Monochrome toast notifications conforming to Section 20 of design guidelines.
abstract final class AppSnackbar {
  static void success(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PennyPalColors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const AppIcon(AppIcons.check, color: PennyPalColors.black, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: PennyPalColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void error(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PennyPalColors.elevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: PennyPalColors.border),
        ),
        content: Row(
          children: [
            const AppIcon(AppIcons.warning, color: PennyPalColors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: PennyPalColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void warning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PennyPalColors.border,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const AppIcon(AppIcons.warning, color: PennyPalColors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: PennyPalColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void info(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PennyPalColors.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: PennyPalColors.border),
        ),
        content: Row(
          children: [
            const AppIcon(AppIcons.info, color: PennyPalColors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: PennyPalColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(AppIcons.warning, size: 48, color: PennyPalColors.gray),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: PennyPalColors.white, fontSize: 15),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Try again', style: TextStyle(color: PennyPalColors.white)),
            ),
          ],
        ],
      ),
    ),
  );
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = AppIcons.fallback,
  });
  final String message;
  final List<List<dynamic>> icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 48, color: PennyPalColors.gray),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: PennyPalColors.gray, fontSize: 14),
          ),
        ],
      ),
    ),
  );
}
