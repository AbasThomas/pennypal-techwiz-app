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
      backgroundColor: PennyPalColors.black,
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
                        color: PennyPalColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Learn how to make your money work for you.',
                      style:
                          TextStyle(fontSize: 14, color: PennyPalColors.gray),
                    ),
                    const SizedBox(height: 16),

                    // ── Search ───────────────────────────────────
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: PennyPalColors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search topics…',
                        hintStyle:
                            const TextStyle(color: PennyPalColors.muted),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: PennyPalColors.muted, size: 20),
                        filled: true,
                        fillColor: PennyPalColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: PennyPalColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: PennyPalColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: PennyPalColors.white, width: 1.5),
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
                          color: PennyPalColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: PennyPalColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(18)),
                              child: LottiePlaceholder(
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
                                        color: PennyPalColors.white,
                                      )),
                                  SizedBox(height: 4),
                                  Text(
                                    'Learn the basics of managing your\nmoney with a clear and simple budget.',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: PennyPalColors.gray,
                                        height: 1.4),
                                  ),
                                  SizedBox(height: 8),
                                  Row(children: [
                                    Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: PennyPalColors.gray),
                                    SizedBox(width: 4),
                                    Text('5 min read',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: PennyPalColors.gray)),
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
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? PennyPalColors.white
                              : PennyPalColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: sel
                                ? PennyPalColors.white
                                : PennyPalColors.border,
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
                                    sel ? PennyPalColors.black : PennyPalColors.gray,
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
                            color: PennyPalColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: PennyPalColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: PennyPalColors.card,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(color: PennyPalColors.border),
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
                                            color: PennyPalColors.white)),
                                    const SizedBox(height: 3),
                                    Text(a.subtitle,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: PennyPalColors.gray),
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow.ellipsis),
                                    const SizedBox(height: 5),
                                    Row(children: [
                                      const Icon(
                                          Icons.access_time_rounded,
                                          size: 11,
                                          color: PennyPalColors.gray),
                                      const SizedBox(width: 3),
                                      Text(a.readTime,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: PennyPalColors.gray)),
                                    ]),
                                  ],
                                ),
                              ),
                              const Icon(
                                  Icons.chevron_right_rounded,
                                  color: PennyPalColors.muted),
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
