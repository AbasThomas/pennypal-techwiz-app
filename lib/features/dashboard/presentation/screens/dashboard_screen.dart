import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
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
      backgroundColor: PennyPalColors.black,
      body: CustomScrollView(
        slivers: [
          // ── Status bar spacer ───────────────────────────────────
          const SliverToBoxAdapter(
            child: SafeArea(bottom: false, child: SizedBox.shrink()),
          ),

          SliverToBoxAdapter(
            child: _DashHeader(greeting: greeting, firstName: firstName),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Balance card (Section 6) ──────────────────────
                const _BalanceCard(),
                const SizedBox(height: 24),

                // ── Quick actions (Section 7) ─────────────────────
                _QuickActions(context: context),
                const SizedBox(height: 28),

                // ── Budget (Section 10) ───────────────────────────
                _SectionTitle(
                  title: 'Monthly Budget',
                  action: 'View all',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                const _BudgetCard(),
                const SizedBox(height: 28),

                // ── Spending breakdown (Section 12) ───────────────
                const _SectionTitle(title: 'Spending breakdown'),
                const SizedBox(height: 12),
                const _SpendingCard(),
                const SizedBox(height: 28),

                // ── Recent transactions (Section 9) ───────────────
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
// Header — clean monochrome greeting card with time-of-day lottie
// ─────────────────────────────────────────────────────────────────────────────

class _DashHeader extends StatelessWidget {
  const _DashHeader({required this.greeting, required this.firstName});
  final String greeting;
  final String firstName;

  static String _lottiePath(int hour) =>
      (hour >= 18 || hour < 6)
          ? 'assets/animations/Moon.json'
          : 'assets/animations/sunny.json';

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final lottiePath = _lottiePath(hour);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PennyPalColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Lottie ──────────────────────────────────────────
            Lottie.asset(
              lottiePath,
              width: 58,
              height: 58,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(width: 58, height: 58),
            ),
            const SizedBox(width: 14),

            // ── Text ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, 👋',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PennyPalColors.lightGray,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    firstName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: PennyPalColors.white,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Here's your financial overview.",
                    style: TextStyle(
                      fontSize: 12,
                      color: PennyPalColors.gray,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Notification button ──────────────────────────────
            GestureDetector(
              onTap: () => context.push('/notifications'),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: PennyPalColors.white,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: PennyPalColors.white,
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Balance card (Section 6)
// ─────────────────────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + change badge
          Row(
            children: [
              const Text(
                'TOTAL BALANCE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: PennyPalColors.gray,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 10,
                      color: PennyPalColors.white,
                    ),
                    SizedBox(width: 3),
                    Text(
                      '8.4% this month',
                      style: TextStyle(
                        fontSize: 11,
                        color: PennyPalColors.white,
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
              color: PennyPalColors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),

          // Divider
          const Divider(color: PennyPalColors.border, height: 1),
          const SizedBox(height: 18),

          // Income / Expenses
          const Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: 'Income',
                  value: '₦180,000',
                  up: true,
                ),
              ),
              SizedBox(
                height: 32,
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: PennyPalColors.border,
                ),
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
              if (!alignRight) ...[
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: PennyPalColors.elevated,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    up
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 10,
                    color: PennyPalColors.white,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: PennyPalColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (alignRight) ...[
                const SizedBox(width: 6),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: PennyPalColors.elevated,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    up
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 10,
                    color: PennyPalColors.white,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: PennyPalColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick actions (Section 7) — large prominent icons inside gray containers
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('Add Income', Icons.add_rounded, () => context.push('/add-income')),
      _Action('Add Expense', Icons.remove_rounded, () => context.push('/add-expense')),
      _Action('Savings', Icons.flag_outlined, () {}),
      _Action('Budget', Icons.donut_large_outlined, () {}),
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
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: PennyPalColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: PennyPalColors.border),
                      ),
                      child: Icon(a.icon, size: 24, color: PennyPalColors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PennyPalColors.white,
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
  const _Action(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
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
            color: PennyPalColors.white,
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
                color: PennyPalColors.lightGray,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget card (Section 10)
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
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PennyPalColors.border),
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
                  color: PennyPalColors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  'of ₦100,000',
                  style: TextStyle(
                    fontSize: 13,
                    color: PennyPalColors.gray,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: const Text(
                  '₦27,500 left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: PennyPalColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: PennyPalColors.border,
              valueColor:
                  const AlwaysStoppedAnimation(PennyPalColors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(ratio * 100).toStringAsFixed(0)}% of monthly budget used',
            style: const TextStyle(fontSize: 12, color: PennyPalColors.gray),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spending breakdown (Section 12) — monochrome bars
// ─────────────────────────────────────────────────────────────────────────────

class _SpendingCard extends StatelessWidget {
  const _SpendingCard();

  static const _items = [
    _SpendItem('Food', 25000, 54500, PennyPalColors.white),
    _SpendItem('Transport', 12500, 54500, PennyPalColors.offWhite),
    _SpendItem('Education', 8000, 54500, PennyPalColors.lightGray),
    _SpendItem('Entertainment', 5000, 54500, PennyPalColors.gray),
    _SpendItem('Other', 4000, 54500, PennyPalColors.darkGray),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PennyPalColors.border),
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
                  color: PennyPalColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              _fmt(item.amount),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white,
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
            backgroundColor: PennyPalColors.border,
            valueColor: AlwaysStoppedAnimation(item.color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent activity (Section 9) — monochrome icons & + / - distinction
// ─────────────────────────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const _items = [
    _TxItem('Lunch', 'Food', 'Today', '₦3,500', false,
        Icons.restaurant_outlined),
    _TxItem('Transport', 'Transport', 'Today', '₦1,200', false,
        Icons.directions_bus_outlined),
    _TxItem('Freelance payment', 'Income', 'Yesterday', '₦50,000', true,
        Icons.work_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PennyPalColors.border),
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
                  color: PennyPalColors.mutedBorder,
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
      this.isIncome, this.icon);
  final String title;
  final String category;
  final String date;
  final String amount;
  final bool isIncome;
  final IconData icon;
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
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PennyPalColors.elevated,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: PennyPalColors.border),
            ),
            child: Icon(item.icon, size: 18, color: PennyPalColors.white),
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
                    color: PennyPalColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.category}  ·  ${item.date}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: PennyPalColors.gray,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${item.isIncome ? '+' : '-'}${item.amount}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PennyPalColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
