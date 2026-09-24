import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/dashboard/presentation/penny_pal_shell.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/providers/auth_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier();
  ref.listen<AuthState>(authControllerProvider, (_, _) => notifier.refresh());
  ref.onDispose(notifier.dispose);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isAuthPage = {
        '/login',
        '/register',
        '/forgot-password',
        '/reset-password',
      }.contains(location);
      final protected = {'/home', '/verify-email', '/admin'}.contains(location);
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return isSplash ? null : '/splash';
      }
      if (status == AuthStatus.authenticated) {
        if (location == '/admin' && ref.read(authControllerProvider).user?.role != 'admin') return '/home';
        return (isSplash || isAuthPage) ? '/home' : null;
      }
      if (protected || isSplash) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(path: '/home', builder: (_, _) => const PennyPalShell()),
      GoRoute(path: '/admin', builder: (_, _) => const AdminDashboardScreen()),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
