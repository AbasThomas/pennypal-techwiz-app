import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/learning_materials.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  static const _categories = [
    'All Materials',
    'Budgeting',
    'Savings & Emergency',
    'Income & Wealth',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final filteredBooks = LearningRepository.curatedBooks.where((book) {
      final matchesQuery = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.subtitle.toLowerCase().contains(query) ||
          book.summary.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_selectedCategoryIndex == 0) return true;
      if (_selectedCategoryIndex == 1) {
        return book.category.toLowerCase().contains('budget');
      }
      if (_selectedCategoryIndex == 2) {
        return book.category.toLowerCase().contains('saving') ||
            book.category.toLowerCase().contains('defense');
      }
      if (_selectedCategoryIndex == 3) {
        return book.category.toLowerCase().contains('income') ||
            book.category.toLowerCase().contains('growth') ||
            book.category.toLowerCase().contains('wealth');
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: PennyPalColors.elevated,
              child: AppIcon(
                AppIcons.book,
                size: 18,
                color: PennyPalColors.white,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Academy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: PennyPalColors.white,
                  ),
                ),
                Text(
                  'Curated student playbooks & guides',
                  style: TextStyle(fontSize: 11, color: PennyPalColors.gray),
                ),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Search Bar
            Container(
              decoration: BoxDecoration(
                color: PennyPalColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: PennyPalColors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search financial books, topics, or lessons…',
                  hintStyle: const TextStyle(
                    color: PennyPalColors.muted,
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: AppIcon(
                      AppIcons.search,
                      size: 18,
                      color: PennyPalColors.gray,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const AppIcon(
                            AppIcons.close,
                            size: 16,
                            color: PennyPalColors.muted,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Minimalist Category Filter Pills
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategoryIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? PennyPalColors.white
                            : PennyPalColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? PennyPalColors.white
                              : PennyPalColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? PennyPalColors.black
                                : PennyPalColors.lightGray,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Featured Book Header (when no active query)
            if (query.isEmpty && _selectedCategoryIndex == 0 && filteredBooks.isNotEmpty) ...[
              _FeaturedBookBanner(book: filteredBooks.first),
              const SizedBox(height: 24),
            ],

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Core Curriculum Books',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: PennyPalColors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: PennyPalColors.elevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  child: Text(
                    '${filteredBooks.length} Books',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: PennyPalColors.lightGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List of Books
            if (filteredBooks.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    AppIcon(AppIcons.book, size: 36, color: PennyPalColors.muted),
                    SizedBox(height: 12),
                    Text(
                      'No learning materials match your search.',
                      style: TextStyle(color: PennyPalColors.gray, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredBooks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return _BookCard(book: book);
                },
              ),

            // Firestore Community Lessons (if available)
            const SizedBox(height: 28),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('learningContent')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }

                final docs = snapshot.data!.docs.where((d) {
                  final data = d.data();
                  final title = '${data['title'] ?? ''}'.toLowerCase();
                  final summary = '${data['summary'] ?? ''}'.toLowerCase();
                  return query.isEmpty ||
                      title.contains(query) ||
                      summary.contains(query);
                }).toList();

                if (docs.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Community Articles & Guides',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: PennyPalColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final d = docs[index];
                        final v = d.data();
                        return ListTile(
                          onTap: () => context.push('/learn/${d.id}'),
                          tileColor: PennyPalColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: PennyPalColors.border),
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: PennyPalColors.elevated,
                            child: AppIcon(
                              AppIcons.invoice,
                              size: 18,
                              color: PennyPalColors.white,
                            ),
                          ),
                          title: Text(
                            '${v['title'] ?? 'Untitled lesson'}',
                            style: const TextStyle(
                              color: PennyPalColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '${v['summary'] ?? v['category'] ?? ''}',
                            style: const TextStyle(
                              color: PennyPalColors.gray,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const AppIcon(
                            AppIcons.chevronRight,
                            size: 16,
                            color: PennyPalColors.gray,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedBookBanner extends StatelessWidget {
  const _FeaturedBookBanner({required this.book});
  final LearningBook book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/learn/${book.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PennyPalColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: PennyPalColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        AppIcons.star,
                        size: 11,
                        color: PennyPalColors.black,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'FEATURED PLAYBOOK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: PennyPalColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${book.readTimeMinutes} min read',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: PennyPalColors.lightGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Professional Book Cover with Spine Accent
                _BookSpineThumbnail(
                  icon: book.icon,
                  width: 58,
                  height: 76,
                  iconSize: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: PennyPalColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: PennyPalColors.lightGray,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              book.summary,
              style: const TextStyle(
                fontSize: 12.5,
                color: PennyPalColors.gray,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _InfoBadge(label: '${book.chapterCount} Chapters'),
                const SizedBox(width: 8),
                _InfoBadge(label: book.level),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: PennyPalColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Read Book',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: PennyPalColors.black,
                        ),
                      ),
                      SizedBox(width: 4),
                      AppIcon(
                        AppIcons.arrowForward,
                        size: 13,
                        color: PennyPalColors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});
  final LearningBook book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/learn/${book.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PennyPalColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Minimalist Book Spine Cover
            _BookSpineThumbnail(
              icon: book.icon,
              width: 52,
              height: 68,
              iconSize: 22,
            ),
            const SizedBox(width: 14),

            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: PennyPalColors.elevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: PennyPalColors.mutedBorder),
                        ),
                        child: Text(
                          book.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: PennyPalColors.lightGray,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${book.readTimeMinutes} min',
                        style: const TextStyle(
                          fontSize: 11,
                          color: PennyPalColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: PennyPalColors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: PennyPalColors.gray,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _InfoBadge(label: '${book.chapterCount} Chapters'),
                      const SizedBox(width: 6),
                      _InfoBadge(label: book.level),
                      const Spacer(),
                      const AppIcon(
                        AppIcons.chevronRight,
                        size: 15,
                        color: PennyPalColors.gray,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookSpineThumbnail extends StatelessWidget {
  const _BookSpineThumbnail({
    required this.icon,
    required this.width,
    required this.height,
    required this.iconSize,
  });

  final List<List<dynamic>> icon;
  final double width;
  final double height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: PennyPalColors.elevated,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border.all(color: PennyPalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Hardcover Spine Left Edge
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: Container(
              decoration: BoxDecoration(
                color: PennyPalColors.white.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
            ),
          ),
          Center(
            child: AppIcon(
              icon,
              size: iconSize,
              color: PennyPalColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: PennyPalColors.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: PennyPalColors.mutedBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: PennyPalColors.lightGray,
        ),
      ),
    );
  }
}
