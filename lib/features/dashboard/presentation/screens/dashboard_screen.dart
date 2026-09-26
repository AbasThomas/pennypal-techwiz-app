import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/finance_providers.dart';
import '../../../../data/models/financial_models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.firstName});
  final String firstName;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(transactionsProvider);
    final budgetState = ref.watch(budgetsProvider);
    final goalState = ref.watch(savingsGoalsProvider);
    if (txState.isLoading || budgetState.isLoading || goalState.isLoading) return const Scaffold(backgroundColor: PennyPalColors.black, body: Center(child: CircularProgressIndicator()));
    final error = txState.error ?? budgetState.error ?? goalState.error;
    if (error != null) {
      return Scaffold(
        backgroundColor: PennyPalColors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              'We could not load your financial data. Please check your connection and try again.\n\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: PennyPalColors.gray),
            ),
          ),
        ),
      );
    }
    final tx = txState.value ?? <FinanceTransaction>[];
    final now = DateTime.now();
    final income = tx.where((t) => t.type == TransactionType.income).fold<double>(0, (a, t) => a + t.amount);
    final expense = tx.where((t) => t.type == TransactionType.expense).fold<double>(0, (a, t) => a + t.amount);
    final monthlyExpense = tx.where((t) => t.type == TransactionType.expense && t.date.year == now.year && t.date.month == now.month).fold<double>(0, (a, t) => a + t.amount);
    final month = DateFormat('yyyy-MM').format(now);
    final budgets = budgetState.value ?? <Budget>[];
    final budget = budgets.where((b) => b.month == month).firstOrNull;
    final goals = goalState.value ?? <SavingsGoal>[];
    return Scaffold(backgroundColor: PennyPalColors.black, body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20,20,20,110), children: [
      Text('Hello, $firstName', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 18),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('AVAILABLE BALANCE', style: TextStyle(color: PennyPalColors.gray)), Text(_money(income-expense), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)), const SizedBox(height: 12), Row(children: [Expanded(child: Text('Income\n${_money(income)}', style: const TextStyle(color: Colors.green))), Expanded(child: Text('Expenses\n${_money(expense)}', style: const TextStyle(color: Colors.red)))])])),
      const SizedBox(height: 12), Row(children: [Expanded(child: FilledButton(onPressed: ()=>context.push('/add-income'), child: const Text('Add income'))), const SizedBox(width: 10), Expanded(child: FilledButton(onPressed: ()=>context.push('/add-expense'), child: const Text('Add expense')))]),
      _heading('Monthly budget', ()=>context.push('/budget')),
      if (budget == null) _card(const Text('No budget for this month.', style: TextStyle(color: PennyPalColors.gray))) else _budget(budget, monthlyExpense),
      _heading('Savings goals', ()=>context.push('/savings')),
      if (goals.isEmpty) _card(const Text('No savings goals yet.', style: TextStyle(color: PennyPalColors.gray))) else ...goals.take(3).map((g) => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(g.goalName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), LinearProgressIndicator(value: g.progress, backgroundColor: PennyPalColors.border, color: Colors.white), Text('${(g.progress * 100).toStringAsFixed(0)}% complete', style: const TextStyle(color: PennyPalColors.gray))]))),
      _heading('Recent transactions', ()=>context.push('/home')),
      if (tx.isEmpty) _card(const Text('No transactions yet.', style: TextStyle(color: PennyPalColors.gray))) else ...tx.take(5).map((t) => ListTile(title: Text(t.description, style: const TextStyle(color: Colors.white)), subtitle: Text(t.categoryId, style: const TextStyle(color: PennyPalColors.gray)), trailing: Text(_money(t.amount), style: TextStyle(color: t.type == TransactionType.income ? Colors.green : Colors.red))))
    ])));
  }
  String _money(double value) => NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(value);
  Widget _card(Widget child) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: PennyPalColors.surface, borderRadius: BorderRadius.circular(14)), child: child);
  Widget _heading(String title, VoidCallback action) => Row(children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)), const Spacer(), TextButton(onPressed: action, child: const Text('View all'))]);
  Widget _budget(Budget budget, double spent) { final double ratio = budget.limitAmount == 0 ? 0 : (spent / budget.limitAmount).clamp(0.0, 1.0); return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${_money(spent)} of ${_money(budget.limitAmount)}', style: const TextStyle(color: Colors.white)), const SizedBox(height: 8), LinearProgressIndicator(value: ratio, color: ratio >= 1 ? Colors.red : Colors.white, backgroundColor: PennyPalColors.border)])); }
}
extension _FirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
