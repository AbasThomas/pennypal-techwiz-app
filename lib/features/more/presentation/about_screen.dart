import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('About PennyPal',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white)),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          children: [
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PennyPalColors.elevated,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: const AppIcon(AppIcons.wallet,
                  color: PennyPalColors.white, size: 42),
            ),
            const SizedBox(height: 16),
            const Text(
              'PennyPal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Fresh All Along',
              style: TextStyle(
                fontSize: 13,
                color: PennyPalColors.muted,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 28),

            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PennyPalColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: const Text(
                'PennyPal helps students understand, manage and improve their everyday financial habits.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: PennyPalColors.gray,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Features
            for (final item in [
              ('Track', 'Monitor income and expenses with ease.'),
              ('Budget', 'Set category limits and stay on course.'),
              ('Save', 'Create goals and celebrate every milestone.'),
              ('Learn', 'Build financial literacy one lesson at a time.'),
            ])
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: PennyPalColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PennyPalColors.elevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const AppIcon(AppIcons.check,
                        color: PennyPalColors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: PennyPalColors.white)),
                      Text(item.$2,
                          style: const TextStyle(
                              fontSize: 12, color: PennyPalColors.gray)),
                    ],
                  ),
                ]),
              ),

            const SizedBox(height: 24),

            // Version
            const Text(
              'Version 1.0',
              style: TextStyle(
                fontSize: 13,
                color: PennyPalColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
