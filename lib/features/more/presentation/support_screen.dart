import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sent = false;

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
        title: const Text('Contact Support',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white)),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: _sent ? _SentView() : _FormView(
        subject: _subject,
        message: _message,
        onSend: () => setState(() => _sent = true),
      ),
    );
  }
}

class _SentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
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
              child: const AppIcon(AppIcons.check,
                  color: PennyPalColors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Message Sent',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: PennyPalColors.white)),
            const SizedBox(height: 10),
            const Text(
              'Our support team will review your\nrequest and get back to you.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14, color: PennyPalColors.gray, height: 1.5),
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
    required this.onSend,
  });
  final TextEditingController subject;
  final TextEditingController message;
  final VoidCallback onSend;

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
            child: const Row(children: [
              AppIcon(AppIcons.support,
                  color: PennyPalColors.white, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Need help? We're here.",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PennyPalColors.white),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          _label('Subject'),
          const SizedBox(height: 8),
          _field(controller: subject, hint: 'What do you need help with?'),
          const SizedBox(height: 16),

          _label('Message'),
          const SizedBox(height: 8),
          TextField(
            controller: message,
            maxLines: 6,
            style: const TextStyle(color: PennyPalColors.white),
            decoration: InputDecoration(
              hintText: 'Describe your issue in detailâ€¦',
              hintStyle: const TextStyle(color: PennyPalColors.muted),
              filled: true,
              fillColor: PennyPalColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: PennyPalColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: PennyPalColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: PennyPalColors.white, width: 1.5)),
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
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Send Message',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PennyPalColors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: PennyPalColors.gray));

  Widget _field(
          {required TextEditingController controller,
          required String hint}) =>
      TextField(
        controller: controller,
        style: const TextStyle(color: PennyPalColors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: PennyPalColors.muted),
          filled: true,
          fillColor: PennyPalColors.surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: PennyPalColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: PennyPalColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: PennyPalColors.white, width: 1.5)),
        ),
      );
}
