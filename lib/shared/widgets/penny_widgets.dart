// Shared UI building blocks used across all PennyPal feature screens.
// Import this file to get: BalanceCard, SectionHeader, QuickActionButton,
// TransactionTile, CategoryProgressBar, GoalCard, PennyEmptyState, InfoCard, InsightChip.

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Balance card — hero element on the Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
    this.changePercent,
    this.changePositive = true,
  });

  final String balance;
  final String income;
  final String expenses;
  final String? changePercent;
  final bool changePositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + badge
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
              if (changePercent != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: PennyPalColors.elevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        changePositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 11,
                        color: PennyPalColors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        changePercent!,
                        style: const TextStyle(
                          color: PennyPalColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Amount
          Text(
            balance,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: PennyPalColors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Divider
          const Divider(color: PennyPalColors.border, height: 1),
          const SizedBox(height: 18),

          // Income / Expenses row
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Income',
                  value: income,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: PennyPalColors.border,
              ),
              Expanded(
                child: _BalanceStat(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Expenses',
                  value: expenses,
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
    required this.icon,
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final align =
        alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Padding(
      padding: EdgeInsets.only(
          left: alignRight ? 16 : 0, right: alignRight ? 0 : 16),
      child: Column(
        crossAxisAlignment: align,
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
                  child: Icon(icon, size: 10, color: PennyPalColors.white),
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
                  child: Icon(icon, size: 10, color: PennyPalColors.white),
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
// Section header — label + optional action link
// ─────────────────────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: PennyPalColors.white,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: PennyPalColors.lightGray,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick action button — large icon tile inside gray container
// ─────────────────────────────────────────────────────────────────────────────

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? PennyPalColors.elevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PennyPalColors.border,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: iconColor ?? PennyPalColors.white),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iconColor ?? PennyPalColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction tile — monochrome styling (+ / - distinction)
// ─────────────────────────────────────────────────────────────────────────────

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: PennyPalColors.card,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: PennyPalColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: PennyPalColors.gray,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}$amount',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: PennyPalColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category progress bar — monochrome progress
// ─────────────────────────────────────────────────────────────────────────────

enum BudgetStatus { healthy, warning, exceeded }

class CategoryProgressBar extends StatelessWidget {
  const CategoryProgressBar({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    this.emoji,
  });

  final String category;
  final double spent;
  final double limit;
  final String? emoji;

  BudgetStatus get _status {
    final ratio = spent / limit;
    if (ratio >= 1.0) return BudgetStatus.exceeded;
    if (ratio >= 0.8) return BudgetStatus.warning;
    return BudgetStatus.healthy;
  }

  Color get _color {
    switch (_status) {
      case BudgetStatus.healthy:
        return PennyPalColors.white;
      case BudgetStatus.warning:
      case BudgetStatus.exceeded:
        return PennyPalColors.lightGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (spent / limit).clamp(0.0, 1.0);
    final spentFmt =
        '₦${spent.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
    final limitFmt =
        '₦${limit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
            ],
            Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: PennyPalColors.white,
              ),
            ),
            const Spacer(),
            Text(
              '$spentFmt / $limitFmt',
              style: const TextStyle(fontSize: 12, color: PennyPalColors.gray),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: PennyPalColors.border,
            valueColor: AlwaysStoppedAnimation(_color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Goal card — used in Savings screen
// ─────────────────────────────────────────────────────────────────────────────

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.saved,
    required this.target,
    this.onTap,
  });

  final String emoji;
  final String name;
  final double saved;
  final double target;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ratio = (saved / target).clamp(0.0, 1.0);
    final pct = (ratio * 100).toStringAsFixed(0);
    final remaining = target - saved;
    final remainFmt =
        '₦${remaining.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
    final savedFmt =
        '₦${saved.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
    final targetFmt =
        '₦${target.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PennyPalColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: PennyPalColors.white,
                        ),
                      ),
                      Text(
                        '$savedFmt / $targetFmt',
                        style: const TextStyle(
                            fontSize: 12, color: PennyPalColors.gray),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PennyPalColors.elevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  child: Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
                minHeight: 8,
                backgroundColor: PennyPalColors.border,
                valueColor:
                    const AlwaysStoppedAnimation(PennyPalColors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$remainFmt remaining',
              style: const TextStyle(fontSize: 12, color: PennyPalColors.gray),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state — used across list screens
// ─────────────────────────────────────────────────────────────────────────────

class PennyEmptyState extends StatelessWidget {
  const PennyEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String emoji;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: PennyPalColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PennyPalColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: PennyPalColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: PennyPalColors.gray),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PennyPalColors.white,
                    foregroundColor: PennyPalColors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info card — dark surface tile used in Reports / Learning / Plan
// ─────────────────────────────────────────────────────────────────────────────

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Insight chip — monochrome tip tile in Reports
// ─────────────────────────────────────────────────────────────────────────────

class InsightChip extends StatelessWidget {
  const InsightChip({
    super.key,
    required this.emoji,
    required this.text,
    this.color,
  });

  final String emoji;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: PennyPalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: PennyPalColors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
