import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/penny_widgets.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: _cleanBar('Financial Insights'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            Row(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: PennyPalColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(AppIcons.calendar,
                          size: 16, color: PennyPalColors.gray),
                      SizedBox(width: 6),
                      Text('September',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: PennyPalColors.white)),
                      SizedBox(width: 4),
                      AppIcon(AppIcons.chevronDown,
                          size: 16, color: PennyPalColors.gray),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Summary row
            const Row(children: [
              Expanded(
                  child: _StatCard(
                      label: 'Income',
                      value: '180,000',
                      icon: AppIcons.arrowDown)),
              SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                      label: 'Expenses',
                      value: '54,500',
                      icon: AppIcons.arrowUp)),
              SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                      label: 'Savings',
                      value: '75,500',
                      icon: AppIcons.piggyBank)),
            ]),
            const SizedBox(height: 28),

            // Spending trend
            const SectionHeader(title: 'Spending Trend'),
            const SizedBox(height: 14),
            InfoCard(
              child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.transparent,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: PennyPalColors.mutedBorder,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const months = [
                              'Apr','May','Jun','Jul','Aug','Sep'
                            ];
                            final i = v.toInt();
                            if (i < 0 || i >= months.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(months[i],
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: PennyPalColors.gray));
                          },
                          reservedSize: 24,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 62),
                          FlSpot(1, 71),
                          FlSpot(2, 58),
                          FlSpot(3, 80),
                          FlSpot(4, 68),
                          FlSpot(5, 54.5),
                        ],
                        isCurved: true,
                        color: PennyPalColors.white,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, _, _, _) =>
                              FlDotCirclePainter(
                            radius: 4,
                            color: PennyPalColors.white,
                            strokeWidth: 2,
                            strokeColor: PennyPalColors.surface,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: PennyPalColors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // By category donut
            const SectionHeader(title: 'Spending by Category'),
            const SizedBox(height: 14),
            InfoCard(
              child: Column(
                children: [
                  SizedBox(
                    height: 160,
                    child: PieChart(PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 44,
                      sections: [
                        PieChartSectionData(
                            value: 25000,
                            color: PennyPalColors.white,
                            radius: 32,
                            showTitle: false),
                        PieChartSectionData(
                            value: 12500,
                            color: PennyPalColors.offWhite,
                            radius: 32,
                            showTitle: false),
                        PieChartSectionData(
                            value: 8000,
                            color: PennyPalColors.lightGray,
                            radius: 32,
                            showTitle: false),
                        PieChartSectionData(
                            value: 5000,
                            color: PennyPalColors.gray,
                            radius: 32,
                            showTitle: false),
                        PieChartSectionData(
                            value: 4000,
                            color: PennyPalColors.darkGray,
                            radius: 32,
                            showTitle: false),
                      ],
                    )),
                  ),
                  const SizedBox(height: 14),
                  for (final item in <(List<List<dynamic>>, String, String, Color)>[
                    (AppIcons.food, 'Food', '25,000', PennyPalColors.white),
                    (AppIcons.transport, 'Transport', '12,500', PennyPalColors.offWhite),
                    (AppIcons.education, 'Education', '8,000', PennyPalColors.lightGray),
                    (AppIcons.entertainment, 'Entertainment', '5,000', PennyPalColors.gray),
                    (AppIcons.wallet, 'Other', '4,000', PennyPalColors.darkGray),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: PennyPalColors.elevated,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: AppIcon(item.$1, size: 12, color: item.$4),
                            )),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(item.$2,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: PennyPalColors.white))),
                        Text(item.$3,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: PennyPalColors.white)),
                      ]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Monthly comparison
            const SectionHeader(title: 'Monthly Comparison'),
            const SizedBox(height: 14),
            InfoCard(
              child: Column(
                children: [
                  for (final item in [
                    ('August', 0.68, PennyPalColors.lightGray),
                    ('September', 0.545, PennyPalColors.white),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        SizedBox(
                          width: 80,
                          child: Text(item.$1,
                              style: const TextStyle(
                                  fontSize: 13, color: PennyPalColors.gray)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: item.$2,
                              minHeight: 8,
                              backgroundColor: PennyPalColors.border,
                              valueColor: AlwaysStoppedAnimation(item.$3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(item.$2 * 100).toStringAsFixed(0)}k',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: PennyPalColors.white),
                        ),
                      ]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Insights
            const SectionHeader(title: 'Insights'),
            const SizedBox(height: 12),
            const InsightChip(
              icon: AppIcons.bulb,
              text: 'You spent 18% less on food this month.',
            ),
            const SizedBox(height: 10),
            const InsightChip(
              icon: AppIcons.chartBar,
              text: 'Entertainment spending increased by 12%.',
            ),
            const SizedBox(height: 10),
            const InsightChip(
              icon: AppIcons.target,
              text: "You're on track to reach your savings goal.",
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final List<List<dynamic>> icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: PennyPalColors.elevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PennyPalColors.border),
            ),
            child: AppIcon(icon, color: PennyPalColors.white, size: 16),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PennyPalColors.white)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: PennyPalColors.gray)),
        ],
      ),
    );
  }
}

AppBar _cleanBar(String title) => AppBar(
      backgroundColor: PennyPalColors.black,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: PennyPalColors.white)),
      iconTheme: const IconThemeData(color: PennyPalColors.white),
    );
