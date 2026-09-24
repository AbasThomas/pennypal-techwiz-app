import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _comments = TextEditingController();
  int _rating = 0;
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _comments.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) return;
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Give Feedback',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white)),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: _submitted ? _SuccessView() : _FormView(
        name: _name,
        email: _email,
        comments: _comments,
        rating: _rating,
        onRating: (r) => setState(() => _rating = r),
        onSubmit: _submit,
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottiePlaceholder(
              height: 200,
              label: 'feedback_success.json',
              tint: PennyPalColors.white,
            ),
            SizedBox(height: 24),
            Text('Thank you!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: PennyPalColors.white)),
            SizedBox(height: 10),
            Text(
              'Thanks for helping us improve PennyPal!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: PennyPalColors.gray),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.name,
    required this.email,
    required this.comments,
    required this.rating,
    required this.onRating,
    required this.onSubmit,
  });

  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController comments;
  final int rating;
  final ValueChanged<int> onRating;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "How's your PennyPal experience?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: PennyPalColors.white,
            ),
          ),
          const SizedBox(height: 20),

          // â”€â”€ Star rating â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(
            children: List.generate(5, (i) {
              final filled = i < rating;
              return GestureDetector(
                onTap: () => onRating(i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppIcon(
                    filled ? AppIcons.star : AppIcons.starOff,
                    size: 38,
                    color: filled ? PennyPalColors.white : PennyPalColors.border,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          _label('Name'),
          const SizedBox(height: 8),
          _field(controller: name, hint: 'Your name'),
          const SizedBox(height: 16),

          _label('Email'),
          const SizedBox(height: 8),
          _field(
              controller: email,
              hint: 'your@email.com',
              type: TextInputType.emailAddress),
          const SizedBox(height: 16),

          _label('Comments'),
          const SizedBox(height: 8),
          TextField(
            controller: comments,
            maxLines: 5,
            style: const TextStyle(color: PennyPalColors.white),
            decoration: InputDecoration(
              hintText: 'Tell us what you thinkâ€¦',
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
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: PennyPalColors.white,
                foregroundColor: PennyPalColors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Submit Feedback',
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

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? type,
  }) =>
      TextField(
        controller: controller,
        keyboardType: type,
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
