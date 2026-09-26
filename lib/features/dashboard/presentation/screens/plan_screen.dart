import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/finance_providers.dart';
import '../../../../data/models/financial_models.dart';
import '../../../auth/providers/auth_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Currency formatter
// ─────────────────────────────────────────────────────────────────────────────

final _fmt = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
String _c(double v) => _fmt.format(v);

// ─────────────────────────────────────────────────────────────────────────────
// Plan screen — custom pill tab switcher (Budget | Savings)
// ─────────────────────────────────────────────────────────────────────────────

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});
  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  int _tab = 0; // 0 = Budget, 1 = Savings

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Plans',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: PennyPalColors.white,
                    ),
                  ),
                  const Spacer(),
                  // Contextual add button
                  GestureDetector(
                    onTap: () => _tab == 0
                        ? _showBudgetSheet(context)
                        : _showCreateGoalSheet(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: PennyPalColors.white,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Center(
                        child: Icon(Icons.add_rounded,
                            color: PennyPalColors.black, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Custom pill tab switcher ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PillTabBar(
                selected: _tab,
                tabs: const ['Budget', 'Savings'],
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 20),

            // ── Content ───────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: _tab == 0
                    ? _BudgetTab(
                        key: const ValueKey('budget'),
                        onEditBudget: (b) =>
                            _showBudgetSheet(context, existing: b),
                      )
                    : _SavingsTab(
                        key: const ValueKey('savings'),
                        onGoalTap: (g) =>
                            _showGoalDetail(context, g),
                        onCreateGoal: () =>
                            _showCreateGoalSheet(context),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sheets ─────────────────────────────────────────────────────────────────

  void _showBudgetSheet(BuildContext context, {Budget? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BudgetSheet(existing: existing),
    );
  }

  void _showCreateGoalSheet(BuildContext context, {SavingsGoal? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateGoalSheet(existing: existing),
    );
  }

  void _showGoalDetail(BuildContext context, SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalDetailSheet(
        goal: goal,
        onEdit: () {
          Navigator.pop(context);
          _showCreateGoalSheet(context, existing: goal);
        },
        onContribute: () {
          Navigator.pop(context);
          _showContributeSheet(context, goal);
        },
      ),
    );
  }

  void _showContributeSheet(BuildContext context, SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContributeSheet(goal: goal),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill tab bar
// ─────────────────────────────────────────────────────────────────────────────

class _PillTabBar extends StatelessWidget {
  const _PillTabBar({
    required this.selected,
    required this.tabs,
    required this.onChanged,
  });
  final int selected;
  final List<String> tabs;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 50,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x1FFFFFFF),
                Color(0x59181818),
                Color(0xA60A0A0A),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 22,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / tabs.length;
              return Stack(
                children: [
                  // Sliding glass capsule indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutBack,
                    left: selected * itemWidth,
                    top: 0,
                    bottom: 0,
                    width: itemWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.20),
                            Colors.white.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Labels
                  Row(
                    children: tabs.asMap().entries.map((e) {
                      final active = selected == e.key;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(e.key),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    active ? FontWeight.w800 : FontWeight.w600,
                                color: active
                                    ? PennyPalColors.white
                                    : PennyPalColors.muted,
                                letterSpacing: active ? 0.2 : 0.0,
                              ),
                              child: Text(e.value),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget tab
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetTab extends ConsumerWidget {
  const _BudgetTab({super.key, required this.onEditBudget});
  final void Function(Budget) onEditBudget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetSnap = ref.watch(budgetsProvider);
    final txSnap = ref.watch(transactionsProvider);

    return budgetSnap.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: PennyPalColors.white)),
      error: (e, _) => _PlanError(message: e.toString()),
      data: (budgets) {
        final transactions = txSnap.value ?? [];
        if (budgets.isEmpty) {
          return _PlanEmpty(
            icon: AppIcons.chart,
            title: 'No budget yet',
            message:
                'Tap + to create your monthly budget and track spending by category.',
          );
        }

        // Use the most recent / current month budget
        final now = DateFormat('yyyy-MM').format(DateTime.now());
        final Budget current = budgets.firstWhere(
          (b) => b.month == now,
          orElse: () => budgets.first,
        );

        // Total spent this month across all expenses
        final totalSpent = transactions
            .where((t) =>
                t.type == TransactionType.expense &&
                DateFormat('yyyy-MM').format(t.date) == current.month)
            .fold(0.0, (a, t) => a + t.amount);

        // Per-category spending
        final catSpending = <String, double>{};
        for (final t in transactions.where((t) =>
            t.type == TransactionType.expense &&
            DateFormat('yyyy-MM').format(t.date) == current.month)) {
          catSpending[t.categoryId] =
              (catSpending[t.categoryId] ?? 0) + t.amount;
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
          children: [
            // ── Month label ──────────────────────────────────────
            Row(
              children: [
                Text(
                  _monthLabel(current.month),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PennyPalColors.gray,
                  ),
                ),
                const SizedBox(width: 4),
                if (budgets.length > 1)
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: PennyPalColors.gray),
              ],
            ),
            const SizedBox(height: 14),

            // ── Monthly overview card ────────────────────────────
            _MonthlyCard(
              budget: current.limitAmount,
              spent: totalSpent,
              onTap: () => onEditBudget(current),
            ),
            const SizedBox(height: 26),

            // ── Category limits ──────────────────────────────────
            if (current.categoryLimits.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'Category Limits',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: PennyPalColors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...current.categoryLimits.entries.map((e) {
                final spent = catSpending[e.key] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _CategoryLimitRow(
                    category: e.key,
                    spent: spent,
                    limit: e.value,
                  ),
                );
              }),
            ] else ...[
              const Text(
                'Category Limits',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: PennyPalColors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No category limits set for this budget.\nEdit the budget to add limits.',
                style: TextStyle(fontSize: 13, color: PennyPalColors.gray),
              ),
            ],

            const SizedBox(height: 20),
            // ── Add category limit CTA ───────────────────────────
            GestureDetector(
              onTap: () => onEditBudget(current),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: PennyPalColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1.2,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        size: 18, color: PennyPalColors.white),
                    SizedBox(width: 6),
                    Text(
                      'Add Category Limit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PennyPalColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _monthLabel(String yyyyMM) {
    try {
      final dt = DateFormat('yyyy-MM').parse(yyyyMM);
      return DateFormat('MMMM yyyy').format(dt);
    } catch (_) {
      return yyyyMM;
    }
  }
}

// ── Monthly budget overview card ────────────────────────────────────────────

class _MonthlyCard extends StatelessWidget {
  const _MonthlyCard({
    required this.budget,
    required this.spent,
    required this.onTap,
  });
  final double budget;
  final double spent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final remaining = (budget - spent).clamp(0.0, double.infinity);
    final over = spent > budget ? spent - budget : 0.0;
    final ratio = budget == 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final pct = (ratio * 100).toStringAsFixed(1);

    Color barColor = PennyPalColors.white;
    if (ratio >= 1.0) {
      barColor = PennyPalColors.danger;
    } else if (ratio >= 0.8) {
      barColor = PennyPalColors.lightGray;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF242424),
              PennyPalColors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Budget',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: PennyPalColors.gray,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),

            // Three value row
            Row(
              children: [
                _MiniStat(label: 'Budget', value: _c(budget)),
                const SizedBox(width: 1),
                _VertDivider(),
                const SizedBox(width: 1),
                _MiniStat(label: 'Spent', value: _c(spent)),
                const SizedBox(width: 1),
                _VertDivider(),
                const SizedBox(width: 1),
                _MiniStat(
                  label: over > 0 ? 'Over' : 'Left',
                  value: _c(over > 0 ? over : remaining),
                  valueColor: over > 0
                      ? PennyPalColors.danger
                      : PennyPalColors.success,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 9,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$pct% used',
                  style: const TextStyle(
                      fontSize: 12, color: PennyPalColors.gray),
                ),
                const Spacer(),
                if (over > 0)
                  Text(
                    '${_c(over)} over budget',
                    style: const TextStyle(
                        fontSize: 12,
                        color: PennyPalColors.danger,
                        fontWeight: FontWeight.w600),
                  )
                else
                  Text(
                    '${_c(remaining)} remaining',
                    style: const TextStyle(
                        fontSize: 12, color: PennyPalColors.gray),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: PennyPalColors.gray,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: valueColor ?? PennyPalColors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 28, color: Colors.white.withValues(alpha: 0.10));
  }
}

// ── Category limit row ───────────────────────────────────────────────────────

class _CategoryLimitRow extends StatelessWidget {
  const _CategoryLimitRow({
    required this.category,
    required this.spent,
    required this.limit,
  });
  final String category;
  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final ratio = limit == 0 ? 0.0 : (spent / limit).clamp(0.0, 1.5);
    final pct = (spent / limit * 100).toStringAsFixed(0);
    final isOver = spent > limit;
    final remaining = limit - spent;

    Color barColor = PennyPalColors.white;
    if (isOver) {
      barColor = PennyPalColors.danger;
    } else if (ratio >= 0.8) {
      barColor = PennyPalColors.lightGray;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PennyPalColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOver
              ? PennyPalColors.danger.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: PennyPalColors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${_c(spent)} / ${_c(limit)}  ·  $pct%',
                style: const TextStyle(
                    fontSize: 12, color: PennyPalColors.gray),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: 8),
          isOver
              ? Text(
                  '${_c(spent - limit)} over budget',
                  style: const TextStyle(
                    fontSize: 12,
                    color: PennyPalColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Text(
                  '${_c(remaining)} remaining',
                  style: const TextStyle(
                      fontSize: 12, color: PennyPalColors.gray),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Savings tab
// ─────────────────────────────────────────────────────────────────────────────

class _SavingsTab extends ConsumerWidget {
  const _SavingsTab({
    super.key,
    required this.onGoalTap,
    required this.onCreateGoal,
  });
  final void Function(SavingsGoal) onGoalTap;
  final VoidCallback onCreateGoal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(savingsGoalsProvider);

    return snap.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: PennyPalColors.white)),
      error: (e, _) => _PlanError(message: e.toString()),
      data: (goals) {
        if (goals.isEmpty) {
          return _PlanEmpty(
            icon: AppIcons.piggyBank,
            title: 'No savings goals yet',
            message:
                'Tap + to create your first savings goal and start building toward it.',
            actionLabel: '+ Create Goal',
            onAction: onCreateGoal,
          );
        }

        final totalSaved =
            goals.fold(0.0, (a, g) => a + g.currentAmount);
        final totalTarget =
            goals.fold(0.0, (a, g) => a + g.targetAmount);
        final overallRatio = totalTarget == 0
            ? 0.0
            : (totalSaved / totalTarget).clamp(0.0, 1.0);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
          children: [
            // ── Total saved card ─────────────────────────────────
            _TotalSavedCard(
              totalSaved: totalSaved,
              totalTarget: totalTarget,
              ratio: overallRatio,
            ),
            const SizedBox(height: 26),

            const Text(
              'Your Goals',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 14),

            // ── Goal cards ───────────────────────────────────────
            ...goals.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _GoalCard(
                    goal: g,
                    onTap: () => onGoalTap(g),
                  ),
                )),

            // ── Create goal CTA ──────────────────────────────────
            GestureDetector(
              onTap: onCreateGoal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: PennyPalColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1.2,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        size: 18, color: PennyPalColors.white),
                    SizedBox(width: 6),
                    Text(
                      'Create Goal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PennyPalColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Total saved card ──────────────────────────────────────────────────────────

class _TotalSavedCard extends StatelessWidget {
  const _TotalSavedCard({
    required this.totalSaved,
    required this.totalTarget,
    required this.ratio,
  });
  final double totalSaved;
  final double totalTarget;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final left = (totalTarget - totalSaved).clamp(0.0, double.infinity);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E2A32),
            Color(0xFF161C22),
            PennyPalColors.surface,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL SAVED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _c(totalSaved),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${(ratio * 100).toStringAsFixed(0)}% of total target',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const Spacer(),
              Text(
                '${_c(left)} left',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Goal card ────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.onTap});
  final SavingsGoal goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ratio = goal.progress;
    final pct = (ratio * 100).toStringAsFixed(0);
    final remaining =
        (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
    final isComplete = goal.currentAmount >= goal.targetAmount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isComplete
                ? PennyPalColors.white.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Goal icon from name initial
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: PennyPalColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Center(
                    child: AppIcon(
                      AppIcons.forCategory(goal.goalName),
                      size: 20,
                      color: PennyPalColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.goalName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: PennyPalColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_c(goal.currentAmount)} / ${_c(goal.targetAmount)}',
                        style: const TextStyle(
                            fontSize: 12, color: PennyPalColors.gray),
                      ),
                    ],
                  ),
                ),
                // Percent badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? PennyPalColors.white.withValues(alpha: 0.12)
                        : PennyPalColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isComplete
                          ? PennyPalColors.white.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isComplete
                          ? PennyPalColors.white
                          : PennyPalColors.gray,
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
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                valueColor:
                    const AlwaysStoppedAnimation(PennyPalColors.white),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  isComplete
                      ? 'Goal reached!'
                      : '${_c(remaining)} remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: isComplete
                        ? PennyPalColors.success
                        : PennyPalColors.gray,
                    fontWeight: isComplete
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  'Target: ${DateFormat('MMM yyyy').format(goal.targetDate)}',
                  style: const TextStyle(
                      fontSize: 12, color: PennyPalColors.gray),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Goal detail bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _GoalDetailSheet extends ConsumerWidget {
  const _GoalDetailSheet({
    required this.goal,
    required this.onEdit,
    required this.onContribute,
  });
  final SavingsGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onContribute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio = goal.progress;
    final remaining =
        (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
    final isComplete = goal.currentAmount >= goal.targetAmount;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon + name
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: PennyPalColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Center(
                child: AppIcon(
                  AppIcons.forCategory(goal.goalName),
                  size: 28,
                  color: PennyPalColors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              goal.goalName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: PennyPalColors.white,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_c(goal.currentAmount)} of ${_c(goal.targetAmount)}',
              style: const TextStyle(
                  fontSize: 14, color: PennyPalColors.gray),
            ),
            const SizedBox(height: 20),

            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 12,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                valueColor:
                    const AlwaysStoppedAnimation(PennyPalColors.white),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(ratio * 100).toStringAsFixed(0)}% complete',
                  style: const TextStyle(
                      fontSize: 12, color: PennyPalColors.gray),
                ),
                Text(
                  isComplete
                      ? 'Goal reached!'
                      : '${_c(remaining)} remaining',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isComplete
                        ? PennyPalColors.success
                        : PennyPalColors.gray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: 16),

            // Detail rows
            _DetailRow(
              label: 'Monthly contribution',
              value: _c(goal.monthlyContribution),
            ),
            _DetailRow(
              label: 'Target date',
              value: DateFormat('MMMM yyyy').format(goal.targetDate),
            ),
            _DetailRow(
              label: 'Status',
              value: goal.status[0].toUpperCase() +
                  goal.status.substring(1),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: 20),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onContribute,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Savings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PennyPalColors.white,
                  foregroundColor: PennyPalColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: AppIcon(AppIcons.edit,
                        size: 15, color: PennyPalColors.white),
                    label: const Text('Edit Goal'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PennyPalColors.white,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref
                          .read(financeRepositoryProvider)
                          .deleteGoal(goal.id);
                    },
                    icon: AppIcon(AppIcons.delete,
                        size: 15, color: PennyPalColors.danger),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PennyPalColors.danger,
                      side: BorderSide(
                          color: PennyPalColors.danger.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: PennyPalColors.gray)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PennyPalColors.white)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Create / Edit goal sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CreateGoalSheet extends ConsumerStatefulWidget {
  const _CreateGoalSheet({this.existing});
  final SavingsGoal? existing;

  @override
  ConsumerState<_CreateGoalSheet> createState() =>
      _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<_CreateGoalSheet> {
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _current = TextEditingController();
  final _monthly = TextEditingController();
  DateTime _targetDate =
      DateTime(DateTime.now().year, DateTime.now().month + 3, 1);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final g = widget.existing!;
      _name.text = g.goalName;
      _target.text = g.targetAmount.toStringAsFixed(0);
      _current.text = g.currentAmount.toStringAsFixed(0);
      _monthly.text = g.monthlyContribution.toStringAsFixed(0);
      _targetDate = g.targetDate;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _current.dispose();
    _monthly.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final uid = ref.read(currentUserProvider)?.id;
    final targetAmt = double.tryParse(_target.text.replaceAll(',', ''));
    final currentAmt =
        double.tryParse(_current.text.replaceAll(',', '')) ?? 0.0;
    final monthlyAmt =
        double.tryParse(_monthly.text.replaceAll(',', '')) ?? 0.0;

    if (_name.text.trim().isEmpty || targetAmt == null || uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in goal name and target amount.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(financeRepositoryProvider).saveGoal(
            SavingsGoal(
              id: widget.existing?.id ?? '',
              userId: uid,
              goalName: _name.text.trim(),
              targetAmount: targetAmt,
              currentAmount: currentAmt,
              targetDate: _targetDate,
              monthlyContribution: monthlyAmt,
              status: currentAmt >= targetAmt ? 'completed' : 'active',
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEdit ? 'Edit Savings Goal' : 'Create Savings Goal',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEdit
                  ? 'Update your goal details.'
                  : 'What are you saving for?',
              style: const TextStyle(
                  fontSize: 14, color: PennyPalColors.gray),
            ),
            const SizedBox(height: 22),
            _SheetField(
              controller: _name,
              label: 'Goal name',
              hint: 'e.g. New Laptop',
              icon: AppIcons.edit,
            ),
            const SizedBox(height: 14),
            _SheetField(
              controller: _target,
              label: 'Target amount (₦)',
              hint: '500,000',
              icon: AppIcons.target,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _SheetField(
              controller: _current,
              label: 'Current savings (₦)',
              hint: '0',
              icon: AppIcons.piggyBank,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _SheetField(
              controller: _monthly,
              label: 'Monthly contribution (₦)',
              hint: '50,000',
              icon: AppIcons.money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),

            // Date picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Target date',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: PennyPalColors.white)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2040),
                      builder: (c, child) => Theme(
                        data: Theme.of(c).copyWith(
                          colorScheme: const ColorScheme.dark(
                              primary: PennyPalColors.white,
                              onPrimary: PennyPalColors.black,
                              surface: PennyPalColors.surface,
                              onSurface: PennyPalColors.white),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setState(() => _targetDate = picked);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: PennyPalColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10)),
                    ),
                    child: Row(
                      children: [
                        AppIcon(AppIcons.calendar,
                            size: 16, color: PennyPalColors.gray),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('dd MMM yyyy').format(_targetDate),
                          style: const TextStyle(
                              fontSize: 14, color: PennyPalColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PennyPalColors.white,
                  foregroundColor: PennyPalColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: PennyPalColors.black),
                      )
                    : Text(
                        isEdit ? 'Save Changes' : 'Create Goal',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
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
// Contribute (add savings) sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ContributeSheet extends ConsumerStatefulWidget {
  const _ContributeSheet({required this.goal});
  final SavingsGoal goal;

  @override
  ConsumerState<_ContributeSheet> createState() =>
      _ContributeSheetState();
}

class _ContributeSheetState extends ConsumerState<_ContributeSheet> {
  final _amount = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_amount.text.replaceAll(',', ''));
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final newTotal = widget.goal.currentAmount + value;
      await ref.read(financeRepositoryProvider).saveGoal(
            SavingsGoal(
              id: widget.goal.id,
              userId: widget.goal.userId,
              goalName: widget.goal.goalName,
              targetAmount: widget.goal.targetAmount,
              currentAmount: newTotal,
              targetDate: widget.goal.targetDate,
              monthlyContribution: widget.goal.monthlyContribution,
              status: newTotal >= widget.goal.targetAmount
                  ? 'completed'
                  : widget.goal.status,
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Savings',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: PennyPalColors.white),
            ),
            const SizedBox(height: 4),
            Text(
              widget.goal.goalName,
              style: const TextStyle(
                  fontSize: 14, color: PennyPalColors.gray),
            ),
            const SizedBox(height: 20),
            _SheetField(
              controller: _amount,
              label: 'Amount to add (₦)',
              hint: '10,000',
              icon: AppIcons.piggyBank,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PennyPalColors.white,
                  foregroundColor: PennyPalColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: PennyPalColors.black),
                      )
                    : const Text('Save',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget create/edit sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetSheet extends ConsumerStatefulWidget {
  const _BudgetSheet({this.existing});
  final Budget? existing;

  @override
  ConsumerState<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends ConsumerState<_BudgetSheet> {
  final _amount = TextEditingController();
  late String _month;
  bool _saving = false;

  // Category limits: category → controller
  final Map<String, TextEditingController> _catControllers = {};

  static const _defaultCategories = [
    'Food',
    'Transport',
    'Education',
    'Entertainment',
    'Shopping',
    'Health',
    'Utilities',
  ];

  @override
  void initState() {
    super.initState();
    _month = DateFormat('yyyy-MM').format(DateTime.now());
    if (widget.existing != null) {
      final b = widget.existing!;
      _amount.text = b.limitAmount.toStringAsFixed(0);
      _month = b.month;
      for (final entry in b.categoryLimits.entries) {
        _catControllers[entry.key] =
            TextEditingController(text: entry.value.toStringAsFixed(0));
      }
    }
    // Ensure default categories have controllers
    for (final cat in _defaultCategories) {
      _catControllers.putIfAbsent(cat, () => TextEditingController());
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    for (final c in _catControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final uid = ref.read(currentUserProvider)?.id;
    final limitAmt = double.tryParse(_amount.text.replaceAll(',', ''));
    if (limitAmt == null || limitAmt <= 0 || uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid budget amount.')),
      );
      return;
    }
    final catLimits = <String, double>{};
    for (final entry in _catControllers.entries) {
      final v = double.tryParse(entry.value.text.replaceAll(',', ''));
      if (v != null && v > 0) catLimits[entry.key] = v;
    }

    setState(() => _saving = true);
    try {
      await ref.read(financeRepositoryProvider).saveBudget(
            Budget(
              id: widget.existing?.id ?? '',
              userId: uid,
              month: _month,
              limitAmount: limitAmt,
              categoryLimits: catLimits,
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEdit ? 'Edit Budget' : 'Create Budget',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PennyPalColors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set your monthly spending limit.',
                style: TextStyle(fontSize: 14, color: PennyPalColors.gray),
              ),
              const SizedBox(height: 22),

              // Month
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Month',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: PennyPalColors.white)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (c, child) => Theme(
                          data: Theme.of(c).copyWith(
                            colorScheme: const ColorScheme.dark(
                                primary: PennyPalColors.white,
                                onPrimary: PennyPalColors.black,
                                surface: PennyPalColors.surface,
                                onSurface: PennyPalColors.white),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() =>
                            _month = DateFormat('yyyy-MM').format(picked));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: PennyPalColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: Row(
                        children: [
                          AppIcon(AppIcons.calendar,
                              size: 16, color: PennyPalColors.gray),
                          const SizedBox(width: 10),
                          Text(
                            _monthLabel(_month),
                            style: const TextStyle(
                                fontSize: 14, color: PennyPalColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _SheetField(
                controller: _amount,
                label: 'Monthly budget (₦)',
                hint: '100,000',
                icon: AppIcons.wallet,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              const Text(
                'Category Limits (optional)',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: PennyPalColors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set spending limits per category.',
                style: TextStyle(fontSize: 13, color: PennyPalColors.gray),
              ),
              const SizedBox(height: 14),

              ...(_catControllers.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SheetField(
                      controller: e.value,
                      label: e.key,
                      hint: 'Leave blank to skip',
                      icon: AppIcons.forCategory(e.key),
                      keyboardType: TextInputType.number,
                    ),
                  ))),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PennyPalColors.white,
                    foregroundColor: PennyPalColors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: PennyPalColors.black),
                        )
                      : Text(
                          isEdit ? 'Save Changes' : 'Create Budget',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthLabel(String yyyyMM) {
    try {
      return DateFormat('MMMM yyyy').format(DateFormat('yyyy-MM').parse(yyyyMM));
    } catch (_) {
      return yyyyMM;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sheet field widget
// ─────────────────────────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final List<List<dynamic>> icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PennyPalColors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: PennyPalColors.white),
          cursorColor: PennyPalColors.white,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: PennyPalColors.muted,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: AppIcon(icon, size: 16, color: PennyPalColors.gray),
            ),
            filled: true,
            fillColor: PennyPalColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: PennyPalColors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared empty / error states
// ─────────────────────────────────────────────────────────────────────────────

class _PlanEmpty extends StatelessWidget {
  const _PlanEmpty({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final List<List<dynamic>> icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PennyPalColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Center(
                child: AppIcon(icon,
                    size: 28,
                    color: PennyPalColors.gray),
              ),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: PennyPalColors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(
                    fontSize: 13, color: PennyPalColors.gray),
                textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PennyPalColors.white,
                  foregroundColor: PennyPalColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: Text(actionLabel!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanError extends StatelessWidget {
  const _PlanError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(AppIcons.warning,
                size: 40,
                color: PennyPalColors.gray),
            const SizedBox(height: 14),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PennyPalColors.white)),
            const SizedBox(height: 6),
            Text(message,
                style: const TextStyle(
                    fontSize: 13, color: PennyPalColors.gray),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
