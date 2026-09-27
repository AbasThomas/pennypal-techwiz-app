import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../data/finance_providers.dart';
import '../../../../data/models/financial_models.dart';
import '../../../../shared/widgets/penny_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.firstName,
    this.onViewTransactions,
  });

  final String firstName;
  final VoidCallback? onViewTransactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(transactionsProvider);
    final budgetState = ref.watch(budgetsProvider);
    final goalState = ref.watch(savingsGoalsProvider);

    if (txState.isLoading || budgetState.isLoading || goalState.isLoading) {
      return const Scaffold(
        backgroundColor: PennyPalColors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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

    final transactions = txState.value ?? <FinanceTransaction>[];
    final now = DateTime.now();
    final income = transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold<double>(0, (total, transaction) => total + transaction.amount);
    final expenses = transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold<double>(0, (total, transaction) => total + transaction.amount);
    final monthlyExpense = transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              transaction.date.year == now.year &&
              transaction.date.month == now.month,
        )
        .fold<double>(0, (total, transaction) => total + transaction.amount);
    final currentMonth = DateFormat('yyyy-MM').format(now);
    final budgets = budgetState.value ?? <Budget>[];
    final budget = budgets
        .where((item) => item.month == currentMonth)
        .firstOrNull;
    final goals = goalState.value ?? <SavingsGoal>[];

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          children: [
            _GreetingCard(firstName: firstName, time: now),
            const SizedBox(height: 18),
            BalanceCard(
              balance: _money(income - expenses),
              income: _money(income),
              expenses: _money(expenses),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: QuickActionButton(
                    icon: AppIcons.arrowUp,
                    label: 'Add income',
                    color: PennyPalColors.successSurface,
                    iconColor: PennyPalColors.success,
                    onTap: () => context.push('/add-income'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionButton(
                    icon: AppIcons.arrowDown,
                    label: 'Add expense',
                    color: PennyPalColors.dangerSurface,
                    iconColor: PennyPalColors.danger,
                    onTap: () => context.push('/add-expense'),
                  ),
                ),
              ],
            ),
            _heading('Monthly budget', () => context.push('/budget')),
            if (budget == null)
              _card(
                const Text(
                  'Set a monthly budget to track your spending here.',
                  style: TextStyle(color: PennyPalColors.gray),
                ),
              )
            else
              _budget(budget, monthlyExpense),
            _heading('Savings goals', () => context.push('/savings')),
            if (goals.isEmpty)
              _card(
                const Text(
                  'No savings goals yet.',
                  style: TextStyle(color: PennyPalColors.gray),
                ),
              )
            else
              ...goals
                  .take(3)
                  .map((goal) => _SavingsGoalCard(goal: goal, money: _money)),
            _heading(
              'Recent transactions',
              onViewTransactions ?? () => context.push('/home'),
            ),
            if (transactions.isEmpty)
              _card(
                const Text(
                  'No transactions yet.',
                  style: TextStyle(color: PennyPalColors.gray),
                ),
              )
            else
              _RecentTransactionsCard(
                transactions: transactions.take(5).toList(),
                money: _money,
              ),
          ],
        ),
      ),
    );
  }

  String _money(double value) =>
      NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(value);

  Widget _card(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: PennyPalColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: PennyPalColors.border),
    ),
    child: child,
  );

  Widget _heading(String title, VoidCallback action) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: PennyPalColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        TextButton(onPressed: action, child: const Text('View all')),
      ],
    ),
  );

  Widget _budget(Budget budget, double spent) {
    final rawRatio = budget.limitAmount == 0 ? 0.0 : spent / budget.limitAmount;
    final progress = rawRatio.clamp(0.0, 1.0).toDouble();
    final remaining = budget.limitAmount - spent;
    final isOverBudget = remaining < 0;
    final isNearLimit = rawRatio >= budget.alertThreshold;
    final color = isOverBudget
        ? PennyPalColors.danger
        : isNearLimit
        ? PennyPalColors.lightGray
        : PennyPalColors.success;
    final status = isOverBudget
        ? '${_money(remaining.abs())} over budget'
        : '${_money(remaining)} remaining';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PennyPalColors.surface, PennyPalColors.nearBlack],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Center(
                  child: AppIcon(
                    AppIcons.chart,
                    size: 19,
                    color: PennyPalColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This month',
                      style: TextStyle(
                        color: PennyPalColors.gray,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_money(spent)} spent of ${_money(budget.limitAmount)}',
                      style: const TextStyle(
                        color: PennyPalColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(rawRatio * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 9,
                color: color,
                backgroundColor: PennyPalColors.border,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.firstName, required this.time});

  final String firstName;
  final DateTime time;

  String get _greeting {
    if (time.hour < 12) return 'Good morning';
    if (time.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _animationAsset => time.hour >= 18 || time.hour < 5
      ? 'assets/animations/Moon.json'
      : 'assets/animations/sunny.json';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PennyPalColors.card, PennyPalColors.nearBlack],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 124, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'YOUR DAILY BRIEF',
                  style: TextStyle(
                    color: PennyPalColors.gray,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_greeting, $firstName',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PennyPalColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'A clear view of your money, today.',
                  style: TextStyle(color: PennyPalColors.gray, fontSize: 13),
                ),
              ],
            ),
          ),
          Positioned(
            right: -4,
            top: 4,
            bottom: 4,
            child: IgnorePointer(
              child: Lottie.asset(
                _animationAsset,
                width: 126,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsGoalCard extends StatelessWidget {
  const _SavingsGoalCard({required this.goal, required this.money});

  final SavingsGoal goal;
  final String Function(double value) money;

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress;
    final isComplete = progress >= 1;
    final remaining = (goal.targetAmount - goal.currentAmount)
        .clamp(0.0, double.infinity)
        .toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isComplete
                      ? PennyPalColors.successSurface
                      : PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AppIcon(
                    isComplete ? AppIcons.check : AppIcons.wallet,
                    color: isComplete
                        ? PennyPalColors.success
                        : PennyPalColors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.goalName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PennyPalColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: isComplete
                      ? PennyPalColors.successSurface
                      : PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isComplete
                      ? 'Complete'
                      : '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: isComplete
                        ? PennyPalColors.success
                        : PennyPalColors.lightGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                money(goal.currentAmount),
                style: const TextStyle(
                  color: PennyPalColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                ' of ${money(goal.targetAmount)}',
                style: const TextStyle(
                  color: PennyPalColors.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                isComplete ? 'Goal reached' : '${money(remaining)} to go',
                style: TextStyle(
                  color: isComplete
                      ? PennyPalColors.success
                      : PennyPalColors.gray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                color: isComplete
                    ? PennyPalColors.success
                    : PennyPalColors.white,
                backgroundColor: PennyPalColors.border,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({
    required this.transactions,
    required this.money,
  });

  final List<FinanceTransaction> transactions;
  final String Function(double value) money;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < transactions.length; index++) ...[
            TransactionTile(
              title: transactions[index].description.trim().isEmpty
                  ? transactions[index].categoryId
                  : transactions[index].description,
              subtitle:
                  '${transactions[index].categoryId} • ${DateFormat('MMM d').format(transactions[index].date)}',
              amount: money(transactions[index].amount),
              isIncome: transactions[index].type == TransactionType.income,
            ),
            if (index < transactions.length - 1)
              const Divider(height: 1, color: PennyPalColors.mutedBorder),
          ],
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
