import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/financial_models.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/dashboard/presentation/penny_pal_shell.dart';
import '../../features/dashboard/presentation/screens/add_expense_screen.dart';
import '../../features/dashboard/presentation/screens/add_income_screen.dart';
import '../../features/dashboard/presentation/screens/article_detail_screen.dart';
import '../../features/dashboard/presentation/screens/learn_screen.dart';
import '../../features/dashboard/presentation/screens/transaction_detail_screen.dart';
import '../../features/dashboard/presentation/screens/plan_screen.dart';
import '../../features/more/presentation/about_screen.dart';
import '../../features/more/presentation/ai_assistant_screen.dart';
import '../../features/more/presentation/feedback_screen.dart';
import '../../features/more/presentation/help_screen.dart';
import '../../features/more/presentation/notifications_screen.dart';
import '../../features/more/presentation/profile_screen.dart';
import '../../features/more/presentation/reports_screen.dart';
import '../../features/more/presentation/settings_screen.dart';
import '../../features/more/presentation/support_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier();
  ref.listen<AuthState>(authControllerProvider, (_, _) => notifier.refresh());
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) async {
      final status = ref.read(authControllerProvider).status;
      final loc = state.matchedLocation;

      final isSplash = loc == '/splash';
      final isOnboarding = loc == '/onboarding';
      final isAuth = const {
        '/login',
        '/register',
        '/forgot-password',
        '/reset-password',
      }.contains(loc);

      // Still initialising — stay on splash
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return isSplash ? null : '/splash';
      }

      // Authenticated
      if (status == AuthStatus.authenticated) {
        final isAdmin = ref
                .read(authControllerProvider)
                .user
                ?.role
                .trim()
                .toLowerCase() ==
            'admin';
        if (loc.startsWith('/admin') && !isAdmin) return '/home';
        // Keep administrator accounts in the admin console even when a
        // restored student route or another screen is still in the stack.
        if (isAdmin && !loc.startsWith('/admin')) return '/admin';
        // Send an authenticated administrator to the admin console rather
        // than the student shell after a new login or app launch.
        if (isSplash || isOnboarding || isAuth) {
          return isAdmin ? '/admin' : '/home';
        }
        return null;
      }

      // Unauthenticated — gate protected routes
      if (isSplash) {
        // Check if first-time user
        final prefs = await SharedPreferences.getInstance();
        final done = prefs.getBool('onboarding_done') ?? false;
        return done ? '/login' : '/onboarding';
      }

      final isProtected = loc.startsWith('/home') ||
          loc.startsWith('/add-') ||
          loc.startsWith('/transaction') ||
          loc.startsWith('/reports') ||
          loc.startsWith('/ai-assistant') ||
          loc.startsWith('/notifications') ||
          loc.startsWith('/profile') ||
          loc.startsWith('/settings') ||
          loc.startsWith('/change-password') ||
          loc.startsWith('/help') ||
          loc.startsWith('/feedback') ||
          loc.startsWith('/support') ||
          loc.startsWith('/about') ||
          loc.startsWith('/learn') ||
          loc.startsWith('/goals') ||
          loc.startsWith('/admin') ||
          loc == '/verify-email';

      if (isProtected) return '/login';
      return null;
    },
    routes: [
      // ── Pre-auth ─────────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
          path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
          path: '/forgot-password',
          builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(
          path: '/reset-password',
          builder: (_, _) => const ResetPasswordScreen()),
      GoRoute(
          path: '/verify-email',
          builder: (_, _) => const VerifyEmailScreen()),

      // ── Main shell ───────────────────────────────────────────────
      GoRoute(path: '/home', builder: (_, _) => const PennyPalShell()),

      // ── Transaction flows ────────────────────────────────────────
      GoRoute(
          path: '/add-expense',
          builder: (_, _) => const AddExpenseScreen()),
      GoRoute(
          path: '/add-income',
          builder: (_, _) => const AddIncomeScreen()),
      GoRoute(
        path: '/transaction-detail',
        builder: (_, state) {
          final tx = state.extra as FinanceTransaction?;
          if (tx != null) {
            return TransactionDetailScreen(transaction: tx);
          }
          return const _TransactionDetailFallback();
        },
      ),

      // ── More screens ─────────────────────────────────────────────
      GoRoute(
          path: '/reports', builder: (_, _) => const ReportsScreen()),
      GoRoute(
          path: '/ai-assistant',
          builder: (_, _) => const AiAssistantScreen()),
      GoRoute(
          path: '/notifications',
          builder: (_, _) => const NotificationsScreen()),
      GoRoute(
          path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(
          path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(
          path: '/change-password',
          builder: (_, _) => const ChangePasswordScreen()),
      GoRoute(path: '/help', builder: (_, _) => const HelpScreen()),
      GoRoute(
          path: '/feedback', builder: (_, _) => const FeedbackScreen()),
      GoRoute(
          path: '/support', builder: (_, _) => const SupportScreen()),
      GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),

      // ── Learning & Goals ─────────────────────────────────────────
      GoRoute(
        path: '/learn',
        builder: (_, _) => const LearnScreen(),
      ),
      GoRoute(
        path: '/learn/:slug',
        builder: (_, state) =>
            ArticleDetailScreen(slug: state.pathParameters['slug']),
      ),
      GoRoute(
        path: '/goals',
        builder: (_, _) => const PlanScreen(),
      ),
      GoRoute(path: '/budget', builder: (_, _) => const PlanScreen()),
      GoRoute(path: '/savings', builder: (_, _) => const PlanScreen()),

      // ── Admin ────────────────────────────────────────────────────
      GoRoute(
          path: '/admin',
          builder: (_, _) => const AdminDashboardScreen()),
    ],
  );
});

/// Fallback shown when navigating to /transaction-detail without a transaction.
class _TransactionDetailFallback extends StatelessWidget {
  const _TransactionDetailFallback();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        title: const Text(
          'Transaction Detail',
          style: TextStyle(
            color: PennyPalColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: PennyPalColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: const Center(
                  child: Icon(
                    Icons.receipt_long,
                    size: 30,
                    color: PennyPalColors.gray,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No transaction selected',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: PennyPalColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Go back and select a transaction from the list to view its details.',
                style: TextStyle(fontSize: 14, color: PennyPalColors.gray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
