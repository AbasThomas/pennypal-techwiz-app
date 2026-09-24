import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
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
    (AppIcons.food, 'Food'),
    (AppIcons.transport, 'Transport'),
    (AppIcons.education, 'Education'),
    (AppIcons.shoppingBag, 'Shopping'),
    (AppIcons.entertainment, 'Entertainment'),
    (AppIcons.health, 'Health'),
    (AppIcons.house, 'Housing'),
    (AppIcons.utilities, 'Utilities'),
  ];

  void _onAmountChanged(String v) {
    if (v.contains('35') || v.contains('25')) {
      setState(() => _aiHint = 'AI detected: Food');
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
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const AppIcon(AppIcons.arrowBack, color: PennyPalColors.white),
        ),
        title: const Text(
          'Add Expense',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PennyPalColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lottie placeholder
            const LottiePlaceholder(
                height: 120,
                label: 'add_expense.json',
                tint: PennyPalColors.white),
            const SizedBox(height: 28),

            // Amount
            const Text('Amount',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PennyPalColors.gray)),
            const SizedBox(height: 8),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              onChanged: _onAmountChanged,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: PennyPalColors.white),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: PennyPalColors.muted.withValues(alpha: 0.3)),
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
                        color: PennyPalColors.white, width: 2)),
              ),
            ),

            // AI hint
            if (_aiHint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: PennyPalColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: Text(_aiHint,
                    style: const TextStyle(
                        fontSize: 13, color: PennyPalColors.white)),
              ),
            ],
            const SizedBox(height: 24),

            // Category
            const Text('Category',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PennyPalColors.gray)),
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
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat.$2);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected
                          ? PennyPalColors.elevated
                          : PennyPalColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? PennyPalColors.white
                            : PennyPalColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                          cat.$1,
                          size: 22,
                          color: selected
                              ? PennyPalColors.white
                              : PennyPalColors.gray,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? PennyPalColors.white
                                : PennyPalColors.muted,
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

            // Date
            const Text('Date',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PennyPalColors.gray)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: PennyPalColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: const Row(
                children: [
                  AppIcon(AppIcons.calendar,
                      size: 18, color: PennyPalColors.muted),
                  SizedBox(width: 10),
                  Text('Today',
                      style: TextStyle(
                          fontSize: 15, color: PennyPalColors.white)),
                  Spacer(),
                  AppIcon(AppIcons.chevronRight,
                      color: PennyPalColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text('Description',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PennyPalColors.gray)),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              style: const TextStyle(color: PennyPalColors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Lunch at campus',
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
                    borderSide:
                        const BorderSide(color: PennyPalColors.white, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),

            // Receipt
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: PennyPalColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: PennyPalColors.border,
                    width: 1.5,
                  ),
                ),
                child: const Column(
                  children: [
                    AppIcon(AppIcons.image,
                        color: PennyPalColors.white, size: 28),
                    SizedBox(height: 6),
                    Text('Add receipt',
                        style: TextStyle(
                            color: PennyPalColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save
            AppButton(
              text: 'Save Expense',
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
