import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';
import '../../../../shared/widgets/penny_widgets.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});
  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final _search = TextEditingController();
  int _topicIndex = 0;

  static const _topics = [
    ('💰', 'All'),
    ('🏦', 'Saving'),
    ('📊', 'Budgeting'),
    ('💼', 'Income'),
    ('🍔', 'Expenses'),
    ('🎯', 'Goals'),
  ];

  static const _articles = [
    _Article('Budgeting 101',
        'Learn the basics of managing your money with a budget.', '📊',
        '5 min read'),
    _Article('Why Saving Matters',
        'Small savings today lead to big rewards tomorrow.', '💰', '4 min read'),
    _Article('Needs vs Wants',
        'Understand the difference to spend smarter.', '🛒', '3 min read'),
    _Article('Understanding Income',
        'All the ways you can earn and track your money.', '💼', '6 min read'),
    _Article('Setting Financial Goals',
        'How to define goals and make a plan to reach them.', '🎯',
        '5 min read'),
    _Article('Cutting Unnecessary Expenses',
        'Find where your money leaks and plug them.', '🍔', '4 min read'),
  ];

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
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Learn',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Learn how to make your money work for you.',
                      style:
                          TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),

                    // ── Search ───────────────────────────────────
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search topics…',
                        hintStyle:
                            const TextStyle(color: AppColors.muted),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.muted, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Featured ─────────────────────────────────
                    const SectionHeader(title: 'Featured'),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.push('/learn/budgeting-101'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: const Border.fromBorderSide(
                              BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18)),
                              child: const LottiePlaceholder(
                                height: 160,
                                label: 'onboarding_2.json',
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Budgeting 101',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                      )),
                                  SizedBox(height: 4),
                                  Text(
                                    'Learn the basics of managing your\nmoney with a clear and simple budget.',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.muted,
                                        height: 1.4),
                                  ),
                                  SizedBox(height: 8),
                                  Row(children: [
                                    Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: AppColors.muted),
                                    SizedBox(width: 4),
                                    Text('5 min read',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.muted)),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Topic filter ─────────────────────────────
                    const SectionHeader(title: 'Topics'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Topic chips ─────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _topics.length,
                  itemBuilder: (_, i) {
                    final t = _topics[i];
                    final sel = _topicIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _topicIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: sel
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.$1,
                                style:
                                    const TextStyle(fontSize: 14)),
                            const SizedBox(width: 5),
                            Text(
                              t.$2,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    sel ? Colors.white : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Article list ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final a = _articles[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () =>
                            context.push('/learn/budgeting-101'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: const Border.fromBorderSide(
                                BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(a.emoji,
                                      style: const TextStyle(
                                          fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(a.title,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text)),
                                    const SizedBox(height: 3),
                                    Text(a.subtitle,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.muted),
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow.ellipsis),
                                    const SizedBox(height: 5),
                                    Row(children: [
                                      const Icon(
                                          Icons.access_time_rounded,
                                          size: 11,
                                          color: AppColors.muted),
                                      const SizedBox(width: 3),
                                      Text(a.readTime,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.muted)),
                                    ]),
                                  ],
                                ),
                              ),
                              const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.muted),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _articles.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Article {
  const _Article(this.title, this.subtitle, this.emoji, this.readTime);
  final String title;
  final String subtitle;
  final String emoji;
  final String readTime;
}
