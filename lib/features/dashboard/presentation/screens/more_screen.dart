import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
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

              // Profile header
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile');
                },
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
                      const AppIcon(
                        AppIcons.chevronRight,
                        color: PennyPalColors.gray,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tools
              const _SectionLabel(label: 'Tools'),
              const SizedBox(height: 8),
              _MenuGroup(items: [
                _MenuItem(
                  icon: AppIcons.chartBar,
                  label: 'Financial Insights',
                  onTap: () => context.push('/reports'),
                ),
                _MenuItem(
                  icon: AppIcons.book,
                  label: 'Financial Learning',
                  onTap: () => context.push('/learn'),
                ),
                _MenuItem(
                  icon: AppIcons.robot,
                  label: 'AI Assistant',
                  onTap: () => context.push('/ai-assistant'),
                ),
                _MenuItem(
                  icon: AppIcons.notification,
                  label: 'Notifications',
                  onTap: () => context.push('/notifications'),
                ),
              ]),
              const SizedBox(height: 20),

              // Account
              const _SectionLabel(label: 'Account'),
              const SizedBox(height: 8),
              _MenuGroup(items: [
                _MenuItem(
                  icon: AppIcons.user,
                  label: 'Profile',
                  onTap: () => context.push('/profile'),
                ),
                _MenuItem(
                  icon: AppIcons.lockCheck,
                  label: 'Security & PIN',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: AppIcons.settings,
                  label: 'App Settings',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),

              // Support
              const _SectionLabel(label: 'Support'),
              const SizedBox(height: 8),
              _MenuGroup(items: [
                _MenuItem(
                  icon: AppIcons.bulb,
                  label: 'Give Feedback',
                  onTap: () => context.push('/feedback'),
                ),
                _MenuItem(
                  icon: AppIcons.support,
                  label: 'Contact Support',
                  onTap: () => context.push('/support'),
                ),
                _MenuItem(
                  icon: AppIcons.info,
                  label: 'About PennyPal',
                  onTap: () => context.push('/about'),
                ),
              ]),
              const SizedBox(height: 20),

              // Log out
              _MenuGroup(items: [
                _MenuItem(
                  icon: AppIcons.logout,
                  label: 'Log Out',
                  showChevron: false,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref
                        .read(authControllerProvider.notifier)
                        .logout();
                  },
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

class _MenuItem extends StatefulWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showChevron = true,
  });

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
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
                child: Center(
                  child: AppIcon(widget.icon, color: PennyPalColors.white, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: PennyPalColors.white,
                  ),
                ),
              ),
              if (widget.showChevron)
                const AppIcon(AppIcons.chevronRight,
                    color: PennyPalColors.muted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
