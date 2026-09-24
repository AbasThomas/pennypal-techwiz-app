import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/providers/auth_providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final name = [user?.firstName, user?.lastName]
        .whereType<String>()
        .join(' ')
        .trim()
        .isNotEmpty
        ? '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim()
        : user?.email.split('@').first ?? 'Student';

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'More',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: PennyPalColors.white,
                ),
              ),
              const SizedBox(height: 20),

              // ── Profile header (Section 17: minimal, no gradient) ──
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PennyPalColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: PennyPalColors.elevated,
                        child: Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            color: PennyPalColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: PennyPalColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                color: PennyPalColors.gray,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: PennyPalColors.gray,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Tools ──────────────────────────────────────────
              const _SectionLabel(label: 'Tools'),
              const SizedBox(height: 8),
              _MenuGroup(items: [
                _MenuItem(
                  icon: Icons.insights_rounded,
                  label: 'Financial Insights',
                  onTap: () => context.push('/reports'),
                ),
                _MenuItem(
                  icon: Icons.smart_toy_rounded,
                  label: 'AI Assistant',
                  onTap: () => context.push('/ai-assistant'),
                ),
                _MenuItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => context.push('/notifications'),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Account ─────────────────────────────────────────
              const _SectionLabel(label: 'Account'),
              const SizedBox(height: 8),
              _MenuGroup(items: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  onTap: () => context.push('/profile'),
                ),
                _MenuItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'Security',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.tune_rounded,
                  label: 'Notification Settings',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),

              // ── Support ─────────────────────────────────────────
              const _SectionLabel(label: 'Support'),
              const SizedBox(height: 8),
              _MenuGroup(items: [
                _MenuItem(
                  icon: Icons.forum_outlined,
                  label: 'Give Feedback',
                  onTap: () => context.push('/feedback'),
                ),
                _MenuItem(
                  icon: Icons.support_agent_rounded,
                  label: 'Contact Support',
                  onTap: () => context.push('/support'),
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About PennyPal',
                  onTap: () => context.push('/about'),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Log out ──────────────────────────────────────────
              _MenuGroup(items: [
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Log Out',
                  showChevron: false,
                  onTap: () => ref
                      .read(authControllerProvider.notifier)
                      .logout(),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: PennyPalColors.muted,
          ),
        ),
      );
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 60,
                  color: PennyPalColors.mutedBorder,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
                border: Border.all(color: PennyPalColors.border),
              ),
              child: Icon(icon, color: PennyPalColors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? PennyPalColors.white,
                ),
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right_rounded,
                  color: PennyPalColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}
