import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
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
                const _BalanceCard(),
                const SizedBox(height: 24),

                _QuickActions(context: context),
                const SizedBox(height: 28),

                _SectionTitle(
                  title: 'Monthly Budget',
                  action: 'View all',
                  onAction: () => context.push('/budget'),
                ),
                const SizedBox(height: 12),
                const _BudgetCard(),
                const SizedBox(height: 28),

                const _SectionTitle(title: 'Spending Breakdown'),
                const SizedBox(height: 12),
                const _SpendingCard(),
                const SizedBox(height: 28),

                _SectionTitle(
                  title: 'Recent Activity',
                  action: 'See all',
                  onAction: () => context.push('/transactions'),
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
            Lottie.asset(
              lottiePath,
              width: 54,
              height: 54,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (_, _, _) =>
                  const SizedBox(width: 54, height: 54),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
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

            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/notifications');
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const AppIcon(
                      AppIcons.notification,
                      size: 20,
                      color: PennyPalColors.white,
                    ),
                    Positioned(
                      top: 11,
                      right: 11,
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
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    AppIcon(
                      AppIcons.arrowUp,
                      size: 10,
                      color: PennyPalColors.white,
                    ),
                    SizedBox(width: 4),
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

          const Text(
            '125,500.00',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: PennyPalColors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),

          const Divider(color: PennyPalColors.border, height: 1),
          const SizedBox(height: 18),

          const Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: 'Income',
                  value: '180,000',
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
                  value: '54,500',
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
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: PennyPalColors.elevated,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(
                      up ? AppIcons.arrowDown : AppIcons.arrowUp,
                      size: 11,
                      color: PennyPalColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: PennyPalColors.elevated,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(
                      up ? AppIcons.arrowDown : AppIcons.arrowUp,
                      size: 11,
                      color: PennyPalColors.white,
                    ),
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
// Quick actions — interactive spring touch with HugeIcons
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('Add Income', AppIcons.arrowDown, () => context.push('/add-income')),
      _Action('Add Expense', AppIcons.arrowUp, () => context.push('/add-expense')),
      _Action('Savings', AppIcons.piggyBank, () => context.push('/savings')),
      _Action('Budget', AppIcons.chart, () => context.push('/budget')),
    ];

    return Row(
      children: actions.asMap().entries.map((e) {
        final a = e.value;
        final isLast = e.key == actions.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: _InteractiveQuickActionTile(action: a),
          ),
        );
      }).toList(),
    );
  }
}

class _InteractiveQuickActionTile extends StatefulWidget {
  const _InteractiveQuickActionTile({required this.action});
  final _Action action;

  @override
  State<_InteractiveQuickActionTile> createState() => _InteractiveQuickActionTileState();
}

class _InteractiveQuickActionTileState extends State<_InteractiveQuickActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.action.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
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
                child: Center(
                  child: AppIcon(widget.action.icon, size: 22, color: PennyPalColors.white),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.action.label,
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
    );
  }
}

class _Action {
  const _Action(this.label, this.icon, this.onTap);
  final String label;
  final List<List<dynamic>> icon;
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
            onTap: () {
              HapticFeedback.selectionClick();
              onAction?.call();
            },
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
                '72,500',
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
                  'of 100,000',
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
                  '27,500 left',
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
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: ratio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, animatedRatio, _) {
                return LinearProgressIndicator(
                  value: animatedRatio,
                  minHeight: 7,
                  backgroundColor: PennyPalColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation(PennyPalColors.white),
                );
              },
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
// Spending breakdown — monochrome bars
// ─────────────────────────────────────────────────────────────────────────────

class _SpendingCard extends StatelessWidget {
  const _SpendingCard();

  static const _items = [
    _SpendItem('Food', 25000, 54500, PennyPalColors.white, AppIcons.food),
    _SpendItem('Transport', 12500, 54500, PennyPalColors.offWhite, AppIcons.transport),
    _SpendItem('Education', 8000, 54500, PennyPalColors.lightGray, AppIcons.education),
    _SpendItem('Entertainment', 5000, 54500, PennyPalColors.gray, AppIcons.entertainment),
    _SpendItem('Other', 4000, 54500, PennyPalColors.darkGray, AppIcons.wallet),
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
  const _SpendItem(this.category, this.amount, this.total, this.color, this.icon);
  final String category;
  final double amount;
  final double total;
  final Color color;
  final List<List<dynamic>> icon;
}

class _SpendRow extends StatelessWidget {
  const _SpendRow({required this.item});
  final _SpendItem item;

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );

  @override
  Widget build(BuildContext context) {
    final ratio = (item.amount / item.total).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: PennyPalColors.elevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: Center(
                child: AppIcon(item.icon, size: 13, color: item.color),
              ),
            ),
            const SizedBox(width: 10),
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
// Recent activity
// ─────────────────────────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const _items = [
    _TxItem('Lunch', 'Food', 'Today', '3,500', false, AppIcons.food),
    _TxItem('Transport', 'Transport', 'Today', '1,200', false, AppIcons.transport),
    _TxItem('Freelance payment', 'Income', 'Yesterday', '50,000', true, AppIcons.freelance),
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
  final List<List<dynamic>> icon;
}

class _TxRow extends StatefulWidget {
  const _TxRow({required this.item});
  final _TxItem item;

  @override
  State<_TxRow> createState() => _TxRowState();
}

class _TxRowState extends State<_TxRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: Center(
                  child: AppIcon(widget.item.icon, size: 18, color: PennyPalColors.white),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PennyPalColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.item.category}  ·  ${widget.item.date}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: PennyPalColors.gray,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${widget.item.isIncome ? '+ ' : '- '}${widget.item.amount}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: PennyPalColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
