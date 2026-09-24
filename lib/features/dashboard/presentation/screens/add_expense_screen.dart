import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amount = TextEditingController();
  final _description = TextEditingController();
  String _selectedCategory = 'Food';
  String _aiHint = '';

  static const _categories = [
    ('🍔', 'Food'),
    ('🚌', 'Transport'),
    ('📚', 'Education'),
    ('🛍', 'Shopping'),
    ('🎬', 'Entertainment'),
    ('💊', 'Health'),
    ('🏠', 'Housing'),
    ('⚡', 'Utilities'),
  ];

  void _onAmountChanged(String v) {
    // TODO: wire real AI categorization — this simulates a hint
    if (v.contains('35') || v.contains('25')) {
      setState(() => _aiHint = '🤖 AI detected: Food');
    } else {
      setState(() => _aiHint = '');
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
        ),
        title: const Text(
          'Add Expense',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Lottie placeholder ─────────────────────────────
            // TODO: Lottie.asset('assets/animations/add_expense.json', height: 140)
            const LottiePlaceholder(height: 120, label: 'add_expense.json'),
            const SizedBox(height: 28),

            // ── Amount ─────────────────────────────────────────
            const Text('Amount',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted)),
            const SizedBox(height: 8),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              onChanged: _onAmountChanged,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text),
                hintText: '0',
                hintStyle: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted.withValues(alpha: 0.3)),
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

            // ── AI hint ────────────────────────────────────────
            if (_aiHint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_aiHint,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.primary)),
              ),
            ],
            const SizedBox(height: 24),

            // ── Category ────────────────────────────────────────
            const Text('Category',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted)),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat.$2;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : const Color(0xFFE2E8F0),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat.$1,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          cat.$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.primary
                                : AppColors.muted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Date ────────────────────────────────────────────
            const Text('Date',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: const Border.fromBorderSide(
                    BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.muted),
                  const SizedBox(width: 10),
                  const Text('Today',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.text)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Description ─────────────────────────────────────
            const Text('Description',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted)),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              decoration: InputDecoration(
                hintText: 'e.g. Lunch at campus',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
            const SizedBox(height: 24),

            // ── Receipt ─────────────────────────────────────────
            GestureDetector(
              onTap: () {}, // TODO: image_picker
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.primary, size: 28),
                    SizedBox(height: 6),
                    Text('Add receipt',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Save ────────────────────────────────────────────
            AppButton(
              text: 'Save Expense',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
