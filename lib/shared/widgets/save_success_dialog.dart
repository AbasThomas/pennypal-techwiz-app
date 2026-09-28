import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/app_theme.dart';

/// Shared confirmation shown after either kind of transaction is saved.
Future<void> showTransactionSavedDialog(BuildContext context, String type) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: PennyPalColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/animations/savedsuccessful.json', height: 150),
            Text(
              '${type[0].toUpperCase()}${type.substring(1)} saved',
              style: const TextStyle(
                color: PennyPalColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your balance and reports have been updated.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PennyPalColors.gray, height: 1.4),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => dialogContext.go('/home'),
                style: FilledButton.styleFrom(
                  backgroundColor: PennyPalColors.white,
                  foregroundColor: PennyPalColors.black,
                ),
                child: const Text('Back to home'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
