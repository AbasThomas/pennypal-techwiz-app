import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';

class _Faq {
  const _Faq(this.category, this.question, this.answer);
  final String category;
  final String question;
  final String answer;
}

const _faqs = <_Faq>[
  _Faq(
    'Getting Started',
    'How do I record a transaction?',
    'Tap the + button at the bottom of the Home screen, then choose Expense or Income. '
        'Pick a category, enter the amount and an optional note, then save. The entry '
        'appears immediately on your dashboard and in Reports.',
  ),
  _Faq(
    'Getting Started',
    'Can I edit or delete a transaction?',
    'Yes. Open the transaction from Home or Reports, then use the edit or delete '
        'option on the detail screen. Deleting removes it from your totals right away.',
  ),
  _Faq(
    'Getting Started',
    'Which currency does PennyPal use?',
    'PennyPal defaults to Naira (NGN) but supports USD, EUR, GBP, ZAR, KES, GHS, JPY, '
        'INR, CAD and AUD. Change it any time in Settings → Appearance → Currency.',
  ),
  _Faq(
    'Transactions',
    'Why does my balance not match my bank?',
    'PennyPal only knows what you record. If a cash withdrawal, bank charge or '
        'transfer is missing, add it as an expense so your balance stays accurate.',
  ),
  _Faq(
    'Transactions',
    'Can I record recurring transactions?',
    'Recurring entries are not automated yet. For now, add each occurrence manually '
        'or set a Daily Entry Reminder in Settings so you never forget to log them.',
  ),
  _Faq(
    'Transactions',
    'What is the difference between Expense and Income?',
    'Expenses reduce your balance and count towards budgets. Income increases your '
        'balance and is tracked separately in Reports so you can see what you earn '
        'versus what you spend.',
  ),
  _Faq(
    'Budgets',
    'How do budgets work?',
    'Set a monthly limit for a category from the Plan tab. PennyPal tracks your '
        'spending against it and warns you as you approach the limit.',
  ),
  _Faq(
    'Budgets',
    'What happens when I exceed a budget?',
    'The budget is marked as exceeded and, if Budget Alerts are enabled in Settings, '
        'you receive a notification so you can adjust your spending.',
  ),
  _Faq(
    'Goals',
    'How do I create a savings goal?',
    'Open the Plan tab, choose Savings, and add a goal with a target amount and an '
        'optional deadline. Add contributions as you save and watch the progress bar fill up.',
  ),
  _Faq(
    'Goals',
    'Can I contribute to a goal in another currency?',
    'Goals use your app currency, set in Settings → Appearance → Currency. Contributions '
        'are recorded in that currency so progress stays consistent.',
  ),
  _Faq(
    'Notifications',
    'How do I turn notifications on or off?',
    'Go to Settings → Notifications. Transaction, Budget and Savings Goal alerts can be '
        'switched individually. Android may still ask for permission the first time you '
        'enable them — accept it so alerts can be delivered.',
  ),
  _Faq(
    'Notifications',
    'How does the Daily Entry Reminder work?',
    'Enable Daily Entry Reminder in Settings → Notifications and pick a time. PennyPal '
        'sends a local reminder every day at that time so you can log your spending. '
        'Keep notifications allowed in your phone settings for it to appear.',
  ),
  _Faq(
    'Notifications',
    'Why am I not receiving push notifications?',
    'Check three things: notifications are allowed for PennyPal in your phone settings, '
        'the relevant alert toggle is on in Settings → Notifications, and your device is '
        'online. Open Settings → Notifications and tap "Send test notification" to verify '
        'delivery.',
  ),
  _Faq(
    'Account',
    'How do I change my password?',
    'Go to Settings → Security → Change Password. Enter your current password, then '
        'your new password twice. If you have forgotten your current password, use the '
        '"Forgot password?" link on the sign-in screen to reset it by email.',
  ),
  _Faq(
    'Account',
    'How do I update my profile details?',
    'Open Settings and tap your profile card at the top, or go to the Profile tab. '
        'You can update your name, phone number, institution, bio and profile picture.',
  ),
  _Faq(
    'Account',
    'How do I delete my account?',
    'Go to Profile → Account → Delete Account. This permanently removes your account '
        'and data and cannot be undone. If you only want a break, use Deactivate Account '
        'instead — you can sign back in later.',
  ),
  _Faq(
    'AI Assistant',
    'What can the AI Assistant do?',
    'The assistant answers questions about your spending and gives budgeting tips based '
        'on what you have recorded. Open it from the Home screen sparkle icon or the More tab.',
  ),
  _Faq(
    'AI Assistant',
    'Is my financial data used to train AI models?',
    'No. Your figures are sent only to generate an answer to your question and are not '
        'used to train models.',
  ),
];

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final _search = TextEditingController();
  String _query = '';
  String _category = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_Faq> get _filtered {
    final q = _query.trim().toLowerCase();
    return _faqs.where((f) {
      if (_category != 'All' && f.category != _category) return false;
      if (q.isEmpty) return true;
      return f.question.toLowerCase().contains(q) ||
          f.answer.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...{for (final f in _faqs) f.category}];
    final results = _filtered;

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Help & FAQs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PennyPalColors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: PennyPalColors.white, fontSize: 14.5),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search help articles',
              hintStyle: const TextStyle(
                color: PennyPalColors.muted,
                fontSize: 14.5,
              ),
              prefixIcon: const SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: AppIcon(
                    AppIcons.search,
                    size: 13,
                    color: PennyPalColors.muted,
                  ),
                ),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 34, minHeight: 34, maxWidth: 34, maxHeight: 34),
              suffixIcon: _query.isEmpty
                  ? null
                  : SizedBox(
                      width: 34,
                      height: 34,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                        icon: const AppIcon(
                          AppIcons.close,
                          size: 13,
                          color: PennyPalColors.muted,
                        ),
                      ),
                    ),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 34, minHeight: 34, maxWidth: 34, maxHeight: 34),
              filled: true,
              fillColor: PennyPalColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
              border: _border(PennyPalColors.border),
              enabledBorder: _border(PennyPalColors.border),
              focusedBorder: _border(PennyPalColors.white, width: 1.5),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = categories[i];
                final selected = c == _category;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? PennyPalColors.white
                          : PennyPalColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? PennyPalColors.white
                            : PennyPalColors.border,
                      ),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? PennyPalColors.black
                            : PennyPalColors.gray,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: PennyPalColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: PennyPalColors.border),
                    ),
                    child: const AppIcon(
                      AppIcons.search,
                      color: PennyPalColors.gray,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No matching articles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PennyPalColors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Try a different keyword, or contact support below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: PennyPalColors.gray,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else
            ...results.map((f) => _FaqTile(faq: f)),
          const SizedBox(height: 24),

          const Text(
            'STILL NEED HELP?',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: PennyPalColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PennyPalColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PennyPalColors.border),
            ),
            child: Column(
              children: [
                const Text(
                  'Our support team usually replies within 24 hours.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: PennyPalColors.gray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context.push('/support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PennyPalColors.white,
                      foregroundColor: PennyPalColors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: PennyPalColors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => context.push('/feedback'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PennyPalColors.white,
                      side: const BorderSide(
                        color: PennyPalColors.border,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Send Feedback',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: PennyPalColors.white,
                      ),
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

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.faq});
  final _Faq faq;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _open ? PennyPalColors.darkGray : PennyPalColors.border,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _open,
          onExpansionChanged: (v) => setState(() => _open = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: PennyPalColors.white,
          collapsedIconColor: PennyPalColors.muted,
          title: Text(
            widget.faq.question,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: PennyPalColors.white,
              height: 1.35,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.faq.answer,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: PennyPalColors.gray,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.faq.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: PennyPalColors.muted,
                ),
              ),
            ),
          ],
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
