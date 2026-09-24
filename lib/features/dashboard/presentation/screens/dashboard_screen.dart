import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ── Status bar spacer ───────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(bottom: false, child: const SizedBox.shrink()),
          ),

          SliverToBoxAdapter(
            child: _DashHeader(greeting: greeting, firstName: firstName),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Balance card ──────────────────────────────────
                const _BalanceCard(),
                const SizedBox(height: 24),

                // ── Quick actions ─────────────────────────────────
                _QuickActions(context: context),
                const SizedBox(height: 28),

                // ── Budget ────────────────────────────────────────
                _SectionTitle(
                  title: 'Monthly Budget',
                  action: 'View all',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                const _BudgetCard(),
                const SizedBox(height: 28),

                // ── Spending breakdown ────────────────────────────
                const _SectionTitle(title: 'Spending breakdown'),
                const SizedBox(height: 12),
                const _SpendingCard(),
                const SizedBox(height: 28),

                // ── Recent transactions ───────────────────────────
                _SectionTitle(
                  title: 'Recent activity',
                  action: 'See all',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                const _RecentActivity(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — greeting + notification bell
// ─────────────────────────────────────────────────────────────────────────────

class _DashHeader extends StatelessWidget {
  const _DashHeader({required this.greeting, required this.firstName});
  final String greeting;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  firstName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          // Notification button
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: const Border.fromBorderSide(
                  BorderSide(color: Color(0xFFE8EDF2)),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 20,
                    color: AppColors.text,
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Balance card
// ─────────────────────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + change badge
          Row(
            children: [
              Text(
                'TOTAL BALANCE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 10,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '8.4% this month',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Amount
          const Text(
            '₦125,500',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),

          // Divider
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 18),

          // Income / Expenses
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: 'Income',
                  value: '₦180,000',
                  up: true,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              Expanded(
                child: _BalanceStat(
                  label: 'Expenses',
                  value: '₦54,500',
                  up: false,
                  alignRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({
    required this.label,
    required this.value,
    required this.up,
    this.alignRight = false,
  });
  final String label;
  final String value;
  final bool up;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: alignRight ? 20 : 0,
        right: alignRight ? 0 : 20,
      ),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  up
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 9,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick actions — horizontal scrollable row
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('Add Income', Icons.add_rounded, const Color(0xFF16A34A),
          const Color(0xFFF0FDF4), () => context.push('/add-income')),
      _Action('Add Expense', Icons.remove_rounded, const Color(0xFFDC2626),
          const Color(0xFFFFF1F2), () => context.push('/add-expense')),
      _Action('Savings', Icons.flag_outlined, AppColors.gold,
          const Color(0xFFFFFBEB), () {}),
      _Action('Budget', Icons.donut_large_outlined, const Color(0xFF4F46E5),
          const Color(0xFFF0F4FF), () {}),
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: a == actions.last ? 0 : 10,
            ),
            child: GestureDetector(
              onTap: a.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: a.bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: a.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(a.icon, size: 18, color: a.color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: a.color,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Action {
  const _Action(this.label, this.icon, this.color, this.bg, this.onTap);
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
}

// ─────────────────────────────────────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget card
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  const _BudgetCard();

  @override
  Widget build(BuildContext context) {
    const spent = 72500.0;
    const total = 100000.0;
    final ratio = spent / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFEDF0F4)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '₦72,500',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  'of ₦100,000',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '₦27,500 left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: const Color(0xFFEDF0F4),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(ratio * 100).toStringAsFixed(0)}% of monthly budget used',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spending breakdown — horizontal bars, no pie chart
// ─────────────────────────────────────────────────────────────────────────────

class _SpendingCard extends StatelessWidget {
  const _SpendingCard();

  static const _items = [
    _SpendItem('Food', 25000, 54500, Color(0xFF16A34A)),
    _SpendItem('Transport', 12500, 54500, Color(0xFF0D9488)),
    _SpendItem('Education', 8000, 54500, Color(0xFF4F46E5)),
    _SpendItem('Entertainment', 5000, 54500, Color(0xFFF59E0B)),
    _SpendItem('Other', 4000, 54500, Color(0xFF94A3B8)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFEDF0F4)),
        ),
      ),
      child: Column(
        children: _items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == _items.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
            child: _SpendRow(item: item),
          );
        }).toList(),
      ),
    );
  }
}

class _SpendItem {
  const _SpendItem(this.category, this.amount, this.total, this.color);
  final String category;
  final double amount;
  final double total;
  final Color color;
}

class _SpendRow extends StatelessWidget {
  const _SpendRow({required this.item});
  final _SpendItem item;

  String _fmt(double v) => '₦${v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      )}';

  @override
  Widget build(BuildContext context) {
    final ratio = (item.amount / item.total).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.category,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              _fmt(item.amount),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: const Color(0xFFEDF0F4),
            valueColor: AlwaysStoppedAnimation(item.color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent activity — no emojis, icon-based category markers
// ─────────────────────────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const _items = [
    _TxItem('Lunch', 'Food', 'Today', '₦3,500', false,
        Icons.restaurant_outlined, Color(0xFF16A34A)),
    _TxItem('Transport', 'Transport', 'Today', '₦1,200', false,
        Icons.directions_bus_outlined, Color(0xFF0D9488)),
    _TxItem('Freelance payment', 'Income', 'Yesterday', '₦50,000', true,
        Icons.work_outline_rounded, Color(0xFF4F46E5)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFEDF0F4)),
        ),
      ),
      child: Column(
        children: _items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == _items.length - 1;
          return Column(
            children: [
              _TxRow(item: item),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 66,
                  color: Color(0xFFF1F5F9),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TxItem {
  const _TxItem(this.title, this.category, this.date, this.amount,
      this.isIncome, this.icon, this.iconColor);
  final String title;
  final String category;
  final String date;
  final String amount;
  final bool isIncome;
  final IconData icon;
  final Color iconColor;
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.item});
  final _TxItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, size: 18, color: item.iconColor),
          ),
          const SizedBox(width: 12),

          // Title + category·date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.category}  ·  ${item.date}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${item.isIncome ? '+' : '-'}${item.amount}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: item.isIncome
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}
