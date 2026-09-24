import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_providers.dart';
import 'screens/dashboard_screen.dart';
import 'screens/money_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/more_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Nav item model
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const _navItems = [
  _NavItem(
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  _NavItem(
    label: 'Money',
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet_rounded,
  ),
  _NavItem(
    label: 'Plan',
    icon: Icons.pie_chart_outline_rounded,
    activeIcon: Icons.pie_chart_rounded,
  ),
  _NavItem(
    label: 'Learn',
    icon: Icons.auto_stories_outlined,
    activeIcon: Icons.auto_stories_rounded,
  ),
  _NavItem(
    label: 'More',
    icon: Icons.widgets_outlined,
    activeIcon: Icons.widgets_rounded,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Shell
// ─────────────────────────────────────────────────────────────────────────────

class PennyPalShell extends ConsumerStatefulWidget {
  const PennyPalShell({super.key});
  @override
  ConsumerState<PennyPalShell> createState() => _PennyPalShellState();
}

class _PennyPalShellState extends ConsumerState<PennyPalShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  void _onFab() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FabSheet(
        onAddIncome: () {
          Navigator.pop(context);
          context.push('/add-income');
        },
        onAddExpense: () {
          Navigator.pop(context);
          context.push('/add-expense');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final rawName = user?.firstName ??
        (user?.email.split('@').first ?? 'there');
    final firstName = rawName
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');

    final screens = [
      DashboardScreen(firstName: firstName),
      const MoneyScreen(),
      const PlanScreen(),
      const LearnScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      // extendBody lets content scroll behind the floating nav bar
      extendBody: true,
      body: IndexedStack(index: _index, children: screens),
      floatingActionButton: _index <= 1
          ? Padding(
              // Lift FAB above the floating nav bar
              padding: const EdgeInsets.only(bottom: 84),
              child: FloatingActionButton(
                onPressed: _onFab,
                backgroundColor: PennyPalColors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add_rounded,
                    color: PennyPalColors.black, size: 28),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _GlassNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: _navItems,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom bottom navigation bar (Section 16)
// ─────────────────────────────────────────────────────────────────────────────

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      // Float the bar above the system gesture area
      padding: EdgeInsets.fromLTRB(20, 0, 20, (bottomPad > 0 ? bottomPad : 16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: PennyPalColors.nearBlack.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: PennyPalColors.mutedBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final active = currentIndex == i;
                return Expanded(
                  child: _NavTile(
                    item: item,
                    active: active,
                    onTap: () => onTap(i),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual nav tile
// ─────────────────────────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: active ? PennyPalColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon ────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: child,
              ),
              child: Icon(
                active ? item.activeIcon : item.icon,
                key: ValueKey(active),
                size: 24,
                color: active ? PennyPalColors.white : PennyPalColors.muted,
              ),
            ),
            const SizedBox(height: 3),

            // ── Label ────────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? PennyPalColors.white : PennyPalColors.muted,
                letterSpacing: 0.1,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAB bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FabSheet extends StatelessWidget {
  const _FabSheet({
    required this.onAddIncome,
    required this.onAddExpense,
  });

  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: PennyPalColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add Transaction',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: PennyPalColors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SheetOption(
                  icon: Icons.arrow_downward_rounded,
                  label: '+ Income',
                  onTap: onAddIncome,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SheetOption(
                  icon: Icons.arrow_upward_rounded,
                  label: '- Expense',
                  onTap: onAddExpense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: PennyPalColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PennyPalColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: PennyPalColors.elevated,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: PennyPalColors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: PennyPalColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
