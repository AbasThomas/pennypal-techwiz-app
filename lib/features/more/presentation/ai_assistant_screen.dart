import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pennypal/core/widgets/app_icon.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/finance_providers.dart';
import '../data/groq_chat_service.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});
  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scroll = ScrollController();
  final List<_Message> _messages = [];
  final List<GroqChatMessage> _history = [];
  bool _isTyping = false;
  bool _failed = false;
  int _selectedTab = 0;

  static const _categoryTabs = [
    'All',
    '💰 Budget',
    '🎯 Savings',
    '📊 Spending',
    '💡 Tips',
  ];

  static const _categorizedSuggestions = {
    0: [
      'How can I save more as a student?',
      'Help me create a monthly budget',
      'Where am I spending most of my money?',
      'How much should I keep in an emergency fund?',
    ],
    1: [
      'Help me create a 50/30/20 budget',
      'How do I stick to my monthly budget limit?',
      'What is the best way to budget for campus groceries?',
      'How do I budget with irregular pocket money or income?',
    ],
    2: [
      'How do I start saving for tuition fees?',
      'How much should I save from my monthly allowance?',
      'What are some practical savings tips for students?',
      'How can I build an emergency savings fund quickly?',
    ],
    3: [
      'Where am I spending the most money?',
      'How can I cut down on food and takeout expenses?',
      'What are easy ways to track daily micro-expenses?',
      'How do I reduce my impulse spending?',
    ],
    4: [
      'How do I build good financial habits early?',
      'What should every student know about investing?',
      'How do I avoid student debt and peer pressure spending?',
      'What are simple money rules for financial freedom?',
    ],
  };

  static final _currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

  /// Builds a system prompt grounded in the user's real Firestore data so
  /// answers reference actual figures instead of generic advice.
  String _systemPrompt() {
    final transactions = ref.read(transactionsProvider).value ?? [];
    final budgets = ref.read(budgetsProvider).value ?? [];
    final goals = ref.read(savingsGoalsProvider).value ?? [];

    final buffer = StringBuffer(
      'You are PennyPal AI, a friendly financial learning assistant inside the '
      'PennyPal personal finance app for students. Give short, practical, '
      'encouraging answers in plain language. Use Nigerian Naira (₦) for money. '
      'Never invent numbers — only reference the user data below if it is '
      'relevant. Format your answer cleanly with plain text paragraphs, '
      'numbered points, or clean bullet points (-). Do not output raw markdown '
      'asterisks (such as ** or *) in headings, lists, or text. '
      'You provide educational guidance, not professional financial advice; '
      'add a brief disclaimer when giving investing or debt advice.\n',
    );

    if (transactions.isEmpty && budgets.isEmpty && goals.isEmpty) {
      buffer.write(
        '\nThe user has not recorded any transactions, budgets or savings '
        'goals yet. If they ask about their finances, gently suggest they add '
        'their income, expenses and goals in the app first.',
      );
      return buffer.toString();
    }

    buffer.write('\nUser data (from their PennyPal account):');

    if (goals.isNotEmpty) {
      buffer.write('\nSavings goals:');
      for (final g in goals) {
        buffer.write(
          '\n- ${g.goalName}: saved ${_currency.format(g.currentAmount)} '
          'of ${_currency.format(g.targetAmount)} target '
          '(target date ${DateFormat('MMM yyyy').format(g.targetDate)}, '
          'status: ${g.status})',
        );
      }
    }

    if (budgets.isNotEmpty) {
      final budget = budgets.first;
      buffer.write(
        '\nMonthly budget (${budget.month}): '
        '${_currency.format(budget.limitAmount)} total limit.',
      );
    }

    if (transactions.isNotEmpty) {
      final recent = transactions.take(15).toList();
      buffer.write('\nRecent transactions:');
      for (final t in recent) {
        final label = t.description.isNotEmpty ? t.description : t.categoryId;
        buffer.write(
          '\n- ${DateFormat('dd MMM').format(t.date)} '
          '${t.type.name}: $label (${t.categoryId}) '
          '${_currency.format(t.amount)}',
        );
      }
    }
    return buffer.toString();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isTyping) return;
    setState(() {
      _messages.add(_Message(text: trimmed, isUser: true));
      _isTyping = true;
      _failed = false;
    });
    _history.add(GroqChatMessage(role: 'user', content: trimmed));
    _controller.clear();
    _scrollToBottom();
    await _requestReply();
  }

  Future<void> _retry() async {
    if (_isTyping) return;
    setState(() {
      _isTyping = true;
      _failed = false;
    });
    await _requestReply();
  }

  Future<void> _requestReply() async {
    try {
      final reply = await ref.read(groqChatServiceProvider).send([
        GroqChatMessage(role: 'system', content: _systemPrompt()),
        ..._history,
      ]);
      if (!mounted) return;
      setState(() {
        _history.add(GroqChatMessage(role: 'assistant', content: reply));
        _messages.add(_Message(text: reply, isUser: false));
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _failed = true;
      });
      final message = e is AppException
          ? e.message
          : 'Something went wrong. Please try again.';
      _showErrorSnack(message);
    }
    _scrollToBottom();
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PennyPalColors.elevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: PennyPalColors.border),
        ),
        content: Row(
          children: [
            const AppIcon(
              AppIcons.warning,
              color: PennyPalColors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: PennyPalColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final viewInsets = MediaQuery.of(context).viewInsets;
    final padding = MediaQuery.of(context).padding;
    final isKeyboardOpen = viewInsets.bottom > 0;
    final double bottomBarPadding = isKeyboardOpen
        ? viewInsets.bottom + 10.0
        : (canPop
            ? (padding.bottom > 0 ? padding.bottom : 16.0) + 4.0
            : (padding.bottom > 0 ? padding.bottom : 16.0) + 84.0);

    final currentSuggestions =
        _categorizedSuggestions[_selectedTab] ?? _categorizedSuggestions[0]!;

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: canPop,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: PennyPalColors.elevated,
              child: AppIcon(
                AppIcons.robot,
                color: PennyPalColors.white,
                size: 18,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PennyPal AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PennyPalColors.white,
                  ),
                ),
                Text(
                  'Financial learning assistant',
                  style: TextStyle(fontSize: 11, color: PennyPalColors.gray),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              tooltip: 'Clear conversation',
              icon: const AppIcon(
                AppIcons.refresh,
                size: 18,
                color: PennyPalColors.gray,
              ),
              onPressed: () {
                setState(() {
                  _messages.clear();
                  _history.clear();
                  _failed = false;
                });
              },
            ),
        ],
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _EmptyChat(
                    categoryTabs: _categoryTabs,
                    selectedTab: _selectedTab,
                    onSelectTab: (index) => setState(() => _selectedTab = index),
                    suggestions: currentSuggestions,
                    onSuggestion: _send,
                    controller: _controller,
                    onInputSubmitted: _send,
                    focusNode: _focusNode,
                    isInsideShell: !canPop,
                  )
                : ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      ..._messages.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ChatBubble(message: m),
                        ),
                      ),
                      if (_isTyping)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: _TypingBubble(),
                        ),
                      if (_failed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RetryPrompt(onRetry: _retry),
                        ),
                    ],
                  ),
          ),

          // Follow-up suggestion pills when messages are present in active chat
          if (_messages.isNotEmpty && !_isTyping)
            Container(
              height: 38,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  _QuickChip(
                    label: 'Tell me more',
                    onTap: () => _send('Can you explain that in more detail with practical student examples?'),
                  ),
                  _QuickChip(
                    label: 'Give an example',
                    onTap: () => _send('Could you give a concrete budget or savings calculation for this?'),
                  ),
                  _QuickChip(
                    label: 'How do I start?',
                    onTap: () => _send('What are the first three action steps I should take today?'),
                  ),
                  _QuickChip(
                    label: 'Create a plan',
                    onTap: () => _send('Help me build a step-by-step plan for my financial goals.'),
                  ),
                ],
              ),
            ),

          // Single bottom typing bar (only visible during ongoing chat conversation)
          if (_messages.isNotEmpty)
            Container(
              color: PennyPalColors.nearBlack,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: bottomBarPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: PennyPalColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: PennyPalColors.border),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const AppIcon(
                            AppIcons.robot,
                            color: PennyPalColors.muted,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              textInputAction: TextInputAction.send,
                              onSubmitted: _send,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                color: PennyPalColors.white,
                                fontSize: 14,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Ask PennyPal AI anything…',
                                hintStyle: TextStyle(
                                  color: PennyPalColors.muted,
                                  fontSize: 14,
                                ),
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                setState(() {});
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: AppIcon(
                                  AppIcons.close,
                                  color: PennyPalColors.muted,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _isTyping ? null : () => _send(_controller.text),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _controller.text.trim().isNotEmpty
                            ? PennyPalColors.white
                            : PennyPalColors.elevated,
                        shape: BoxShape.circle,
                      ),
                      child: _isTyping
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: PennyPalColors.black,
                              ),
                            )
                          : AppIcon(
                              AppIcons.arrowForward,
                              color: _controller.text.trim().isNotEmpty
                                  ? PennyPalColors.black
                                  : PennyPalColors.gray,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: PennyPalColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: PennyPalColors.border),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: PennyPalColors.lightGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyChat extends StatefulWidget {
  const _EmptyChat({
    required this.categoryTabs,
    required this.selectedTab,
    required this.onSelectTab,
    required this.suggestions,
    required this.onSuggestion,
    required this.controller,
    required this.onInputSubmitted,
    required this.focusNode,
    required this.isInsideShell,
  });

  final List<String> categoryTabs;
  final int selectedTab;
  final ValueChanged<int> onSelectTab;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;
  final TextEditingController controller;
  final ValueChanged<String> onInputSubmitted;
  final FocusNode focusNode;
  final bool isInsideShell;

  @override
  State<_EmptyChat> createState() => _EmptyChatState();
}

