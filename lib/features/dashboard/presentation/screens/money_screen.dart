import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/penny_widgets.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});
  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  int _filterIndex = 0; // 0=All 1=Income 2=Expenses
  final _search = TextEditingController();

  static const _transactions = [
    _Tx('🍔', 'Lunch', 'Food', 'Today', '₦3,500', false),
    _Tx('🚌', 'Transport', 'Transport', 'Today', '₦1,200', false),
    _Tx('💼', 'Freelance Payment', 'Income', 'Sep 23', '₦50,000', true),
    _Tx('📚', 'Textbooks', 'Education', 'Sep 22', '₦8,000', false),
    _Tx('🛍', 'Shopping', 'Shopping', 'Sep 21', '₦4,500', false),
    _Tx('💰', 'Salary', 'Income', 'Sep 20', '₦130,000', true),
    _Tx('🍕', 'Dinner', 'Food', 'Sep 19', '₦5,200', false),
    _Tx('🎬', 'Netflix', 'Entertainment', 'Sep 18', '₦2,900', false),
  ];

  List<_Tx> get _filtered {
    var list = _transactions;
    if (_filterIndex == 1) list = list.where((t) => t.isIncome).toList();
    if (_filterIndex == 2) list = list.where((t) => !t.isIncome).toList();
    final q = _search.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
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
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list_rounded,
                        color: AppColors.text),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Search ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search transactions…',
                  hintStyle: const TextStyle(color: AppColors.muted),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.muted, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Filter tabs ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['All', 'Income', 'Expenses']
                    .asMap()
                    .entries
                    .map(
                      (e) => GestureDetector(
                        onTap: () =>
                            setState(() => _filterIndex = e.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _filterIndex == e.key
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _filterIndex == e.key
                                  ? AppColors.primary
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _filterIndex == e.key
                                  ? Colors.white
                                  : AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),

            // ── List ─────────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? const PennyEmptyState(
                      emoji: '🔍',
                      title: 'No transactions found',
                      message:
                          'Try adjusting your search or filter.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (_, i) {
                        final t = _filtered[i];
                        return TransactionTile(
                          emoji: t.emoji,
                          title: t.title,
                          subtitle: '${t.category} · ${t.date}',
                          amount: t.amount,
                          isIncome: t.isIncome,
                          onTap: () =>
                              context.push('/transaction-detail'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tx {
  const _Tx(this.emoji, this.title, this.category, this.date,
      this.amount, this.isIncome);
  final String emoji;
  final String title;
  final String category;
  final String date;
  final String amount;
  final bool isIncome;
}
