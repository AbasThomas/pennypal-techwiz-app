import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pennypal/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/learning_materials.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({super.key, this.slug});
  final String? slug;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  int _activeChapterIndex = 0;
  final _scrollController = ScrollController();
  final Set<int> _completedChapters = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToChapter(int index) {
    HapticFeedback.selectionClick();
    setState(() => _activeChapterIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final slug = widget.slug;
    if (slug == null) {
      return const Scaffold(
        backgroundColor: PennyPalColors.black,
        body: Center(
          child: Text(
            'Material not found',
            style: TextStyle(color: PennyPalColors.white),
          ),
        ),
      );
    }

    final book = LearningRepository.getBookById(slug);
    if (book != null) {
      return _buildBookReader(context, book);
    }

    return _buildFirestoreArticle(context, slug);
  }

  Widget _buildBookReader(BuildContext context, LearningBook book) {
    final currentChapter = book.chapters[_activeChapterIndex];
    final hasNext = _activeChapterIndex < book.chapters.length - 1;
    final hasPrev = _activeChapterIndex > 0;
    final isCompleted = _completedChapters.contains(_activeChapterIndex);

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          book.title,
          style: const TextStyle(
            color: PennyPalColors.white,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Table of Contents',
            icon: const AppIcon(
              AppIcons.menu,
              size: 20,
              color: PennyPalColors.white,
            ),
            onPressed: () => _showChapterSheet(context, book),
          ),
        ],
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: Column(
        children: [
          // Reading Progress Line
          LinearProgressIndicator(
            value: (_completedChapters.length) / book.chapters.length,
            backgroundColor: PennyPalColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(PennyPalColors.white),
            minHeight: 2.0,
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Overview Header with HugeIcon Spine
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PennyPalColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: PennyPalColors.border),
                    ),
                    child: Row(
                      children: [
                        // Hardcover Spine Thumbnail
                        Container(
                          width: 44,
                          height: 56,
                          decoration: BoxDecoration(
                            color: PennyPalColors.elevated,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(3),
                              bottomLeft: Radius.circular(3),
                              topRight: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                            border: Border.all(color: PennyPalColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(1.5, 2.5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: PennyPalColors.white
                                        .withValues(alpha: 0.15),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: AppIcon(
                                  book.icon,
                                  size: 20,
                                  color: PennyPalColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: PennyPalColors.gray,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                book.subtitle,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: PennyPalColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chapter Navigation Pills
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: book.chapters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isActive = index == _activeChapterIndex;
                        final isDone = _completedChapters.contains(index);
                        return GestureDetector(
                          onTap: () => _goToChapter(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? PennyPalColors.white
                                  : PennyPalColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive
                                    ? PennyPalColors.white
                                    : PennyPalColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isDone) ...[
                                  AppIcon(
                                    AppIcons.check,
                                    size: 12,
                                    color: isActive
                                        ? PennyPalColors.black
                                        : PennyPalColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  'Ch. ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isActive
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isActive
                                        ? PennyPalColors.black
                                        : PennyPalColors.lightGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Chapter Title & Number
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: PennyPalColors.elevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: PennyPalColors.border),
                        ),
                        child: Text(
                          'CHAPTER ${currentChapter.number}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: PennyPalColors.lightGray,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        currentChapter.readTime,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: PennyPalColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentChapter.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: PennyPalColors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentChapter.summary,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: PennyPalColors.gray,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: PennyPalColors.mutedBorder),
                  const SizedBox(height: 18),

                  // Chapter Content Body
                  ...currentChapter.content.trim().split('\n\n').map(
                        (paragraph) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            paragraph.trim(),
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: PennyPalColors.offWhite,
                              height: 1.65,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),

                  const SizedBox(height: 14),

                  // Key Actionable Takeaways Card
                  if (currentChapter.takeaways.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PennyPalColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: PennyPalColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              AppIcon(
                                AppIcons.bulb,
                                size: 16,
                                color: PennyPalColors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Key Action Takeaways',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: PennyPalColors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...currentChapter.takeaways.map(
                            (takeaway) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    child: const AppIcon(
                                      AppIcons.check,
                                      size: 14,
                                      color: PennyPalColors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      takeaway,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: PennyPalColors.lightGray,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Mark Chapter as Completed Action
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        if (isCompleted) {
                          _completedChapters.remove(_activeChapterIndex);
                        } else {
                          _completedChapters.add(_activeChapterIndex);
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? PennyPalColors.surface
                            : PennyPalColors.elevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCompleted
                              ? PennyPalColors.white
                              : PennyPalColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIcon(
                            isCompleted ? AppIcons.check : AppIcons.star,
                            size: 15,
                            color: PennyPalColors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCompleted
                                ? 'Chapter Completed ✓'
                                : 'Mark Chapter as Completed',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: PennyPalColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Previous / Next Chapter Buttons
                  Row(
                    children: [
                      if (hasPrev)
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: PennyPalColors.surface,
                              side: const BorderSide(
                                  color: PennyPalColors.border),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 11),
                            ),
                            icon: const AppIcon(
                              AppIcons.arrowBack,
                              size: 15,
                              color: PennyPalColors.white,
                            ),
                            label: const Text(
                              'Previous',
                              style: TextStyle(
                                color: PennyPalColors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () =>
                                _goToChapter(_activeChapterIndex - 1),
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 12),
                      if (hasNext)
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PennyPalColors.white,
                              foregroundColor: PennyPalColors.black,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 11),
                            ),
                            label: const Text(
                              'Next Chapter',
                              style: TextStyle(
                                color: PennyPalColors.black,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            icon: const AppIcon(
                              AppIcons.arrowForward,
                              size: 15,
                              color: PennyPalColors.black,
                            ),
                            onPressed: () =>
                                _goToChapter(_activeChapterIndex + 1),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PennyPalColors.white,
                              foregroundColor: PennyPalColors.black,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 11),
                            ),
                            label: const Text(
                              'Finish Book',
                              style: TextStyle(
                                color: PennyPalColors.black,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            icon: const AppIcon(
                              AppIcons.check,
                              size: 15,
                              color: PennyPalColors.black,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: PennyPalColors.surface,
                                  content: const Text(
                                    '🎉 Congratulations on completing this financial book!',
                                    style: TextStyle(
                                      color: PennyPalColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                        color: PennyPalColors.border),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChapterSheet(BuildContext context, LearningBook book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: PennyPalColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PennyPalColors.muted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Table of Contents',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: PennyPalColors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: book.chapters.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: PennyPalColors.mutedBorder),
                    itemBuilder: (context, index) {
                      final ch = book.chapters[index];
                      final isCurrent = index == _activeChapterIndex;
                      final isDone = _completedChapters.contains(index);
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          _goToChapter(index);
                        },
                        leading: CircleAvatar(
                          radius: 13,
                          backgroundColor: isCurrent
                              ? PennyPalColors.white
                              : PennyPalColors.elevated,
                          child: Text(
                            ch.number,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isCurrent
                                  ? PennyPalColors.black
                                  : PennyPalColors.lightGray,
                            ),
                          ),
                        ),
                        title: Text(
                          ch.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isCurrent
                                ? PennyPalColors.white
                                : PennyPalColors.lightGray,
                          ),
                        ),
                        trailing: isDone
                            ? const AppIcon(
                                AppIcons.check,
                                size: 15,
                                color: PennyPalColors.success,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFirestoreArticle(BuildContext context, String slug) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        title: const Text(
          'Lesson',
          style: TextStyle(color: PennyPalColors.white),
        ),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('learningContent')
            .doc(slug)
            .snapshots(),
        builder: (_, s) {
          if (s.hasError) {
            return Center(
              child: Text(
                '${s.error}',
                style: const TextStyle(color: PennyPalColors.white),
              ),
            );
          }
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = s.data!.data();
          if (d == null) {
            return const Center(
              child: Text(
                'This lesson is unavailable.',
                style: TextStyle(color: PennyPalColors.gray),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${d['title'] ?? ''}',
                  style: const TextStyle(
                    color: PennyPalColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${d['category'] ?? ''}',
                  style: const TextStyle(color: PennyPalColors.gray),
                ),
                const SizedBox(height: 24),
                Text(
                  '${d['content'] ?? d['summary'] ?? ''}',
                  style: const TextStyle(
                    color: PennyPalColors.white,
                    fontSize: 14.5,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
