import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Drop-in placeholder for every Lottie animation in the app.
///
/// To swap in a real animation, replace the widget with:
///   Lottie.asset('assets/animations/<name>.json',
///       width: width, height: height, fit: BoxFit.contain)
///
/// The [label] parameter shows the intended asset filename during dev.
class LottiePlaceholder extends StatelessWidget {
  const LottiePlaceholder({
    super.key,
    this.width = double.infinity,
    this.height = 200,
    this.label = 'animation.json',
    this.tint,
  });

  final double width;
  final double height;
  final String label;

  /// Override the tint color (defaults to AppColors.primary).
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? AppColors.primary;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline_rounded,
            size: height * 0.22,
            color: color.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.5),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
