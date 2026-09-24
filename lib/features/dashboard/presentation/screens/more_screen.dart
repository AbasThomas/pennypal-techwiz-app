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
      backgroundColor: AppColors.background,
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
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 20),

              // ── Profile header ─────────────────────────────────
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
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
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Tools ──────────────────────────────────────────
              _SectionLabel(label: 'Tools'),
              const SizedBox(height: 8),
              _MenuGroup(items: [
                _MenuItem(
                  icon: Icons.insights_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  iconBg: const Color(0xFFF5F3FF),
                  label: 'Financial Insights',
                  onTap: () => context.push('/reports'),
                ),
                _MenuItem(
                  icon: Icons.smart_toy_rounded,
                  iconColor: const Color(0xFF0D9488),
                  iconBg: const Color(0xFFF0FDFA),
                  label: 'AI Assistant',
                  onTap: () => context.push('/ai-assistant'),
                ),
                _MenuItem(
                  icon: Icons.notifications_none_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  iconBg: const Color(0xFFFFFBEB),
                  label: 'Notifications',
                  onTap: () => context.push('/notifications'),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Account ─────────────────────────────────────────
              _SectionLabel(label: 'Account'),
              const SizedBox(height: 8),
              _MenuGroup(items: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.primary,
                  iconBg: const Color(0xFFF0FDF4),
                  label: 'Profile',
                  onTap: () => context.push('/profile'),
                ),
                _MenuItem(
                  icon: Icons.lock_outline_rounded,
                  iconColor: AppColors.primary,
                  iconBg: const Color(0xFFF0FDF4),
                  label: 'Security',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.tune_rounded,
                  iconColor: AppColors.primary,
                  iconBg: const Color(0xFFF0FDF4),
                  label: 'Notification Settings',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),

              // ── Support ─────────────────────────────────────────
              _SectionLabel(label: 'Support'),
              const SizedBox(height: 8),
              _MenuGroup(items: [
                _MenuItem(
                  icon: Icons.forum_outlined,
                  iconColor: const Color(0xFF4F46E5),
                  iconBg: const Color(0xFFF0F4FF),
                  label: 'Give Feedback',
                  onTap: () => context.push('/feedback'),
                ),
                _MenuItem(
                  icon: Icons.support_agent_rounded,
                  iconColor: const Color(0xFF4F46E5),
                  iconBg: const Color(0xFFF0F4FF),
                  label: 'Contact Support',
                  onTap: () => context.push('/support'),
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF4F46E5),
                  iconBg: const Color(0xFFF0F4FF),
                  label: 'About PennyPal',
                  onTap: () => context.push('/about'),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Log out ──────────────────────────────────────────
              _MenuGroup(items: [
                _MenuItem(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.error,
                  iconBg: const Color(0xFFFFF1F2),
                  label: 'Log Out',
                  labelColor: AppColors.error,
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
            color: AppColors.muted,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
            BorderSide(color: Color(0xFFE2E8F0))),
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
                    color: Color(0xFFF1F5F9)),
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
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.showChevron = true,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
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
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? AppColors.text,
                ),
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}
