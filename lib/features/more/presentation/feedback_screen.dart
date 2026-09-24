import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Give Feedback',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: Lottie.asset('assets/animations/feedback_success.json', height: 200)
            const LottiePlaceholder(
              height: 200,
              label: 'feedback_success.json',
              tint: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text('Thank you! 💚',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text)),
            const SizedBox(height: 10),
            const Text(
              'Thanks for helping us improve PennyPal!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.muted),
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
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),

          // ── Star rating ──────────────────────────────────────
          Row(
            children: List.generate(5, (i) {
              final filled = i < rating;
              return GestureDetector(
                onTap: () => onRating(i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 38,
                    color: filled ? AppColors.gold : const Color(0xFFCBD5E1),
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
            decoration: InputDecoration(
              hintText: 'Tell us what you think…',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Submit Feedback',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
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
          color: AppColors.muted));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? type,
  }) =>
      TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2)),
        ),
      );
}
