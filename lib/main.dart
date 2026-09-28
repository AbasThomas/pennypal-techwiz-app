import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/storage/preferences_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/providers/auth_providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // API configuration falls back to the local Android-emulator URL.
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  await NotificationService.instance.init();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    NotificationService.instance.pendingRoute.addListener(_openPendingRoute);
  }

  @override
  void dispose() {
    NotificationService.instance.pendingRoute
        .removeListener(_openPendingRoute);
    super.dispose();
  }

  void _openPendingRoute() {
    final route = NotificationService.instance.pendingRoute.value;
    if (route == null) return;
    if (ref.read(authControllerProvider).status != AuthStatus.authenticated) {
      return;
    }
    NotificationService.instance.pendingRoute.value = null;
    ref.read(appRouterProvider).go(route);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (prev, next) {
      final wasAuthed = prev?.status == AuthStatus.authenticated;
      final isAuthed = next.status == AuthStatus.authenticated;
      if (!wasAuthed && isAuthed) {
        final uid = next.user?.id;
        if (uid != null) {
          NotificationService.instance.registerDevice(uid);
          NotificationService.instance.ensureDailyReminder();
        }
        // Navigate directly on both fresh sign-in and restored sessions.
        // This also covers a router that was already showing the student
        // shell when Firestore finished loading the user's role.
        final normalizedRole = next.user?.role.trim().toLowerCase();
        final destination = normalizedRole == 'admin' ? '/admin' : '/home';
        // Wait until MaterialApp.router has completed the current frame before
        // changing location; login status updates can arrive during routing.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          debugPrint(
            'PennyPal navigation: role=$normalizedRole, route=$destination',
          );
          ref.read(appRouterProvider).go(destination);
        });
      } else if (wasAuthed && !isAuthed) {
        final uid = prev?.user?.id;
        if (uid != null) NotificationService.instance.unregisterDevice(uid);
      }
      _openPendingRoute();
    });

    return MaterialApp.router(
      title: 'PennyPal',
      theme: AppTheme.lightTheme,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
