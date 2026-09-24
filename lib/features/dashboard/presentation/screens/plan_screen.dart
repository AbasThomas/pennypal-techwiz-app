import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/penny_widgets.dart';

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
      backgroundColor: PennyPalColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Plan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: PennyPalColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: PennyPalColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: PennyPalColors.elevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: PennyPalColors.white,
                  unselectedLabelColor: PennyPalColors.gray,
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

            // Content
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
      _BudgetCat(AppIcons.food, 'Food', 18000, 25000),
      _BudgetCat(AppIcons.transport, 'Transport', 8500, 15000),
      _BudgetCat(AppIcons.education, 'Education', 12000, 15000),
      _BudgetCat(AppIcons.shoppingBag, 'Shopping', 9500, 10000),
      _BudgetCat(AppIcons.entertainment, 'Entertainment', 6000, 5000),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
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
                              color: PennyPalColors.gray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '72,500 spent',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: PennyPalColors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'of 100,000 budget',
                            style: TextStyle(
                                fontSize: 13, color: PennyPalColors.gray),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: PennyPalColors.elevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: PennyPalColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          '73%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: PennyPalColors.white,
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
                    backgroundColor: PennyPalColors.border,
                    valueColor:
                        AlwaysStoppedAnimation(PennyPalColors.white),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('27,500 remaining',
                    style:
                        TextStyle(fontSize: 13, color: PennyPalColors.gray)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SectionHeader(title: 'Category Limits'),
          const SizedBox(height: 14),
          ...categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CategoryProgressBar(
                icon: c.icon,
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
  const _BudgetCat(this.icon, this.category, this.spent, this.limit);
  final List<List<dynamic>> icon;
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
      _Goal(AppIcons.freelance, 'New Laptop', 75000, 150000),
      _Goal(AppIcons.emergency, 'Emergency Fund', 40000, 200000),
      _Goal(AppIcons.travel, 'Trip', 22000, 80000),
      _Goal(AppIcons.piggyBank, 'Vault Savings', 55000, 80000),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
          InfoCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: PennyPalColors.elevated,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  child: const Center(
                    child: AppIcon(AppIcons.piggyBank,
                        color: PennyPalColors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Saved',
                        style:
                            TextStyle(fontSize: 13, color: PennyPalColors.gray)),
                    Text(
                      '192,000',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: PennyPalColors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
                icon: g.icon,
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
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateGoalSheet(),
    );
  }
}

class _Goal {
  const _Goal(this.icon, this.name, this.saved, this.target);
  final List<List<dynamic>> icon;
  final String name;
  final double saved;
  final double target;
}

// ─────────────────────────────────────────────────────────────────────────────
// Create goal bottom sheet with HugeIcons selector
// ─────────────────────────────────────────────────────────────────────────────

class _CreateGoalSheet extends StatefulWidget {
  const _CreateGoalSheet();
  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();

  final _icons = [
    AppIcons.target,
    AppIcons.house,
    AppIcons.travel,
    AppIcons.piggyBank,
    AppIcons.education,
    AppIcons.freelance,
    AppIcons.shoppingBag,
    AppIcons.emergency,
  ];
  int _selectedIndex = 0;

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
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: PennyPalColors.border),
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
                  color: PennyPalColors.border,
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
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text('What are you saving for?',
                style: TextStyle(color: PennyPalColors.gray, fontSize: 14)),
            const SizedBox(height: 20),

            // HugeIcon selector
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                itemBuilder: (_, i) {
                  final icon = _icons[i];
                  final selected = i == _selectedIndex;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIndex = i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? PennyPalColors.elevated
                            : PennyPalColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? PennyPalColors.white
                              : PennyPalColors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: AppIcon(
                          icon,
                          size: 20,
                          color: selected
                              ? PennyPalColors.white
                              : PennyPalColors.gray,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _name,
              style: const TextStyle(color: PennyPalColors.white),
              decoration: InputDecoration(
                labelText: 'Goal name',
                labelStyle: const TextStyle(color: PennyPalColors.gray),
                filled: true,
                fillColor: PennyPalColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PennyPalColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PennyPalColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PennyPalColors.white, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: PennyPalColors.white),
              decoration: InputDecoration(
                labelText: 'Target amount',
                labelStyle: const TextStyle(color: PennyPalColors.gray),
                filled: true,
                fillColor: PennyPalColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PennyPalColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PennyPalColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PennyPalColors.white, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PennyPalColors.white,
                  foregroundColor: PennyPalColors.black,
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
