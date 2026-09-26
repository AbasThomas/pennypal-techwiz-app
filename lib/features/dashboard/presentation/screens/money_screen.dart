import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/finance_providers.dart';
import '../../../../data/models/financial_models.dart';
import '../../../../shared/widgets/penny_widgets.dart';

final _money = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({super.key});
  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen> {
  int _filterIndex = 0; // 0=All 1=Income 2=Expenses
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<FinanceTransaction> _applyFilters(List<FinanceTransaction> source) {
    var list = [...source]
      ..sort((a, b) => b.date.compareTo(a.date));
    if (_filterIndex == 1) {
      list = list.where((t) => t.type == TransactionType.income).toList();
    } else if (_filterIndex == 2) {
      list = list.where((t) => t.type == TransactionType.expense).toList();
    }
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((t) =>
              t.description.toLowerCase().contains(q) ||
              t.categoryId.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      body: SafeArea(
        child: txState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: PennyPalColors.white),
          ),
          error: (e, _) => _LoadError(message: e.toString()),
          data: (transactions) {
            final now = DateTime.now();
            final prev = DateTime(now.year, now.month - 1);

            double sumFor(List<FinanceTransaction> tx, TransactionType type,
                    DateTime month) =>
                tx
                    .where((t) =>
                        t.type == type &&
                        t.date.year == month.year &&
                        t.date.month == month.month)
                    .fold<double>(0, (a, t) => a + t.amount);

            final income = sumFor(transactions, TransactionType.income, now);
            final expense = sumFor(transactions, TransactionType.expense, now);
            final prevIncome =
                sumFor(transactions, TransactionType.income, prev);
            final prevExpense =
                sumFor(transactions, TransactionType.expense, prev);

            final visible = _applyFilters(transactions);
            final monthLabel =
                DateFormat('MMMM').format(now).toUpperCase();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      const Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: PennyPalColors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => HapticFeedback.lightImpact(),
                        icon: const AppIcon(
                          AppIcons.filter,
                          color: PennyPalColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── Month overview ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '$monthLabel OVERVIEW',
                    style: const TextStyle(
                      color: PennyPalColors.gray,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Income',
                            amount: income,
                            icon: AppIcons.arrowDown,
                            accent: PennyPalColors.success,
                            accentSurface: PennyPalColors.successSurface,
                            previous: prevIncome,
                            goodWhenUp: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Expenses',
                            amount: expense,
                            icon: AppIcons.arrowUp,
                            accent: PennyPalColors.danger,
                            accentSurface: PennyPalColors.dangerSurface,
                            previous: prevExpense,
                            goodWhenUp: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Search ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      color: PennyPalColors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search transactions…',
                      hintStyle:
                          const TextStyle(color: PennyPalColors.muted),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12),
                        child: AppIcon(
                          AppIcons.search,
                          color: PennyPalColors.muted,
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: PennyPalColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: PennyPalColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: PennyPalColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: PennyPalColors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Filter tabs ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: ['All', 'Income', 'Expenses']
                        .asMap()
                        .entries
                        .map(
                          (e) => GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _filterIndex = e.key);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _filterIndex == e.key
                                    ? PennyPalColors.white
                                    : PennyPalColors.surface,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: _filterIndex == e.key
                                      ? PennyPalColors.white
                                      : PennyPalColors.border,
                                ),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _filterIndex == e.key
                                      ? PennyPalColors.black
                                      : PennyPalColors.gray,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // ── List ────────────────────────────────────────
                Expanded(
                  child: transactions.isEmpty
                      ? const PennyEmptyState(
                          icon: AppIcons.wallet,
                          title: 'No transactions yet',
                          message:
                              'Add your first income or expense to start tracking your money.',
                        )
                      : visible.isEmpty
                          ? const PennyEmptyState(
                              icon: AppIcons.search,
                              title: 'No transactions found',
                              message:
                                  'Try adjusting your search or filter.',
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 8, 20, 100),
                              itemCount: visible.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                color: PennyPalColors.mutedBorder,
                              ),
                              itemBuilder: (_, i) {
                                final t = visible[i];
                                final isIncome =
                                    t.type == TransactionType.income;
                                return TransactionTile(
                                  icon: AppIcons.forCategory(t.categoryId),
                                  title: t.description.isEmpty
                                      ? t.categoryId
                                      : t.description,
                                  subtitle:
                                      '${t.categoryId} · ${_relativeDate(t.date)}',
                                  amount: _money.format(t.amount),
                                  isIncome: isIncome,
                                  onTap: () =>
                                      context.push('/transaction-detail'),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _relativeDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return DateFormat('MMM d').format(d);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary card — clean, professional income / expense tile
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.accent,
    required this.accentSurface,
    required this.previous,
    required this.goodWhenUp,
  });

  final String label;
  final double amount;
  final List<List<dynamic>> icon;
  final Color accent;
  final Color accentSurface;
  final double previous;
  final bool goodWhenUp;

  @override
  Widget build(BuildContext context) {
    // Real month-over-month change; null when there is no prior baseline.
    double? changePct;
    if (previous > 0) {
      changePct = ((amount - previous) / previous) * 100;
    }
    final isUp = (changePct ?? 0) >= 0;
    final changeIsGood = goodWhenUp ? isUp : !isUp;
    final trendColor = changePct == null
        ? PennyPalColors.gray
        : (changeIsGood ? PennyPalColors.success : PennyPalColors.danger);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
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
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: AppIcon(icon, size: 17, color: accent),
                ),
              ),
              const Spacer(),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: PennyPalColors.gray,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _money.format(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PennyPalColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          if (changePct == null)
            const Text(
              'No prior month data',
              style: TextStyle(
                color: PennyPalColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Row(
              children: [
                AppIcon(
                  isUp ? AppIcons.arrowUp : AppIcons.arrowDown,
                  size: 12,
                  color: trendColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${changePct.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'vs last month',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: PennyPalColors.gray,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Load error state
// ─────────────────────────────────────────────────────────────────────────────

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon(AppIcons.warning,
                size: 40, color: PennyPalColors.gray),
            const SizedBox(height: 14),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: PennyPalColors.gray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
