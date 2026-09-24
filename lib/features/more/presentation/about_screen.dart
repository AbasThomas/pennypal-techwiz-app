import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('About PennyPal',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          children: [
            // ── Logo ──────────────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.savings_rounded,
                  color: Colors.white, size: 42),
            ),
            const SizedBox(height: 16),
            const Text(
              'PennyPal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Fresh All Along',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 28),

            // ── Description ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: const Border.fromBorderSide(
                    BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: const Text(
                'PennyPal helps students understand, manage and improve their everyday financial habits.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.muted,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Features ──────────────────────────────────────
            for (final item in [
              ('📊', 'Track', 'Monitor income and expenses with ease.'),
              ('🎯', 'Budget', 'Set category limits and stay on course.'),
              ('💰', 'Save', 'Create goals and celebrate every milestone.'),
              ('📚', 'Learn', 'Build financial literacy one lesson at a time.'),
            ])
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: const Border.fromBorderSide(
                      BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(children: [
                  Text(item.$1,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$2,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text)),
                      Text(item.$3,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ]),
              ),

            const SizedBox(height: 24),

            // ── Version ───────────────────────────────────────
            Text(
              'Version 1.0',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
