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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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
    final firstName = user?.firstName ??
        (user?.email.split('@').first ?? 'there');

    final screens = [
      DashboardScreen(firstName: firstName),
      const MoneyScreen(),
      const PlanScreen(),
      const LearnScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: screens),
      floatingActionButton: _index <= 1
          ? FloatingActionButton(
              onPressed: _onFab,
              backgroundColor: AppColors.primary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 28),
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 62,
        indicatorColor: AppColors.primary.withValues(alpha: 0.10),
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 22),
            selectedIcon: Icon(Icons.home_rounded, size: 22),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, size: 22),
            selectedIcon: Icon(Icons.receipt_long_rounded, size: 22),
            label: 'Money',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined, size: 22),
            selectedIcon: Icon(Icons.track_changes_rounded, size: 22),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, size: 22),
            selectedIcon: Icon(Icons.menu_book_rounded, size: 22),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined, size: 22),
            selectedIcon: Icon(Icons.grid_view_rounded, size: 22),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// ── FAB bottom sheet ──────────────────────────────────────────────────────────

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add Transaction',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SheetOption(
                  icon: Icons.arrow_downward_rounded,
                  label: '+ Income',
                  color: const Color(0xFF16A34A),
                  bg: const Color(0xFFF0FDF4),
                  onTap: onAddIncome,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SheetOption(
                  icon: Icons.arrow_upward_rounded,
                  label: '- Expense',
                  color: const Color(0xFFDC2626),
                  bg: const Color(0xFFFFF1F2),
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
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
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
