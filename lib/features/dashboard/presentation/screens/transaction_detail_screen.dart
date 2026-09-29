import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pennypal/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/finance_providers.dart';
import '../../../../data/models/financial_models.dart';

final _money = NumberFormat.currency(symbol: '\u20A6', decimalDigits: 0);
final _dateFmt = DateFormat('EEEE, MMMM d, yyyy');
final _timeFmt = DateFormat('h:mm a');
final _shortDate = DateFormat('MMM d, yyyy');

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transaction});
  final FinanceTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == TransactionType.income;
    final accent = isIncome ? PennyPalColors.success : PennyPalColors.danger;
    final accentSurface =
        isIncome ? PennyPalColors.successSurface : PennyPalColors.dangerSurface;
    final typeLabel = isIncome ? 'Income' : 'Expense';
    final sign = isIncome ? '+' : '-';

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: PennyPalColors.white),
        title: const Text(
          'Transaction Detail',
          style: TextStyle(
            color: PennyPalColors.white,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const AppIcon(
              AppIcons.edit,
              color: PennyPalColors.white,
              size: 20,
            ),
            tooltip: 'Edit transaction',
            onPressed: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: PennyPalColors.elevated,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: PennyPalColors.border),
                  ),
                  content: const Text(
                    'Edit coming soon',
                    style: TextStyle(
                      color: PennyPalColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const AppIcon(
              AppIcons.share,
              color: PennyPalColors.white,
              size: 20,
            ),
            tooltip: 'Share receipt',
            onPressed: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: PennyPalColors.elevated,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: PennyPalColors.border),
                  ),
                  content: const Text(
                    'Share coming soon',
                    style: TextStyle(
                      color: PennyPalColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const AppIcon(
              AppIcons.delete,
              color: PennyPalColors.danger,
              size: 20,
            ),
            tooltip: 'Delete transaction',
            onPressed: () => _confirmDelete(context, ref),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    PennyPalColors.surface,
                    PennyPalColors.nearBlack,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accentSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: AppIcon(
                        AppIcons.forCategory(transaction.categoryId),
                        size: 32,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accentSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      typeLabel.toUpperCase(),
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '$sign${_money.format(transaction.amount)}',
                    style: TextStyle(
                      color: accent,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    transaction.description.isNotEmpty
                        ? transaction.description
                        : transaction.categoryId,
                    style: const TextStyle(
                      color: PennyPalColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_dateFmt.format(transaction.date)}  \u2022  ${_timeFmt.format(transaction.date)}',
                    style: const TextStyle(
                      color: PennyPalColors.gray,
                      fontSize: 12.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Quick stats row
            Row(
              children: [
                Expanded(
                  child: _QuickStat(
                    icon: AppIcons.calendar,
                    label: 'Date',
                    value: _shortDate.format(transaction.date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStat(
                    icon: AppIcons.invoice,
                    label: 'Time',
                    value: _timeFmt.format(transaction.date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Details section
            const _SectionLabel('Transaction Details'),
            _DetailCard(
              children: [
                _DetailRow(
                  icon: AppIcons.receipt,
                  label: 'Category',
                  value: transaction.categoryId,
                ),
                _DetailRow(
                  icon: AppIcons.creditCard,
                  label: 'Payment Method',
                  value: transaction.paymentMode,
                ),
                _DetailRow(
                  icon: isIncome ? AppIcons.arrowDown : AppIcons.arrowUp,
                  label: 'Transaction Type',
                  value: typeLabel,
                  valueColor: accent,
                ),
                if (transaction.source != null &&
                    transaction.source!.isNotEmpty)
                  _DetailRow(
                    icon: AppIcons.transfer,
                    label: 'Source / Account',
                    value: transaction.source!,
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Notes / Description section
            const _SectionLabel('Notes'),
            _DetailCard(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: PennyPalColors.elevated,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Center(
                          child: AppIcon(
                            AppIcons.info,
                            size: 15,
                            color: PennyPalColors.gray,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: PennyPalColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              transaction.description.isNotEmpty
                                  ? transaction.description
                                  : 'No description added.',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: PennyPalColors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Reference section
            const _SectionLabel('Reference'),
            _DetailCard(
              children: [
                _DetailRow(
                  icon: AppIcons.receipt,
                  label: 'Transaction ID',
                  value: transaction.id,
                  monospace: true,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: transaction.id));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: PennyPalColors.elevated,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              const BorderSide(color: PennyPalColors.border),
                        ),
                        content: const Text(
                          'Transaction ID copied',
                          style: TextStyle(
                            color: PennyPalColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                _DetailRow(
                  icon: transaction.syncStatus == 'synced'
                      ? AppIcons.check
                      : AppIcons.refresh,
                  label: 'Sync Status',
                  value: transaction.syncStatus == 'synced'
                      ? 'Synced to cloud'
                      : 'Pending sync',
                  valueColor: transaction.syncStatus == 'synced'
                      ? PennyPalColors.success
                      : PennyPalColors.gray,
                ),
                _DetailRow(
                  icon: AppIcons.user,
                  label: 'User ID',
                  value: transaction.userId,
                  monospace: true,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: transaction.userId));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: PennyPalColors.elevated,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              const BorderSide(color: PennyPalColors.border),
                        ),
                        content: const Text(
                          'User ID copied',
                          style: TextStyle(
                            color: PennyPalColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PennyPalColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: PennyPalColors.danger),
        ),
        title: const Row(
          children: [
            AppIcon(AppIcons.delete, color: PennyPalColors.danger, size: 20),
            SizedBox(width: 8),
            Text(
              'Delete Transaction?',
              style: TextStyle(
                color: PennyPalColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          'This transaction will be permanently removed and cannot be undone. This action may affect your monthly reports and balance calculations.',
          style: TextStyle(
            color: PennyPalColors.lightGray,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: PennyPalColors.gray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PennyPalColors.danger,
              foregroundColor: PennyPalColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(financeRepositoryProvider)
            .deleteTransaction(transaction.id);
        if (context.mounted) context.pop();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: PennyPalColors.dangerSurface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: PennyPalColors.danger),
              ),
              content: Text(
                'Failed to delete: $e',
                style: const TextStyle(
                  color: PennyPalColors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }
      }
    }
  }
}

// --- Sub-widgets --------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
        color: PennyPalColors.muted,
      ),
    ),
  );
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: PennyPalColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: PennyPalColors.border),
    ),
    child: Column(
      children: children.asMap().entries.map((e) {
        return Column(
          children: [
            e.value,
            if (e.key < children.length - 1)
              const Divider(
                height: 1,
                indent: 52,
                endIndent: 16,
                color: PennyPalColors.mutedBorder,
              ),
          ],
        );
      }).toList(),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.monospace = false,
    this.onTap,
  });
  final List<List<dynamic>> icon;
  final String label, value;
  final Color? valueColor;
  final bool monospace;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: PennyPalColors.elevated,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: AppIcon(icon, size: 15, color: PennyPalColors.gray),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: PennyPalColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? PennyPalColors.white,
                    fontFamily: monospace ? 'monospace' : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const AppIcon(
              AppIcons.copy,
              size: 14,
              color: PennyPalColors.muted,
            ),
          ],
        ],
      ),
    ),
  );
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final List<List<dynamic>> icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PennyPalColors.elevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AppIcon(icon, size: 17, color: PennyPalColors.gray),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: PennyPalColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: PennyPalColors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