class _EmptyChatState extends State<_EmptyChat> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        widget.isInsideShell ? 100 : 32,
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Lottie.asset(
            'assets/animations/ai.json',
            height: 280,
            width: 280,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 4),
          const Text(
            'How can I help you today?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: PennyPalColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'PennyPal AI gives you clear, student-friendly\nadvice on budgets, savings, and spending.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: PennyPalColors.gray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Single Interactive Input Tab / Typing Box on the AI page
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PennyPalColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PennyPalColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: PennyPalColors.elevated,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Center(
                        child: AppIcon(
                          AppIcons.bulb,
                          size: 15,
                          color: PennyPalColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Start a conversation',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: PennyPalColors.lightGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: PennyPalColors.nearBlack,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: PennyPalColors.mutedBorder),
                  ),
                  child: Row(
                    children: [
                      const AppIcon(
                        AppIcons.robot,
                        size: 18,
                        color: PennyPalColors.muted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          textInputAction: TextInputAction.send,
                          onSubmitted: widget.onInputSubmitted,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            color: PennyPalColors.white,
                            fontSize: 14.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Type your question here…',
                            hintStyle: TextStyle(
                              color: PennyPalColors.muted,
                              fontSize: 14,
                            ),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      if (widget.controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            widget.controller.clear();
                            setState(() {});
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: AppIcon(
                              AppIcons.close,
                              color: PennyPalColors.muted,
                              size: 16,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () => widget.onInputSubmitted(widget.controller.text),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: widget.controller.text.trim().isNotEmpty
                                ? PennyPalColors.white
                                : PennyPalColors.elevated,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AppIcon(
                              AppIcons.arrowForward,
                              size: 17,
                              color: widget.controller.text.trim().isNotEmpty
                                  ? PennyPalColors.black
                                  : PennyPalColors.gray,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Category Filter Tabs
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.categoryTabs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == widget.selectedTab;
                return GestureDetector(
                  onTap: () => widget.onSelectTab(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? PennyPalColors.white : PennyPalColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? PennyPalColors.white : PennyPalColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.categoryTabs[index],
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? PennyPalColors.black : PennyPalColors.lightGray,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Suggested Prompts
          ...widget.suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: GestureDetector(
                onTap: () => widget.onSuggestion(s),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: PennyPalColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: PennyPalColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const AppIcon(
                        AppIcons.arrowForward,
                        size: 15,
                        color: PennyPalColors.gray,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  const _Message({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final _Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: message.isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!message.isUser) ...[
          const CircleAvatar(
            radius: 14,
            backgroundColor: PennyPalColors.elevated,
            child: AppIcon(
              AppIcons.robot,
              size: 14,
              color: PennyPalColors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: message.isUser
                  ? PennyPalColors.white
                  : PennyPalColors.card,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                bottomRight: Radius.circular(message.isUser ? 4 : 16),
              ),
              border: message.isUser
                  ? null
                  : Border.all(color: PennyPalColors.border),
            ),
            child: _FormattedMessageBody(
              text: message.text,
              isUser: message.isUser,
            ),
          ),
        ),
      ],
    );
  }
}

/// Rich markdown and clean text renderer that removes all raw asterisks
/// and displays bold, italics, bullets, headers, and lists cleanly.
class _FormattedMessageBody extends StatelessWidget {
  const _FormattedMessageBody({required this.text, required this.isUser});
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: PennyPalColors.black,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trimRight();
      if (line.trim().isEmpty) {
        if (i > 0 && i < lines.length - 1 && lines[i - 1].trim().isNotEmpty) {
          widgets.add(const SizedBox(height: 8));
        }
        continue;
      }

      final trimmed = line.trim();

      // Heading 1, 2, or 3 (e.g. ### Title or ## Title or # Title)
      if (trimmed.startsWith(RegExp(r'^#{1,3}\s+'))) {
        final headingText = trimmed.replaceFirst(RegExp(r'^#{1,3}\s+'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Text.rich(
              TextSpan(
                children: _parseInlineSpans(
                  headingText,
                  textColor: PennyPalColors.white,
                  isHeading: true,
                ),
              ),
            ),
          ),
        );
        continue;
      }

      // Bullet items (starts with * , - , + , or • )
      final bulletMatch = RegExp(r'^(\*|-|\+|•)\s+(.*)$').firstMatch(trimmed);
      if (bulletMatch != null) {
        final itemContent = bulletMatch.group(2) ?? '';
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: PennyPalColors.lightGray,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _parseInlineSpans(
                        itemContent,
                        textColor: PennyPalColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Numbered items (e.g. 1. Item or 1) Item)
      final numMatch = RegExp(r'^(\d+[\.\)])\s+(.*)$').firstMatch(trimmed);
      if (numMatch != null) {
        final numPrefix = numMatch.group(1) ?? '';
        final itemContent = numMatch.group(2) ?? '';
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    numPrefix,
                    style: const TextStyle(
                      color: PennyPalColors.lightGray,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _parseInlineSpans(
                        itemContent,
                        textColor: PennyPalColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Standard paragraph line
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text.rich(
            TextSpan(
              children: _parseInlineSpans(
                line,
                textColor: PennyPalColors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets.isEmpty
          ? [
              Text(
                text.replaceAll('*', ''),
                style: const TextStyle(
                  fontSize: 14,
                  color: PennyPalColors.white,
                  height: 1.45,
                ),
              ),
            ]
          : widgets,
    );
  }

  static List<InlineSpan> _parseInlineSpans(
    String raw, {
    Color textColor = PennyPalColors.white,
    bool isHeading = false,
  }) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(
      r'(\*\*\*(.*?)\*\*\*|___(.*?)___|\*\*(.*?)\*\*|__(.*?)__|\*(.*?)\*|_(.*?)_|`([^`]+)`)',
      dotAll: true,
    );

    int lastIndex = 0;
    for (final match in pattern.allMatches(raw)) {
      if (match.start > lastIndex) {
        final normalText = raw
            .substring(lastIndex, match.start)
            .replaceAll('*', '');
        if (normalText.isNotEmpty) {
          spans.add(
            TextSpan(
              text: normalText,
              style: TextStyle(
                color: textColor,
                fontSize: isHeading ? 15.5 : 14,
                fontWeight: isHeading ? FontWeight.w700 : FontWeight.w400,
                height: 1.45,
              ),
            ),
          );
        }
      }

      final fullMatch = match.group(0)!;
      if (fullMatch.startsWith('***') || fullMatch.startsWith('___')) {
        final content = (match.group(2) ?? match.group(3) ?? '').replaceAll('*', '');
        spans.add(
          TextSpan(
            text: content,
            style: TextStyle(
              color: textColor,
              fontSize: isHeading ? 15.5 : 14,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              height: 1.45,
            ),
          ),
        );
      } else if (fullMatch.startsWith('**') || fullMatch.startsWith('__')) {
        final content = (match.group(4) ?? match.group(5) ?? '').replaceAll('*', '');
        spans.add(
          TextSpan(
            text: content,
            style: TextStyle(
              color: PennyPalColors.white,
              fontSize: isHeading ? 15.5 : 14,
              fontWeight: FontWeight.w800,
              height: 1.45,
            ),
          ),
        );
      } else if (fullMatch.startsWith('*') || fullMatch.startsWith('_')) {
        final content = (match.group(6) ?? match.group(7) ?? '').replaceAll('*', '');
        spans.add(
          TextSpan(
            text: content,
            style: TextStyle(
              color: textColor,
              fontSize: isHeading ? 15.5 : 14,
              fontStyle: FontStyle.italic,
              fontWeight: isHeading ? FontWeight.w700 : FontWeight.w400,
              height: 1.45,
            ),
          ),
        );
      } else if (fullMatch.startsWith('`')) {
        final code = match.group(8) ?? '';
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: PennyPalColors.elevated,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontFamily: 'monospace',
                  color: PennyPalColors.lightGray,
                ),
              ),
            ),
          ),
        );
      }
      lastIndex = match.end;
    }

    if (lastIndex < raw.length) {
      final remaining = raw.substring(lastIndex).replaceAll('*', '');
      if (remaining.isNotEmpty) {
        spans.add(
          TextSpan(
            text: remaining,
            style: TextStyle(
              color: textColor,
              fontSize: isHeading ? 15.5 : 14,
              fontWeight: isHeading ? FontWeight.w700 : FontWeight.w400,
              height: 1.45,
            ),
          ),
        );
      }
    }

    if (spans.isEmpty) {
      spans.add(
        TextSpan(
          text: raw.replaceAll('*', ''),
          style: TextStyle(
            color: textColor,
            fontSize: isHeading ? 15.5 : 14,
            fontWeight: isHeading ? FontWeight.w700 : FontWeight.w400,
            height: 1.45,
          ),
        ),
      );
    }

    return spans;
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundColor: PennyPalColors.elevated,
          child: AppIcon(AppIcons.robot, size: 14, color: PennyPalColors.white),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: PennyPalColors.card,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: PennyPalColors.border),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final offset = (i * 0.25) % 1.0;
                  final t = (_controller.value + offset) % 1.0;
                  final bounce = -4 * t * t + 4 * t;
                  return Container(
                    margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
                    child: Transform.translate(
                      offset: Offset(0, -4 * bounce),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: PennyPalColors.gray.withValues(
                            alpha: 0.4 + 0.6 * bounce,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RetryPrompt extends StatelessWidget {
  const _RetryPrompt({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(AppIcons.warning, size: 14, color: PennyPalColors.danger),
          SizedBox(width: 6),
          Text(
            "Couldn't get a response. Tap to retry.",
            style: TextStyle(
              fontSize: 13,
              color: PennyPalColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
