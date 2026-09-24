import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
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
import '../../features/more/presentation/about_screen.dart';
import '../../features/more/presentation/ai_assistant_screen.dart';
import '../../features/more/presentation/feedback_screen.dart';
import '../../features/more/presentation/notifications_screen.dart';
import '../../features/more/presentation/profile_screen.dart';
import '../../features/more/presentation/reports_screen.dart';
import '../../features/more/presentation/support_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier();
  ref.listen<AuthState>(authControllerProvider, (_, __) => notifier.refresh());
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
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
        final isAdmin =
            ref.read(authControllerProvider).user?.role == 'admin';
        if (loc == '/admin' && !isAdmin) return '/home';
        if (isSplash || isOnboarding || isAuth) return '/home';
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
          loc.startsWith('/feedback') ||
          loc.startsWith('/support') ||
          loc.startsWith('/about') ||
          loc.startsWith('/learn/') ||
          loc == '/admin' ||
          loc == '/verify-email';

      if (isProtected) return '/login';
      return null;
    },
    routes: [
      // ── Pre-auth ─────────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
          path: '/reset-password',
          builder: (_, __) => const ResetPasswordScreen()),
      GoRoute(
          path: '/verify-email',
          builder: (_, __) => const VerifyEmailScreen()),

      // ── Main shell ───────────────────────────────────────────────
      GoRoute(path: '/home', builder: (_, __) => const PennyPalShell()),

      // ── Transaction flows ────────────────────────────────────────
      GoRoute(
          path: '/add-expense',
          builder: (_, __) => const AddExpenseScreen()),
      GoRoute(
          path: '/add-income',
          builder: (_, __) => const AddIncomeScreen()),
      GoRoute(
          path: '/transaction-detail',
          builder: (_, __) => const _TransactionDetailPlaceholder()),

      // ── More screens ─────────────────────────────────────────────
      GoRoute(
          path: '/reports', builder: (_, __) => const ReportsScreen()),
      GoRoute(
          path: '/ai-assistant',
          builder: (_, __) => const AiAssistantScreen()),
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen()),
      GoRoute(
          path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
          path: '/feedback', builder: (_, __) => const FeedbackScreen()),
      GoRoute(
          path: '/support', builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),

      // ── Learning ─────────────────────────────────────────────────
      GoRoute(
        path: '/learn/:slug',
        builder: (_, state) =>
            ArticleDetailScreen(slug: state.pathParameters['slug']),
      ),

      // ── Admin ────────────────────────────────────────────────────
      GoRoute(
          path: '/admin',
          builder: (_, __) => const AdminDashboardScreen()),
    ],
  );
});

/// Placeholder until a full transaction detail screen is built.
class _TransactionDetailPlaceholder extends StatelessWidget {
  const _TransactionDetailPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Detail'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: const Center(child: Text('Transaction detail coming soon.')),
    );
  }
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
