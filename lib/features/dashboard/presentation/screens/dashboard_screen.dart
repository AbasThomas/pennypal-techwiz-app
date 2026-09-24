import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/penny_widgets.dart';

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

    // ── Sample data (replace with real providers) ─────────────────
    const balance = '₦125,500';
    const income = '₦180,000';
    const expenses = '₦54,500';
    const changePercent = '+8.4%';

    final spendingData = [
      _SpendEntry('Food', 25000, const Color(0xFF16A34A)),
      _SpendEntry('Transport', 12500, const Color(0xFF0D9488)),
      _SpendEntry('Education', 8000, const Color(0xFF7C3AED)),
      _SpendEntry('Entertainment', 5000, const Color(0xFFF59E0B)),
      _SpendEntry('Other', 4000, const Color(0xFF64748B)),
    ];

    const recentTx = [
      _TxData('🍔', 'Lunch', 'Food · Today', '₦3,500', false),
      _TxData('🚌', 'Transport', 'Transport · Today', '₦1,200', false),
      _TxData('💼', 'Freelance', 'Income · Yesterday', '₦50,000', true),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────────
            SliverAppBar(
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              floating: true,
              elevation: 0,
              titleSpacing: 24,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $firstName 👋',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Text(
                    "Here's how your money is doing.",
                    style:
                        TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.text),
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Balance card ────────────────────────────
                  const BalanceCard(
                    balance: balance,
                    income: income,
                    expenses: expenses,
                    changePercent: changePercent,
                  ),
                  const SizedBox(height: 28),

                  // ── Quick actions ───────────────────────────
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                    children: [
                      QuickActionButton(
                        icon: Icons.add_rounded,
                        label: 'Income',
                        onTap: () => context.push('/add-income'),
                        color: const Color(0xFFF0FDF4),
                        iconColor: const Color(0xFF16A34A),
                      ),
                      QuickActionButton(
                        icon: Icons.remove_rounded,
                        label: 'Expense',
                        onTap: () => context.push('/add-expense'),
                        color: const Color(0xFFFFF1F2),
                        iconColor: const Color(0xFFDC2626),
                      ),
                      QuickActionButton(
                        icon: Icons.flag_rounded,
                        label: 'Savings',
                        onTap: () {},
                        color: const Color(0xFFFFFBEB),
                        iconColor: AppColors.gold,
                      ),
                      QuickActionButton(
                        icon: Icons.bar_chart_rounded,
                        label: 'Budget',
                        onTap: () {},
                        color: const Color(0xFFF0F4FF),
                        iconColor: const Color(0xFF4F46E5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Budget summary ──────────────────────────
                  const SectionHeader(
                    title: 'Monthly Budget',
                    actionLabel: 'View Budget →',
                  ),
                  const SizedBox(height: 14),
                  InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              '₦72,500',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              ' / ₦100,000',
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: const LinearProgressIndicator(
                            value: 0.725,
                            minHeight: 10,
                            backgroundColor: Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation(
                                AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '₦27,500 remaining',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Spending overview ───────────────────────
                  const SectionHeader(title: 'Spending this month'),
                  const SizedBox(height: 14),
                  InfoCard(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 48,
                              sections: spendingData
                                  .map(
                                    (e) => PieChartSectionData(
                                      value: e.amount,
                                      color: e.color,
                                      radius: 36,
                                      showTitle: false,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...spendingData.map(
                          (e) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: e.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(e.category,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.text))),
                                Text(
                                  '₦${e.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Recent transactions ─────────────────────
                  SectionHeader(
                    title: 'Recent Activity',
                    actionLabel: 'See all',
                    onAction: () {},
                  ),
                  const SizedBox(height: 4),
                  InfoCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Column(
                      children: recentTx
                          .map(
                            (t) => TransactionTile(
                              emoji: t.emoji,
                              title: t.title,
                              subtitle: t.subtitle,
                              amount: t.amount,
                              isIncome: t.isIncome,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendEntry {
  const _SpendEntry(this.category, this.amount, this.color);
  final String category;
  final double amount;
  final Color color;
}

class _TxData {
  const _TxData(this.emoji, this.title, this.subtitle, this.amount,
      this.isIncome);
  final String emoji;
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
}
