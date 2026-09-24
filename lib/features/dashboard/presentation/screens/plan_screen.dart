import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/penny_widgets.dart';

// Plan tab — hosts Budget and Savings as sub-tabs

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});
  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
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
                    'Plan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tab bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border.fromBorderSide(
                      BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.muted,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Budget'),
                    Tab(text: 'Savings'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),

            // ── Content ──────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  _BudgetTab(),
                  _SavingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget sub-tab
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetTab extends StatelessWidget {
  const _BudgetTab();

  @override
  Widget build(BuildContext context) {
    const categories = [
      _BudgetCat('🍔', 'Food', 18000, 25000),
      _BudgetCat('🚌', 'Transport', 8500, 15000),
      _BudgetCat('📚', 'Education', 12000, 15000),
      _BudgetCat('🛍', 'Shopping', 9500, 10000),
      _BudgetCat('🎬', 'Entertainment', 6000, 5000),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
          // ── Monthly overview card ──────────────────────────
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'September 2026',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '₦72,500 spent',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'of ₦100,000',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '73%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(
                    value: 0.725,
                    minHeight: 10,
                    backgroundColor: Color(0xFFE2E8F0),
                    valueColor:
                        AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('₦27,500 remaining',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Category limits ────────────────────────────────
          const SectionHeader(title: 'Category Limits'),
          const SizedBox(height: 14),
          ...categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CategoryProgressBar(
                emoji: c.emoji,
                category: c.category,
                spent: c.spent,
                limit: c.limit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCat {
  const _BudgetCat(this.emoji, this.category, this.spent, this.limit);
  final String emoji;
  final String category;
  final double spent;
  final double limit;
}

// ─────────────────────────────────────────────────────────────────────────────
// Savings sub-tab
// ─────────────────────────────────────────────────────────────────────────────

class _SavingsTab extends StatelessWidget {
  const _SavingsTab();

  @override
  Widget build(BuildContext context) {
    const goals = [
      _Goal('🎓', 'New Laptop', 75000, 150000),
      _Goal('🏠', 'Emergency Fund', 40000, 200000),
      _Goal('✈️', 'Trip', 22000, 80000),
      _Goal('📱', 'New Phone', 55000, 80000),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
          // ── Total saved ────────────────────────────────────
          InfoCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.flag_rounded,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Saved',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.muted)),
                    Text(
                      '₦192,000',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Goals ──────────────────────────────────────────
          SectionHeader(
            title: 'Your Goals',
            actionLabel: '+ New Goal',
            onAction: () => _showCreateGoalSheet(context),
          ),
          const SizedBox(height: 14),
          ...goals.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GoalCard(
                emoji: g.emoji,
                name: g.name,
                saved: g.saved,
                target: g.target,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateGoalSheet(),
    );
  }
}

class _Goal {
  const _Goal(this.emoji, this.name, this.saved, this.target);
  final String emoji;
  final String name;
  final double saved;
  final double target;
}

// ─────────────────────────────────────────────────────────────────────────────
// Create goal bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CreateGoalSheet extends StatefulWidget {
  const _CreateGoalSheet();
  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();

  final _emojis = ['🎓', '🏠', '✈️', '📱', '💻', '🎯', '🛒', '💰'];
  String _selectedEmoji = '🎯';

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Create Savings Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text('What are you saving for?',
                style: TextStyle(color: AppColors.muted, fontSize: 14)),
            const SizedBox(height: 20),

            // ── Emoji picker ─────────────────────────────────
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _emojis.length,
                itemBuilder: (_, i) {
                  final e = _emojis[i];
                  final selected = e == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 46,
                      height: 46,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child:
                            Text(e, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: 'Goal name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target amount (₦)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Create Goal',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
