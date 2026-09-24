import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// A clean top section used on auth screens.
/// [lottiePlaceholder] is the named slot — swap the Container below
/// for a LottieBuilder widget once the animation file is ready.
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
        // ── Brand mark ──────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.savings_rounded,
                color: Colors.white,
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
                color: AppColors.text,
              ),
            ),
          ],
        ),

        if (showAnimation) ...[
          const SizedBox(height: 32),
          // ── Lottie placeholder ───────────────────────────────────
          // TODO: replace this Container with a LottieBuilder widget
          // e.g.:
          //   Lottie.asset('assets/animations/auth_welcome.json',
          //     width: double.infinity, height: 180, fit: BoxFit.contain)
          const _LottiePlaceholder(height: 180),
        ],

        const SizedBox(height: 28),

        // ── Page title & subtitle ────────────────────────────────
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.muted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Placeholder widget that marks where a Lottie animation will live.
/// Shows a subtle dashed border with a play icon so the space is obvious
/// during development. Delete this class once real animations are added.
class _LottiePlaceholder extends StatelessWidget {
  const _LottiePlaceholder({this.height = 180});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
          // Dashed borders aren't native in Flutter — using a solid light
          // border keeps it clean while still marking the zone clearly.
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline_rounded,
            size: 40,
            color: AppColors.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 8),
          Text(
            'Lottie animation',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary.withValues(alpha: 0.55),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
