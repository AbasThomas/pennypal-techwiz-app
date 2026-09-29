import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AdminAnalyticsTab extends StatelessWidget {
  const AdminAnalyticsTab({super.key});

  static const _days = 14;

  @override
  Widget build(BuildContext context) {
    final cutoff = DateTime.now().subtract(const Duration(days: _days - 1));
    final start = DateTime(cutoff.year, cutoff.month, cutoff.day);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Usage analytics', style: TextStyle(color: PennyPalColors.white, fontSize: 25, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Aggregated to protect student financial privacy.', style: TextStyle(color: PennyPalColors.gray, fontSize: 12.5)),
        const SizedBox(height: 20),
        _SignupsChart(start: start),
        const SizedBox(height: 16),
        _TransactionsChart(start: start),
        const SizedBox(height: 16),
        _FeedbackPie(),
        const SizedBox(height: 16),
        _SupportPie(),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.subtitle, required this.child});
  final String title, subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PennyPalColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: PennyPalColors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: PennyPalColors.gray, fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: child),
          ],
        ),
      );
}

class _SignupsChart extends StatelessWidget {
  const _SignupsChart({required this.start});
  final DateTime start;

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('userProfiles')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .snapshots(),
        builder: (_, s) {
          final buckets = List<int>.filled(AdminAnalyticsTab._days, 0);
          var total = 0;
          if (s.hasData) {
            for (final d in s.data!.docs) {
              if ('${d.data()['role'] ?? 'student'}'.toLowerCase() == 'admin') continue;
              final dt = _toDate(d.data()['createdAt']);
              if (dt == null) continue;
              final day = DateTime(dt.year, dt.month, dt.day).difference(start).inDays;
              if (day >= 0 && day < AdminAnalyticsTab._days) buckets[day]++;
            }
            total = buckets.fold(0, (a, b) => a + b);
          }
          return _ChartCard(
            title: 'New student signups',
            subtitle: '$total in the last ${AdminAnalyticsTab._days} days',
            child: s.hasData
                ? _LineChart(buckets: buckets, start: start, color: PennyPalColors.success)
                : const Center(child: CircularProgressIndicator()),
          );
        },
      );
}

class _TransactionsChart extends StatelessWidget {
  const _TransactionsChart({required this.start});
  final DateTime start;

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .snapshots(),
        builder: (_, s) {
          final buckets = List<int>.filled(AdminAnalyticsTab._days, 0);
          var total = 0;
          if (s.hasData) {
            for (final d in s.data!.docs) {
              final dt = _toDate(d.data()['date']);
              if (dt == null) continue;
              final day = DateTime(dt.year, dt.month, dt.day).difference(start).inDays;
              if (day >= 0 && day < AdminAnalyticsTab._days) buckets[day]++;
            }
            total = buckets.fold(0, (a, b) => a + b);
          }
          return _ChartCard(
            title: 'Transactions recorded',
            subtitle: '$total in the last ${AdminAnalyticsTab._days} days',
            child: s.hasData
                ? _BarChart(buckets: buckets, start: start)
                : const Center(child: CircularProgressIndicator()),
          );
        },
      );
}

class _FeedbackPie extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
        builder: (_, s) {
          final counts = <String, int>{};
          if (s.hasData) {
            for (final d in s.data!.docs) {
              final type = '${d.data()['type'] ?? 'other'}';
              counts[type] = (counts[type] ?? 0) + 1;
            }
          }
          return _ChartCard(
            title: 'Feedback by type',
            subtitle: '${counts.values.fold(0, (a, b) => a + b)} total',
            child: s.hasData
                ? _Pie(sections: counts)
                : const Center(child: CircularProgressIndicator()),
          );
        },
      );
}

class _SupportPie extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('supportQueries').snapshots(),
        builder: (_, s) {
          final counts = <String, int>{};
          if (s.hasData) {
            for (final d in s.data!.docs) {
              final status = '${d.data()['status'] ?? 'open'}';
              counts[status] = (counts[status] ?? 0) + 1;
            }
          }
          return _ChartCard(
            title: 'Support queries by status',
            subtitle: '${counts.values.fold(0, (a, b) => a + b)} total',
            child: s.hasData
                ? _Pie(sections: counts)
                : const Center(child: CircularProgressIndicator()),
          );
        },
      );
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.buckets, required this.start, required this.color});
  final List<int> buckets;
  final DateTime start;
  final Color color;

  @override
  Widget build(BuildContext context) => LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (v, m) => _dayLabel(v, start),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < buckets.length; i++) FlSpot(i.toDouble(), buckets[i].toDouble())],
              isCurved: true,
              color: color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
            ),
          ],
        ),
      );
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.buckets, required this.start});
  final List<int> buckets;
  final DateTime start;

  @override
  Widget build(BuildContext context) => BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (v, m) => _dayLabel(v, start),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < buckets.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: buckets[i].toDouble(),
                    color: PennyPalColors.white,
                    width: 10,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ],
              ),
          ],
        ),
      );
}

class _Pie extends StatelessWidget {
  const _Pie({required this.sections});
  final Map<String, int> sections;

  static const _palette = [
    PennyPalColors.success,
    PennyPalColors.danger,
    PennyPalColors.lightGray,
    PennyPalColors.muted,
    PennyPalColors.white,
  ];

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Center(child: Text('No data yet.', style: TextStyle(color: PennyPalColors.gray)));
    }
    final entries = sections.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 42,
              sectionsSpace: 2,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value.toDouble(),
                    title: '${entries[i].value}',
                    color: _palette[i % _palette.length],
                    radius: 52,
                    titleStyle: const TextStyle(color: PennyPalColors.black, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (var i = 0; i < entries.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: _palette[i % _palette.length], shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text('${entries[i].key} (${entries[i].value})', style: const TextStyle(color: PennyPalColors.gray, fontSize: 11.5)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

Widget _dayLabel(double value, DateTime start) {
  if (value < 0 || value >= AdminAnalyticsTab._days || value % 1 != 0) {
    return const SizedBox.shrink();
  }
  final d = start.add(Duration(days: value.toInt()));
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text('${d.day}', style: const TextStyle(color: PennyPalColors.muted, fontSize: 10)),
  );
}

DateTime? _toDate(dynamic v) => switch (v) {
      Timestamp t => t.toDate(),
      DateTime t => t,
      _ => null,
    };
