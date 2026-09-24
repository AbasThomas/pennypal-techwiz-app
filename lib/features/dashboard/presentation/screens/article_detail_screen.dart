import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, this.slug});
  final String? slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Budgeting',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────────────
            const Text(
              'What is a Budget?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.2,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.muted),
              const SizedBox(width: 5),
              const Text('5 min read',
                  style: TextStyle(fontSize: 13, color: AppColors.muted)),
            ]),
            const SizedBox(height: 20),

            // ── Lottie placeholder ─────────────────────────────
            // TODO: Lottie.asset('assets/animations/onboarding_2.json', height: 200)
            const LottiePlaceholder(height: 180, label: 'onboarding_2.json'),
            const SizedBox(height: 24),

            // ── Body ──────────────────────────────────────────
            _bodyText(
              "A budget is a plan for how you'll spend and save your money. It helps you make intentional decisions instead of wondering where your money went at the end of the month.",
            ),
            const SizedBox(height: 20),

            // ── Example box ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Example',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(height: 10),
                  const Text('You receive ₦100,000/month.',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text)),
                  const SizedBox(height: 10),
                  for (final item in [
                    ('Needs', '₦50,000'),
                    ('Savings', '₦20,000'),
                    ('Wants', '₦30,000'),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        Expanded(
                            child: Text(item.$1,
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.muted))),
                        Text(item.$2,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text)),
                      ]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _bodyText(
              'When you give every naira a purpose, you spend less on things that don\'t matter and more on things that do. Start small — even a rough budget is better than no budget.',
            ),
            const SizedBox(height: 20),

            // ── Second illustration ────────────────────────────
            // TODO: swap with a second lottie here
            const LottiePlaceholder(height: 140, label: 'onboarding_3.json'),
            const SizedBox(height: 24),

            // ── Tip ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.25)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PennyPal Tip',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text)),
                        SizedBox(height: 4),
                        Text(
                          'Always give your money a job. A budget is just a spending plan — it puts you in control.',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bodyText(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.text,
          height: 1.7,
        ),
      );
}
