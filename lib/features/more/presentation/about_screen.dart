import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pennypal/core/widgets/app_icon.dart';
import 'package:go_router/go_router.dart';
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
            Image.asset(
              'assets/images/app-logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: PennyPalColors.elevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const AppIcon(AppIcons.check,
                        color: PennyPalColors.white, size: 16),
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

            // Support & legal
            Container(
              decoration: BoxDecoration(
                color: PennyPalColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: Column(
                children: [
                  _LinkRow(
                    icon: AppIcons.help,
                    label: 'Help & FAQs',
                    subtitle: 'Answers to common questions',
                    onTap: () => context.push('/help'),
                  ),
                  const _RowDivider(),
                  _LinkRow(
                    icon: AppIcons.support,
                    label: 'Contact Support',
                    subtitle: 'Reach the PennyPal team',
                    onTap: () => context.push('/support'),
                  ),
                  const _RowDivider(),
                  _LinkRow(
                    icon: AppIcons.bulb,
                    label: 'Send Feedback',
                    subtitle: 'Suggest an improvement',
                    onTap: () => context.push('/feedback'),
                  ),
                  const _RowDivider(),
                  _LinkRow(
                    icon: AppIcons.security,
                    label: 'Open Source Licenses',
                    subtitle: 'Packages that power PennyPal',
                    onTap: () => _showLicenses(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Version
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: PennyPalColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Made for students, by students.',
              style: TextStyle(
                fontSize: 12,
                color: PennyPalColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    HapticFeedback.selectionClick();
    showLicensePage(
      context: context,
      applicationName: 'PennyPal',
      applicationVersion: '1.0.0',
      applicationLegalese: '\u00A9 2026 PennyPal',
      applicationIcon: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Image.asset(
          'assets/images/app-logo.png',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    indent: 60,
    endIndent: 16,
    color: PennyPalColors.mutedBorder,
  );
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PennyPalColors.elevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppIcon(icon, color: PennyPalColors.white, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: PennyPalColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: PennyPalColors.gray,
                    ),
                  ),
                ],
              ),
            ),
            const AppIcon(
              AppIcons.chevronRight,
              color: PennyPalColors.gray,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
