import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';

/// A clean top section used on auth screens.
class AuthFormHeader extends StatelessWidget {
  const AuthFormHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showAnimation = true,
  });

  final String title;
  final String subtitle;

  /// When true, the Lottie placeholder area is shown above the copy.
  final bool showAnimation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand mark
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: PennyPalColors.elevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: const AppIcon(
                AppIcons.wallet,
                color: PennyPalColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'PennyPal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: PennyPalColors.white,
              ),
            ),
          ],
        ),

        if (showAnimation) ...[
          const SizedBox(height: 32),
          const _LottiePlaceholder(height: 180),
        ],

        const SizedBox(height: 28),

        // Page title & subtitle
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: PennyPalColors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: PennyPalColors.gray,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Placeholder widget that marks where a Lottie animation will live.
class _LottiePlaceholder extends StatelessWidget {
  const _LottiePlaceholder({this.height = 180});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PennyPalColors.border,
          width: 1.5,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            AppIcons.fallback,
            size: 40,
            color: PennyPalColors.white,
          ),
          SizedBox(height: 8),
          Text(
            'Lottie animation',
            style: TextStyle(
              fontSize: 12,
              color: PennyPalColors.muted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
