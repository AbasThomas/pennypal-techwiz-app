import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/lottie_placeholder.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});
  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _amount = TextEditingController();
  final _source = TextEditingController();
  final _description = TextEditingController();

  static const _sources = [
    ('💼', 'Freelance'),
    ('💰', 'Salary'),
    ('🎁', 'Gift'),
    ('📈', 'Investment'),
    ('🏫', 'Scholarship'),
    ('👨‍👩‍👧', 'Family'),
    ('🤝', 'Part-time'),
    ('➕', 'Other'),
  ];

  String _selectedSource = 'Salary';

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
          'Add Income',
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
            // TODO: Lottie.asset('assets/animations/add_income.json', height: 120)
            const LottiePlaceholder(
                height: 120,
                label: 'add_income.json',
                tint: Color(0xFF16A34A)),
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
                        color: Color(0xFF16A34A), width: 2)),
              ),
            ),
            const SizedBox(height: 24),

            // ── Source ─────────────────────────────────────────
            const Text('Source',
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
              itemCount: _sources.length,
              itemBuilder: (_, i) {
                final s = _sources[i];
                final selected = _selectedSource == s.$2;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedSource = s.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFF0FDF4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFE2E8F0),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.$1,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          s.$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? const Color(0xFF16A34A)
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
              child: const Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.muted),
                  SizedBox(width: 10),
                  Text('Today',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.text)),
                  Spacer(),
                  Icon(Icons.chevron_right_rounded,
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
                hintText: 'e.g. Website project payment',
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
            const SizedBox(height: 32),

            // ── Save ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Income',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
