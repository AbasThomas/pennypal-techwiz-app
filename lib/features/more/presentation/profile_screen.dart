import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final name = [user?.firstName, user?.lastName]
        .whereType<String>()
        .join(' ')
        .trim();
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'S';

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white)),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          children: [
            // â”€â”€ Avatar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 44,
              backgroundColor: PennyPalColors.elevated,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: PennyPalColors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name.isNotEmpty ? name : 'Student',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: PennyPalColors.white,
              ),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 14, color: PennyPalColors.muted),
            ),
            const SizedBox(height: 28),

            // â”€â”€ Info â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _InfoSection(title: 'Personal Information', items: [
              _InfoRow(label: 'Full Name', value: name.isNotEmpty ? name : 'â€”'),
              _InfoRow(label: 'Email', value: user?.email ?? 'â€”'),
              _InfoRow(
                  label: 'Phone',
                  value: user?.phoneNumber ?? 'â€”'),
            ]),
            const SizedBox(height: 20),

            _InfoSection(title: 'Account', items: [
              _InfoRow(label: 'Role', value: user?.role ?? 'student'),
              _InfoRow(
                  label: 'Email Verified',
                  value: (user?.isEmailVerified ?? false) ? 'Yes' : 'No'),
            ]),
            const SizedBox(height: 28),

            // â”€â”€ Logout â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                icon: const AppIcon(AppIcons.logout,
                    color: PennyPalColors.white, size: 18),
                label: const Text('Log Out',
                    style: TextStyle(
                        color: PennyPalColors.white,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: PennyPalColors.card,
                  side: const BorderSide(color: PennyPalColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.items});
  final String title;
  final List<_InfoRow> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: PennyPalColors.muted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: PennyPalColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PennyPalColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(children: [
                e.value,
                if (!isLast)
                  const Divider(
                      height: 1, indent: 16, color: PennyPalColors.mutedBorder),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14, color: PennyPalColors.gray)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PennyPalColors.white)),
      ]),
    );
  }
}
