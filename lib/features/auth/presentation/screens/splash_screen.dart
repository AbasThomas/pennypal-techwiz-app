import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).initialize(),
    );
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // â”€â”€ Brand mark â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: PennyPalColors.elevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  child: const AppIcon(
                    AppIcons.wallet,
                    color: PennyPalColors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PennyPal',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: PennyPalColors.white,
                  ),
                ),

                const SizedBox(height: 48),

                // â”€â”€ Lottie animation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                const LottiePlaceholder(
                  width: 260,
                  height: 260,
                  label: 'splash.json',
                  tint: PennyPalColors.white,
                ),

                const SizedBox(height: 40),

                const Text(
                  'Your money. Your progress.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: PennyPalColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Smart money management for student life.',
                  style: TextStyle(
                    fontSize: 14,
                    color: PennyPalColors.gray,
                  ),
                ),

                const Spacer(),

                // â”€â”€ Loading indicator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: PennyPalColors.white,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
