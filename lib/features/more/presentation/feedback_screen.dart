import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pennypal/core/widgets/app_icon.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/finance_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/lottie_placeholder.dart';
import '../../auth/providers/auth_providers.dart';

const _ratingLabels = <int, String>{
  1: 'Needs work',
  2: 'Could be better',
  3: 'Decent',
  4: 'Great',
  5: 'Love it!',
};

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _comments = TextEditingController();
  int _rating = 0;
  bool _submitted = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final display = [user.firstName, user.lastName]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .join(' ')
        .trim();
    if (display.isNotEmpty) _name.text = display;
    if (user.email.isNotEmpty) _email.text = user.email;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _comments.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        Validators.email(_email.text) != null ||
        Validators.required(_comments.text, label: 'Comments') != null ||
        _rating == 0) {
      AppSnackbar.error(
        context,
        'Add your name, a valid email, a star rating and a few comments.',
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) {
      AppSnackbar.error(context, 'Sign in again to send feedback.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      await ref.read(financeRepositoryProvider).submitFeedback(user.id, {
        'type': 'feedback',
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'rating': _rating,
        'comments': _comments.text.trim(),
        'source': 'feedback_screen',
      });
      if (!mounted) return;
      setState(() => _submitted = true);
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, ApiErrorHandler.from(error).message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _reset() {
    _comments.clear();
    setState(() {
      _rating = 0;
      _submitted = false;
    });
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
          'Give Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PennyPalColors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: _submitted
          ? _SuccessView(onReset: _reset, onClose: () => context.pop())
          : _FormView(
              name: _name,
              email: _email,
              comments: _comments,
              rating: _rating,
              onRating: (value) => setState(() => _rating = value),
              sending: _sending,
              onSubmit: _sending ? null : _submit,
            ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onReset, required this.onClose});

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
            const LottiePlaceholder(
              height: 200,
              label: 'feedback_success.json',
              tint: PennyPalColors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Thank you!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Thanks for helping us improve PennyPal!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: PennyPalColors.gray),
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
                'Send more feedback',
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
    required this.name,
    required this.email,
    required this.comments,
    required this.rating,
    required this.onRating,
    required this.sending,
    required this.onSubmit,
  });

  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController comments;
  final int rating;
  final ValueChanged<int> onRating;
  final bool sending;
  final VoidCallback? onSubmit;

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

          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => onRating(i),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppIcon(
                      i <= rating ? AppIcons.star : AppIcons.starOff,
                      size: 38,
                      color: i <= rating
                          ? PennyPalColors.white
                          : PennyPalColors.border,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rating == 0
                ? 'Tap a star to rate'
                : _ratingLabels[rating] ?? 'Thanks!',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: rating == 0
                  ? PennyPalColors.muted
                  : PennyPalColors.lightGray,
            ),
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
            type: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          _label('Comments'),
          const SizedBox(height: 8),
          TextField(
            controller: comments,
            maxLines: 5,
            style: const TextStyle(color: PennyPalColors.white),
            decoration: InputDecoration(
              hintText: 'Tell us what you think\u2026',
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
              onPressed: onSubmit,
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
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PennyPalColors.black,
                      ),
                    ),
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
    TextInputType? type,
  }) => TextField(
    controller: controller,
    keyboardType: type,
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

OutlineInputBorder _border(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
