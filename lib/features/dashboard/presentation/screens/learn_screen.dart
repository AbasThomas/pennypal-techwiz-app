import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
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
    (AppIcons.book, 'All'),
    (AppIcons.piggyBank, 'Saving'),
    (AppIcons.chart, 'Budgeting'),
    (AppIcons.salary, 'Income'),
    (AppIcons.wallet, 'Expenses'),
    (AppIcons.target, 'Goals'),
  ];

  static const _articles = [
    _Article('Budgeting 101',
        'Learn the basics of managing your money with a budget.', AppIcons.chart,
        '5 min read'),
    _Article('Why Saving Matters',
        'Small savings today lead to big rewards tomorrow.', AppIcons.piggyBank, '4 min read'),
    _Article('Needs vs Wants',
        'Understand the difference to spend smarter.', AppIcons.shoppingBag, '3 min read'),
    _Article('Understanding Income',
        'All the ways you can earn and track your money.', AppIcons.salary, '6 min read'),
    _Article('Setting Financial Goals',
        'How to define goals and make a plan to reach them.', AppIcons.target,
        '5 min read'),
    _Article('Cutting Unnecessary Expenses',
        'Find where your money leaks and plug them.', AppIcons.wallet, '4 min read'),
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
            // Header
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

                    // Search
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: PennyPalColors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search topics…',
                        hintStyle:
                            const TextStyle(color: PennyPalColors.muted),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: AppIcon(AppIcons.search,
                              color: PennyPalColors.muted, size: 20),
                        ),
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

                    // Featured
                    const SectionHeader(title: 'Featured'),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/learn/budgeting-101');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: PennyPalColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: PennyPalColors.border),
                        ),
                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(18)),
                              child: LottiePlaceholder(
                                height: 160,
                                label: 'onboarding_2.json',
                              ),
                            ),
                            Padding(
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
                                    AppIcon(
                                        AppIcons.book,
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

                    // Topic filter
                    const SectionHeader(title: 'Topics'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Topic chips
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
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _topicIndex = i);
                      },
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
                            AppIcon(
                              t.$1,
                              size: 14,
                              color: sel ? PennyPalColors.black : PennyPalColors.gray,
                            ),
                            const SizedBox(width: 6),
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

            // Article list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final a = _articles[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _InteractiveArticleCard(article: a),
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
  const _Article(this.title, this.subtitle, this.icon, this.readTime);
  final String title;
  final String subtitle;
  final List<List<dynamic>> icon;
  final String readTime;
}

class _InteractiveArticleCard extends StatefulWidget {
  const _InteractiveArticleCard({required this.article});
  final _Article article;

  @override
  State<_InteractiveArticleCard> createState() => _InteractiveArticleCardState();
}

class _InteractiveArticleCardState extends State<_InteractiveArticleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        context.push('/learn/budgeting-101');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: Center(
                  child: AppIcon(widget.article.icon, size: 22, color: PennyPalColors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.article.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PennyPalColors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.article.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: PennyPalColors.gray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const AppIcon(
                          AppIcons.book,
                          size: 11,
                          color: PennyPalColors.gray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.article.readTime,
                          style: const TextStyle(
                            fontSize: 11,
                            color: PennyPalColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const AppIcon(
                AppIcons.chevronRight,
                color: PennyPalColors.muted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
