import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pennypal/core/widgets/app_icon.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/finance_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../auth/providers/auth_providers.dart';

const _topics = <String>[
  'Account & password',
  'Transactions',
  'Budgets & goals',
  'Notifications',
  'AI Assistant',
  'Something else',
];

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  String _topic = _topics.first;
  bool _sent = false;
  bool _sending = false;

  Future<void> _send() async {
    if (_subject.text.trim().isEmpty || _message.text.trim().length < 5) {
      AppSnackbar.error(
        context,
        'Add a subject and a short description of the issue.',
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) {
      AppSnackbar.error(context, 'Sign in again to contact support.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      await ref.read(financeRepositoryProvider).submitSupport(user.id, {
        'subject': _subject.text.trim(),
        'message': _message.text.trim(),
        'topic': _topic,
        if (user.email.isNotEmpty) 'email': user.email,
      });
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, ApiErrorHandler.from(error).message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _reset() {
    _subject.clear();
    _message.clear();
    setState(() {
      _topic = _topics.first;
      _sent = false;
    });
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
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
        title: const Text(
          'Contact Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PennyPalColors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: _sent
          ? _SentView(
              topic: _topic,
              onReset: _reset,
              onClose: () => context.pop(),
            )
          : _FormView(
              subject: _subject,
              message: _message,
              topic: _topic,
              onTopicChanged: (value) => setState(() => _topic = value),
              sending: _sending,
              onSend: _sending ? null : _send,
              onHelp: () => context.push('/help'),
            ),
    );
  }
}

class _SentView extends StatelessWidget {
  const _SentView({
    required this.topic,
    required this.onReset,
    required this.onClose,
  });

  final String topic;
  final VoidCallback onReset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PennyPalColors.elevated,
                shape: BoxShape.circle,
                border: Border.all(color: PennyPalColors.border),
              ),
              child: const AppIcon(
                AppIcons.check,
                color: PennyPalColors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Message Sent',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Our support team will review your request\nand get back to you within 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: PennyPalColors.gray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: PennyPalColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: Text(
                topic,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PennyPalColors.lightGray,
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PennyPalColors.white,
                  foregroundColor: PennyPalColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PennyPalColors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: onReset,
              child: const Text(
                'Send another message',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PennyPalColors.gray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.subject,
    required this.message,
    required this.topic,
    required this.onTopicChanged,
    required this.sending,
    required this.onSend,
    required this.onHelp,
  });

  final TextEditingController subject;
  final TextEditingController message;
  final String topic;
  final ValueChanged<String> onTopicChanged;
  final bool sending;
  final VoidCallback? onSend;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PennyPalColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PennyPalColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    AppIcon(
                      AppIcons.support,
                      color: PennyPalColors.white,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Need help? We're here.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: PennyPalColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: PennyPalColors.mutedBorder),
                const SizedBox(height: 10),
                InkWell(
                  onTap: onHelp,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        AppIcon(
                          AppIcons.help,
                          color: PennyPalColors.gray,
                          size: 17,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Browse Help & FAQs first',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: PennyPalColors.white,
                            ),
                          ),
                        ),
                        AppIcon(
                          AppIcons.chevronRight,
                          color: PennyPalColors.muted,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _label('What is this about?'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in _topics)
                _TopicChip(
                  label: item,
                  selected: item == topic,
                  onTap: () => onTopicChanged(item),
                ),
            ],
          ),
          const SizedBox(height: 22),

          _label('Subject'),
          const SizedBox(height: 8),
          _field(
            controller: subject,
            hint: 'What do you need help with?',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          _label('Message'),
          const SizedBox(height: 8),
          TextField(
            controller: message,
            maxLines: 6,
            style: const TextStyle(color: PennyPalColors.white),
            decoration: InputDecoration(
              hintText: 'Describe your issue in detail\u2026',
              hintStyle: const TextStyle(color: PennyPalColors.muted),
              filled: true,
              fillColor: PennyPalColors.surface,
              border: _border(PennyPalColors.border),
              enabledBorder: _border(PennyPalColors.border),
              focusedBorder: _border(PennyPalColors.white, width: 1.5),
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: PennyPalColors.white,
                foregroundColor: PennyPalColors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PennyPalColors.black,
                      ),
                    )
                  : const Text(
                      'Send Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PennyPalColors.black,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'We usually reply within 24 hours.',
              style: TextStyle(fontSize: 12, color: PennyPalColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: PennyPalColors.gray,
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputAction? textInputAction,
  }) => TextField(
    controller: controller,
    textInputAction: textInputAction,
    style: const TextStyle(color: PennyPalColors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PennyPalColors.muted),
      filled: true,
      fillColor: PennyPalColors.surface,
      border: _border(PennyPalColors.border),
      enabledBorder: _border(PennyPalColors.border),
      focusedBorder: _border(PennyPalColors.white, width: 1.5),
    ),
  );
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PennyPalColors.white : PennyPalColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? PennyPalColors.white : PennyPalColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? PennyPalColors.black : PennyPalColors.gray,
            ),
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder _border(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
