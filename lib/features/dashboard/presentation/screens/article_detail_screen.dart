import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, this.slug});
  final String? slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Budgeting',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white)),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const Text(
              'What is a Budget?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.2,
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Row(children: [
              AppIcon(AppIcons.fallback,
                  size: 14, color: PennyPalColors.gray),
              SizedBox(width: 5),
              Text('5 min read',
                  style: TextStyle(fontSize: 13, color: PennyPalColors.gray)),
            ]),
            const SizedBox(height: 20),

            // â”€â”€ Lottie placeholder â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const LottiePlaceholder(height: 180, label: 'onboarding_2.json'),
            const SizedBox(height: 24),

            // â”€â”€ Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _bodyText(
              "A budget is a plan for how you'll spend and save your money. It helps you make intentional decisions instead of wondering where your money went at the end of the month.",
            ),
            const SizedBox(height: 20),

            // â”€â”€ Example box â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: PennyPalColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Example',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PennyPalColors.white)),
                  const SizedBox(height: 10),
                  const Text('You receive 100,000/month.',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: PennyPalColors.white)),
                  const SizedBox(height: 10),
                  for (final item in [
                    ('Needs', '50,000'),
                    ('Savings', '20,000'),
                    ('Wants', '30,000'),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        Expanded(
                            child: Text(item.$1,
                                style: const TextStyle(
                                    fontSize: 14, color: PennyPalColors.gray))),
                        Text(item.$2,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: PennyPalColors.white)),
                      ]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _bodyText(
              'When you give every naira a purpose, you spend less on things that don\'t matter and more on things that do. Start small â€” even a rough budget is better than no budget.',
            ),
            const SizedBox(height: 20),

            // â”€â”€ Second illustration â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const LottiePlaceholder(height: 140, label: 'onboarding_3.json'),
            const SizedBox(height: 24),

            // â”€â”€ Tip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PennyPalColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIcon(AppIcons.bulb, size: 20, color: PennyPalColors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PennyPal Tip',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: PennyPalColors.white)),
                        SizedBox(height: 4),
                        Text(
                          'Always give your money a job. A budget is just a spending plan â€” it puts you in control.',
                          style: TextStyle(
                              fontSize: 13,
                              color: PennyPalColors.gray,
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
          color: PennyPalColors.lightGray,
          height: 1.7,
        ),
      );
}
