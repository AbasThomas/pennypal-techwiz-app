import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:bootstrap_flutter/features/auth/data/models/auth_user.dart';
import 'package:bootstrap_flutter/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:bootstrap_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bootstrap_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:bootstrap_flutter/core/theme/app_theme.dart';
import 'package:bootstrap_flutter/features/auth/providers/auth_providers.dart';

class _FakeGateway implements AuthGateway {
  String? lastEmail;
  String? lastPassword;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    return AuthUser(id: 'u1', email: email);
  }

  @override
  Future<AuthUser> register(Map<String, dynamic> data) async =>
      AuthUser(id: 'u1', email: (data['email'] ?? '').toString());

  @override
  Future<AuthUser?> restoreSession() async => null;

  @override
  Future<void> logout() async {}
}

void main() {
  _goldenMain();
  final errors = <FlutterErrorDetails>[];

  setUp(() {
    errors.clear();
    final original = FlutterError.onError;
    FlutterError.onError = (details) => errors.add(details);
    addTearDown(() => FlutterError.onError = original);
  });

  testWidgets('login revamp: renders, sizes, validates, navigates', (
    tester,
  ) async {
    // Wide/tall viewport: the test font (Ahem) gives every glyph a full em
    // square, so text measures far wider than with real fonts.
    tester.view.physicalSize = const Size(720, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final gateway = _FakeGateway();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const LoginScreen()),
        GoRoute(
          path: '/register',
          builder: (_, _) => const Scaffold(body: Text('REGISTER_ROUTE')),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, _) => const Scaffold(body: Text('FORGOT_ROUTE')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => AuthController(gateway)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // Real asset I/O for the Lottie file.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }

    // Structure
    expect(find.text('PennyPal'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Lottie loaded (no error placeholder) and is bigger than before (240).
    expect(find.byType(ErrorWidget), findsNothing);
    final lottie = find.byType(LottieBuilder);
    expect(lottie, findsOneWidget);
    expect(tester.getSize(lottie), const Size(240, 240));

    // Empty submit runs validators instead of crashing.
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);

    // Password visibility toggle.
    final pwdField = find.byType(TextFormField).at(1);
    final pwdEditable = find.descendant(
      of: pwdField,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(pwdEditable).obscureText, isTrue);
    await tester.tap(
      find.descendant(of: pwdField, matching: find.byType(IconButton)),
    );
    await tester.pump();
    expect(tester.widget<EditableText>(pwdEditable).obscureText, isFalse);

    // Navigation links.
    await tester.tap(find.text('Forgot password?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('FORGOT_ROUTE'), findsOneWidget);

    router.go('/');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Create an account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('REGISTER_ROUTE'), findsOneWidget);

    // Successful submit reaches the auth controller with trimmed credentials.
    router.go('/');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      '  ada@example.com  ',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(gateway.lastEmail, 'ada@example.com');
    expect(gateway.lastPassword, 'secret123');

    expect(
      errors,
      isEmpty,
      reason: errors.map((e) => e.toString()).join('\n---\n'),
    );
  });
}

class _GoldenHarness extends StatelessWidget {
  const _GoldenHarness();

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      authControllerProvider.overrideWith((ref) => AuthController(_FakeGateway())),
    ],
    child: MaterialApp(
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    ),
  );
}

void _goldenMain() {
  testWidgets('golden snapshot', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const _GoldenHarness());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('_login_golden.png'),
    );
  });
}
