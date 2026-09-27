import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
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
  final _scroll = ScrollController();
  final List<_Message> _messages = [];
  final List<GroqChatMessage> _history = [];
  bool _isTyping = false;
  bool _failed = false;

  static const _suggestions = [
    'How can I save more?',
    'Help me create a budget',
    'Where am I spending most?',
    'How much should I save?',
  ];

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
      'relevant. You provide educational guidance, not professional financial '
      'advice; add a brief disclaimer when giving investing or debt advice.\n',
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
      final message =
          e is AppException ? e.message : 'Something went wrong. Please try again.';
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
            const AppIcon(AppIcons.warning,
                color: PennyPalColors.white, size: 20),
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
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: PennyPalColors.elevated,
              child: AppIcon(AppIcons.robot,
                  color: PennyPalColors.white, size: 18),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PennyPal AI',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PennyPalColors.white)),
                Text('Financial learning assistant',
                    style:
                        TextStyle(fontSize: 11, color: PennyPalColors.gray)),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _EmptyChat(
                    suggestions: _suggestions,
                    onSuggestion: _send,
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

          // Disclaimer
          Container(
            color: PennyPalColors.nearBlack,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(AppIcons.warning, size: 12, color: PennyPalColors.muted),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Educational guidance only — not professional financial advice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: PennyPalColors.muted),
                  ),
                ),
              ],
            ),
          ),

          // Input bar
          Container(
            color: PennyPalColors.nearBlack,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    style: const TextStyle(color: PennyPalColors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything…',
                      hintStyle:
                          const TextStyle(color: PennyPalColors.muted),
                      filled: true,
                      fillColor: PennyPalColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(
                            color: PennyPalColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(
                            color: PennyPalColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(
                            color: PennyPalColors.white, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isTyping ? null : () => _send(_controller.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: PennyPalColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: _isTyping
                        ? const Padding(
                            padding: EdgeInsets.all(11),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: PennyPalColors.black,
                            ),
                          )
                        : const AppIcon(AppIcons.arrowForward,
                            color: PennyPalColors.black, size: 20),
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

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({
    required this.suggestions,
    required this.onSuggestion,
  });
  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        children: [
          Lottie.asset(
            'assets/animations/ai.json',
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          const Text(
            'How can I help you today?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: PennyPalColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'I can help you understand your finances\nand build better money habits.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: PennyPalColors.gray),
          ),
          const SizedBox(height: 28),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onSuggestion(s),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: PennyPalColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PennyPalColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(s,
                              style: const TextStyle(
                                  fontSize: 14, color: PennyPalColors.white))),
                      const AppIcon(AppIcons.arrowForward,
                          size: 16, color: PennyPalColors.gray),
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
            child:
                AppIcon(AppIcons.robot, size: 14, color: PennyPalColors.white),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: message.isUser
                  ? PennyPalColors.white
                  : PennyPalColors.card,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    Radius.circular(message.isUser ? 16 : 4),
                bottomRight:
                    Radius.circular(message.isUser ? 4 : 16),
              ),
              border: message.isUser
                  ? null
                  : Border.all(color: PennyPalColors.border),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: message.isUser ? PennyPalColors.black : PennyPalColors.white,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
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
                          color: PennyPalColors.gray.withValues(alpha: 0.4 + 0.6 * bounce),
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
          AppIcon(AppIcons.warning,
              size: 14, color: PennyPalColors.danger),
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
