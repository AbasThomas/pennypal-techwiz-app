import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
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
    _Tx(AppIcons.food, 'Lunch', 'Food', 'Today', '3,500', false),
    _Tx(AppIcons.transport, 'Transport', 'Transport', 'Today', '1,200', false),
    _Tx(AppIcons.freelance, 'Freelance Payment', 'Income', 'Sep 23', '50,000', true),
    _Tx(AppIcons.education, 'Textbooks', 'Education', 'Sep 22', '8,000', false),
    _Tx(AppIcons.shoppingBag, 'Shopping', 'Shopping', 'Sep 21', '4,500', false),
    _Tx(AppIcons.salary, 'Salary', 'Income', 'Sep 20', '130,000', true),
    _Tx(AppIcons.food, 'Dinner', 'Food', 'Sep 19', '5,200', false),
    _Tx(AppIcons.entertainment, 'Netflix', 'Entertainment', 'Sep 18', '2,900', false),
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
      backgroundColor: PennyPalColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                    onPressed: () {
                      HapticFeedback.lightImpact();
                    },
                    icon: const AppIcon(AppIcons.filter,
                        color: PennyPalColors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: PennyPalColors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search transactions…',
                  hintStyle: const TextStyle(color: PennyPalColors.muted),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: AppIcon(AppIcons.search,
                        color: PennyPalColors.muted, size: 20),
                  ),
                  filled: true,
                  fillColor: PennyPalColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: PennyPalColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: PennyPalColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: PennyPalColors.white, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Filter tabs
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
                              horizontal: 16, vertical: 8),
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

            // List
            Expanded(
              child: _filtered.isEmpty
                  ? const PennyEmptyState(
                      icon: AppIcons.search,
                      title: 'No transactions found',
                      message:
                          'Try adjusting your search or filter.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => const Divider(
                          height: 1, color: PennyPalColors.mutedBorder),
                      itemBuilder: (_, i) {
                        final t = _filtered[i];
                        return TransactionTile(
                          icon: t.icon,
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
  const _Tx(this.icon, this.title, this.category, this.date,
      this.amount, this.isIncome);
  final List<List<dynamic>> icon;
  final String title;
  final String category;
  final String date;
  final String amount;
  final bool isIncome;
}
