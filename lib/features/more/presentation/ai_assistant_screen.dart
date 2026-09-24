import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});
  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Message> _messages = [];

  static const _suggestions = [
    'How can I save more?',
    'Help me create a budget',
    'Where am I spending most?',
    'How much should I save?',
  ];

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      // Simulated AI reply
      _messages.add(const _Message(
        text:
            "Based on your recent spending, here are some practical tips to help you with that. I'd recommend reviewing your biggest expense categories first, then setting a specific target. Remember, I provide educational guidance â€” not professional financial advice.",
        isUser: false,
      ));
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
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
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) =>
                        _ChatBubble(message: _messages[i]),
                  ),
          ),

          // â”€â”€ Disclaimer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            color: PennyPalColors.nearBlack,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(AppIcons.warning, size: 12, color: PennyPalColors.muted),
                SizedBox(width: 6),
                Text(
                  'Educational guidance only — not professional financial advice.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: PennyPalColors.muted),
                ),
              ],
            ),
          ),

          // â”€â”€ Input bar (Section 13) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
                      hintText: 'Ask me anythingâ€¦',
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
                  onTap: () => _send(_controller.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: PennyPalColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const AppIcon(AppIcons.arrowForward,
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
          const LottiePlaceholder(
              height: 180, label: 'ai_assistant.json'),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
      ),
    );
  }
}
