import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/finance_providers.dart';
import '../../../../data/models/financial_models.dart';
import '../../../auth/providers/auth_providers.dart';

class AddIncomeScreen extends ConsumerStatefulWidget {
  const AddIncomeScreen({super.key});
  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  final _amount = TextEditingController();
  final _source = TextEditingController();
  final _description = TextEditingController();

  static const _sources = [
    (AppIcons.freelance, 'Freelance'),
    (AppIcons.salary, 'Salary'),
    (AppIcons.gift, 'Gift'),
    (AppIcons.investment, 'Investment'),
    (AppIcons.education, 'Scholarship'),
    (AppIcons.users, 'Family'),
    (AppIcons.wallet, 'Part-time'),
    (AppIcons.add, 'Other'),
  ];

  String _selectedSource = 'Salary';
  bool _saving = false;
  Future<void> _save() async {
    final value = double.tryParse(_amount.text.replaceAll(',', '').trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid income amount.')),
      );
      return;
    }
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(financeRepositoryProvider)
          .saveTransaction(
            FinanceTransaction(
              id: '',
              userId: uid,
              type: TransactionType.income,
              amount: value,
              categoryId: _selectedSource,
              description: _description.text.trim().isEmpty
                  ? _selectedSource
                  : _description.text.trim(),
              date: DateTime.now(),
              paymentMode: 'Cash',
              source: _selectedSource,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Income saved.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save income: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _source.dispose();
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
          'Add Income',
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
            const LottiePlaceholder(
              height: 120,
              label: 'add_income.json',
              tint: PennyPalColors.white,
            ),
            const SizedBox(height: 28),

            // Amount
            const Text(
              'Amount',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PennyPalColors.gray,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: PennyPalColors.white,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: PennyPalColors.muted.withValues(alpha: 0.3),
                ),
                filled: true,
                fillColor: PennyPalColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: PennyPalColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: PennyPalColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: PennyPalColors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Source
            const Text(
              'Source',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PennyPalColors.gray,
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _sources.length,
              itemBuilder: (_, i) {
                final s = _sources[i];
                final selected = _selectedSource == s.$2;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSource = s.$2);
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
                          s.$1,
                          size: 22,
                          color: selected
                              ? PennyPalColors.white
                              : PennyPalColors.gray,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.$2,
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
            const Text(
              'Date',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PennyPalColors.gray,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: PennyPalColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: const Row(
                children: [
                  AppIcon(
                    AppIcons.calendar,
                    size: 18,
                    color: PennyPalColors.muted,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Today',
                    style: TextStyle(fontSize: 15, color: PennyPalColors.white),
                  ),
                  Spacer(),
                  AppIcon(AppIcons.chevronRight, color: PennyPalColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PennyPalColors.gray,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              style: const TextStyle(color: PennyPalColors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Website project payment',
                hintStyle: const TextStyle(color: PennyPalColors.muted),
                filled: true,
                fillColor: PennyPalColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: PennyPalColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: PennyPalColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: PennyPalColors.white,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PennyPalColors.white,
                  foregroundColor: PennyPalColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _saving ? 'Saving…' : 'Save Income',
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
      ),
    );
  }
}
