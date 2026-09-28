import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/storage/preferences_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/finance_providers.dart';
import '../../auth/providers/auth_providers.dart';

// ── Persistent settings state ────────────────────────────────────────────────


class AppSettings {
  AppSettings({
    required this.themeMode,
    required this.notifTransactions,
    required this.notifBudgets,
    required this.notifGoals,
    required this.reminderDaily,
    required this.reminderTime,
  });

  final String themeMode;
  final bool notifTransactions;
  final bool notifBudgets;
  final bool notifGoals;
  final bool reminderDaily;
  final String reminderTime;

  AppSettings copyWith({
    String? themeMode,
    bool? notifTransactions,
    bool? notifBudgets,
    bool? notifGoals,
    bool? reminderDaily,
    String? reminderTime,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notifTransactions: notifTransactions ?? this.notifTransactions,
      notifBudgets: notifBudgets ?? this.notifBudgets,
      notifGoals: notifGoals ?? this.notifGoals,
      reminderDaily: reminderDaily ?? this.reminderDaily,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

class _SettingsNotifier extends StateNotifier<AppSettings> {
  _SettingsNotifier(this._prefs)
      : super(
          AppSettings(
            themeMode: _prefs?.getString('prefs_theme') ?? 'dark',
            notifTransactions:
                _prefs?.getBool('prefs_notif_tx') ?? true,
            notifBudgets:
                _prefs?.getBool('prefs_notif_budget') ?? true,
            notifGoals:
                _prefs?.getBool('prefs_notif_goals') ?? true,
            reminderDaily:
                _prefs?.getBool('prefs_reminder') ?? false,
            reminderTime:
                _prefs?.getString('prefs_reminder_time') ?? '20:00',
          ),
        );

  final SharedPreferences? _prefs;

  Future<void> update(AppSettings s) async {
    state = s;
    final p = _prefs;
    if (p == null) return;
    await Future.wait([
      p.setString('prefs_theme', s.themeMode),
      p.setBool('prefs_notif_tx', s.notifTransactions),
      p.setBool('prefs_notif_budget', s.notifBudgets),
      p.setBool('prefs_notif_goals', s.notifGoals),
      p.setBool('prefs_reminder', s.reminderDaily),
      p.setString('prefs_reminder_time', s.reminderTime),
    ]);
  }

  void tap() => HapticFeedback.selectionClick();
  void impact(bool heavy) => heavy
      ? HapticFeedback.mediumImpact()
      : HapticFeedback.lightImpact();
}

final _settingsProvider =
    StateNotifierProvider<_SettingsNotifier, AppSettings>(
  (ref) => throw UnimplementedError(
    '_settingsProvider must be overridden with a _SettingsNotifier instance.',
  ),
);

// ── Settings screen ──────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<SharedPreferences>? _prefsFuture;

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? PennyPalColors.dangerSurface : PennyPalColors.elevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: error ? PennyPalColors.danger : PennyPalColors.border),
        ),
        content: Text(
          msg,
          style: TextStyle(
            color: error ? PennyPalColors.danger : PennyPalColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _prefsFuture ??= SharedPreferences.getInstance();
    return FutureBuilder<SharedPreferences>(
      future: _prefsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: PennyPalColors.black,
            appBar: AppBar(
              backgroundColor: PennyPalColors.black,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: PennyPalColors.white),
              title: const Text(
                'App Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: PennyPalColors.white,
                ),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(
                color: PennyPalColors.white,
              ),
            ),
          );
        }
        final prefs = snapshot.data!;
        return ProviderScope(
          overrides: [
            _settingsProvider.overrideWith(
              (ref) => _SettingsNotifier(prefs),
            ),
          ],
          child: _SettingsView(
            onSnack: _snack,
            onLogout: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        );
      },
    );
  }
}

class _SettingsView extends ConsumerWidget {
  const _SettingsView({
    required this.onSnack,
    required this.onLogout,
  });
  final void Function(String, {bool error}) onSnack;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(_settingsProvider);
    final notifier = ref.read(_settingsProvider.notifier);
    final user = ref.watch(currentUserProvider);

    void update(AppSettings next) {
      notifier.update(next);
    }

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: PennyPalColors.white),
        title: const Text(
          'App Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PennyPalColors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset to defaults',
            onPressed: () => _confirmReset(context, ref, notifier),
            icon: const AppIcon(
              AppIcons.refresh,
              size: 19,
              color: PennyPalColors.gray,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Profile summary banner
          _ProfileCard(
            name: user?.fullName ?? 'Student',
            email: user?.email ?? '',
            role: user?.role ?? 'student',
            onTap: () {
              notifier.tap();
              context.push('/profile');
            },
          ),
          const SizedBox(height: 24),

          // NOTIFICATIONS
          const _SectionLabel('Notifications'),
          const SizedBox(height: 8),
          _Group(
            items: [
              _SwitchRow(
                icon: AppIcons.notification,
                label: 'Transaction Alerts',
                subtitle: 'When income or expense is recorded',
                value: s.notifTransactions,
                onChanged: (v) {
                  final next = s.copyWith(notifTransactions: v);
                  update(next);
                  _syncAlertPreferences(ref, next);
                  onSnack(v ? 'Transaction alerts enabled' : 'Transaction alerts muted');
                },
              ),
              _SwitchRow(
                icon: AppIcons.target,
                label: 'Budget Alerts',
                subtitle: 'When spending nears or exceeds limits',
                value: s.notifBudgets,
                onChanged: (v) {
                  final next = s.copyWith(notifBudgets: v);
                  update(next);
                  _syncAlertPreferences(ref, next);
                  onSnack(v ? 'Budget alerts enabled' : 'Budget alerts muted');
                },
              ),
              _SwitchRow(
                icon: AppIcons.piggyBank,
                label: 'Savings Goal Updates',
                subtitle: 'Progress milestones and completions',
                value: s.notifGoals,
                onChanged: (v) {
                  final next = s.copyWith(notifGoals: v);
                  update(next);
                  _syncAlertPreferences(ref, next);
                  onSnack(v ? 'Goal updates enabled' : 'Goal updates muted');
                },
              ),
              _SwitchRow(
                icon: AppIcons.calendar,
                label: 'Daily Entry Reminder',
                subtitle: 'Remind me to log my expenses',
                value: s.reminderDaily,
                onChanged: (v) async {
                  final next = s.copyWith(reminderDaily: v);
                  update(next);
                  _syncAlertPreferences(ref, next);
                  if (v) {
                    final allowed =
                        await NotificationService.instance.requestPermission();
                    if (!allowed) {
                      final reverted = ref
                          .read(_settingsProvider)
                          .copyWith(reminderDaily: false);
                      update(reverted);
                      _syncAlertPreferences(ref, reverted);
                      onSnack(
                        'Allow notifications in your phone settings for reminders to appear.',
                        error: true,
                      );
                      return;
                    }
                    await NotificationService.instance
                        .scheduleDailyReminder(next.reminderTime);
                    onSnack('Daily reminder set for ${next.reminderTime}');
                  } else {
                    await NotificationService.instance.cancelDailyReminder();
                    onSnack('Daily reminder turned off');
                  }
                },
              ),
              if (s.reminderDaily)
                _SettingRow(
                  icon: AppIcons.invoice,
                  label: '  Reminder Time',
                  value: s.reminderTime,
                  onTap: () async {
                    notifier.tap();
                    final parts = s.reminderTime.split(':');
                    final now = TimeOfDay(
                      hour: int.tryParse(parts.first) ?? 20,
                      minute: int.tryParse(parts.last) ?? 0,
                    );
                    final t = await showTimePicker(
                      context: context,
                      initialTime: now,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: PennyPalColors.white,
                              onPrimary: PennyPalColors.black,
                              surface: PennyPalColors.surface,
                              onSurface: PennyPalColors.white,
                            ),
                            dialogTheme: const DialogThemeData(
                              backgroundColor: PennyPalColors.surface,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (t != null) {
                      final hm =
                          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                      final next = s.copyWith(reminderTime: hm);
                      update(next);
                      _syncAlertPreferences(ref, next);
                      await NotificationService.instance
                          .scheduleDailyReminder(hm);
                      onSnack('Reminder rescheduled for $hm');
                    }
                  },
                ),
              _SettingRow(
                icon: AppIcons.notification,
                label: 'Notification Permissions',
                subtitle: 'Check access and send a test alert',
                value: '',
                onTap: () async {
                  notifier.tap();
                  await _showPermissionsSheet(context, onSnack);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // SECURITY
          const _SectionLabel('Security'),
          const SizedBox(height: 8),
          _Group(
            items: [
              _SettingRow(
                icon: AppIcons.lockCheck,
                label: 'Change Password',
                subtitle: 'Update your sign-in password',
                value: '',
                onTap: () {
                  notifier.tap();
                  context.push('/change-password');
                },
              ),
              _SettingRow(
                icon: AppIcons.shield,
                label: 'Privacy & Permissions',
                subtitle: 'What PennyPal stores and how to control it',
                value: '',
                onTap: () {
                  notifier.tap();
                  _showPrivacySheet(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ABOUT & SUPPORT
          const _SectionLabel('About & Support'),
          const SizedBox(height: 8),
          _Group(
            items: [
              _SettingRow(
                icon: AppIcons.info,
                label: 'About PennyPal',
                value: 'v1.0.0',
                onTap: () {
                  notifier.tap();
                  context.push('/about');
                },
              ),
              _SettingRow(
                icon: AppIcons.support,
                label: 'Contact Support',
                value: '',
                onTap: () {
                  notifier.tap();
                  context.push('/support');
                },
              ),
              _SettingRow(
                icon: AppIcons.star,
                label: 'Rate the App',
                subtitle: 'Tell us how PennyPal is working for you',
                value: '',
                onTap: () {
                  notifier.tap();
                  _showRatingSheet(context, ref, onSnack);
                },
              ),
              _SettingRow(
                icon: AppIcons.bulb,
                label: 'Send Feedback',
                value: '',
                onTap: () {
                  notifier.tap();
                  context.push('/feedback');
                },
              ),
              _SettingRow(
                icon: AppIcons.help,
                label: 'Help & FAQs',
                subtitle: 'Answers to common questions',
                value: '',
                onTap: () {
                  notifier.tap();
                  context.push('/help');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // DANGER ZONE: LOG OUT
          _Group(
            items: [
              _SettingRow(
                icon: AppIcons.logout,
                label: 'Log Out',
                value: '',
                destructive: true,
                showChevron: false,
                onTap: () => _confirmLogout(context, onLogout),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Dialog helpers ────────────────────────────────────────────────────────

  Future<void> _confirmReset(
    BuildContext context,
    WidgetRef ref,
    _SettingsNotifier notifier,
  ) async {
    notifier.impact(true);
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ConfirmDialog(
        title: 'Reset Settings?',
        body:
            'This will restore all app settings to their default values. Your transactions, budgets and goals will NOT be affected.',
        confirmText: 'Reset',
        danger: true,
      ),
    );
    if (r == true) {
      await ref.read(appCurrencyProvider.notifier).set(AppCurrency.naira);
      await notifier.update(AppSettings(
        themeMode: 'dark',
        notifTransactions: true,
        notifBudgets: true,
        notifGoals: true,
        reminderDaily: false,
        reminderTime: '20:00',
      ));
      await NotificationService.instance.cancelDailyReminder();
      await NotificationService.instance.syncPreferences(
        transactions: true,
        budgets: true,
        goals: true,
        reminder: false,
        reminderTime: '20:00',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: PennyPalColors.elevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: PennyPalColors.border),
            ),
            content: const Text(
              'All settings restored to defaults',
              style: TextStyle(
                color: PennyPalColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context, VoidCallback onOk) async {
    HapticFeedback.mediumImpact();
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ConfirmDialog(
        title: 'Log Out?',
        body: 'You will be signed out of your PennyPal account. You can sign back in any time.',
        confirmText: 'Log Out',
      ),
    );
    if (r == true) onOk();
  }
}

// ── Settings actions ────────────────────────────────────────────────────────

void _syncAlertPreferences(WidgetRef ref, AppSettings s) {
  NotificationService.instance.syncPreferences(
    transactions: s.notifTransactions,
    budgets: s.notifBudgets,
    goals: s.notifGoals,
    reminder: s.reminderDaily,
    reminderTime: s.reminderTime,
  );
}

Future<void> _showRatingSheet(
  BuildContext context,
  WidgetRef ref,
  void Function(String, {bool error}) onSnack,
) async {
  final result = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _RatingSheet(),
  );
  if (result == null) return;

  final uid = ref.read(currentUserProvider)?.id;
  if (uid == null) {
    onSnack('Sign in again to send your rating.', error: true);
    return;
  }
  try {
    await ref.read(financeRepositoryProvider).submitFeedback(uid, {
      'type': 'rating',
      'rating': result,
      'source': 'settings',
    });
    onSnack('Thanks for rating PennyPal $result/5!');
  } catch (_) {
    onSnack('Could not send your rating. Please try again.', error: true);
  }
}

Future<void> _showPermissionsSheet(
  BuildContext context,
  void Function(String, {bool error}) onSnack,
) async {
  final granted = await NotificationService.instance.permissionGranted();
  if (!context.mounted) return;
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _PermissionsSheet(granted: granted),
  );
  if (action == 'allow') {
    final ok = await NotificationService.instance.requestPermission();
    onSnack(
      ok
          ? 'Notifications are allowed on this device.'
          : 'Notifications are still blocked. Enable them in your phone settings.',
      error: !ok,
    );
  } else if (action == 'test') {
    final ok = await NotificationService.instance.showTestNotification();
    onSnack(
      ok
          ? 'Test notification sent — check your notification shade.'
          : 'Notifications are blocked. Allow them to receive alerts.',
      error: !ok,
    );
  }
}

void _showPrivacySheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _PrivacySheet(),
  );
}

// ── Sheets ──────────────────────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: PennyPalColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PennyPalColors.darkGray,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13.5,
                color: PennyPalColors.gray,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _RatingSheet extends StatefulWidget {
  const _RatingSheet();

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _stars = 0;

  static const _labels = {
    1: 'Needs work',
    2: 'Could be better',
    3: 'Decent',
    4: 'Great',
    5: 'Love it!',
  };

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Rate PennyPal',
      subtitle: _stars == 0
          ? 'How has your experience been so far?'
          : _labels[_stars]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _stars = i);
                  },
                  iconSize: 40,
                  icon: AppIcon(
                    i <= _stars ? AppIcons.star : AppIcons.starOff,
                    size: 36,
                    color: i <= _stars
                        ? PennyPalColors.white
                        : PennyPalColors.darkGray,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _stars == 0
                  ? null
                  : () => Navigator.of(context).pop(_stars),
              style: ElevatedButton.styleFrom(
                backgroundColor: PennyPalColors.white,
                foregroundColor: PennyPalColors.black,
                disabledBackgroundColor: PennyPalColors.darkGray,
                disabledForegroundColor: PennyPalColors.gray,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Submit Rating',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: PennyPalColors.gray,
              ),
              child: const Text(
                'Maybe later',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionsSheet extends StatelessWidget {
  const _PermissionsSheet({required this.granted});
  final bool granted;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Notification Permissions',
      subtitle:
          'PennyPal needs notification access to deliver alerts and your daily reminder.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PennyPalColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PennyPalColors.border),
            ),
            child: Row(
              children: [
                AppIcon(
                  granted ? AppIcons.check : AppIcons.warning,
                  size: 20,
                  color: granted
                      ? PennyPalColors.success
                      : PennyPalColors.danger,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    granted
                        ? 'Notifications are allowed on this device.'
                        : 'Notifications are blocked for PennyPal.',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: PennyPalColors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop('allow'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PennyPalColors.white,
                foregroundColor: PennyPalColors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                granted ? 'Re-check Permission' : 'Allow Notifications',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop('test'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PennyPalColors.white,
                side: const BorderSide(
                  color: PennyPalColors.border,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Send Test Notification',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet();

  static const _points = [
    (
      'What we store',
      'Your transactions, budgets, savings goals, profile details and notification '
          'preferences. Nothing else is collected.',
    ),
    (
      'Where it lives',
      'Data is stored in your private PennyPal cloud account (Google Firebase) and '
          'cached on this device. It is never sold or shared with advertisers.',
    ),
    (
      'Who can see it',
      'Only you. Each record is tied to your user ID and protected by database rules.',
    ),
    (
      'AI Assistant',
      'Your figures are sent only to generate an answer and are not used to train models.',
    ),
    (
      'Your controls',
      'Delete any transaction, budget or goal at any time. Delete your account from '
          'Profile → Account to erase everything permanently.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Privacy & Permissions',
      subtitle: 'A plain-English summary of how PennyPal handles your data.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final p in _points) ...[
            Text(
              p.$1,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              p.$2,
              style: const TextStyle(
                fontSize: 13,
                color: PennyPalColors.gray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/support');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: PennyPalColors.white,
                side: const BorderSide(
                  color: PennyPalColors.border,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Ask a Privacy Question',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile banner ──────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.role,
    required this.onTap,
  });
  final String name;
  final String email;
  final String role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [PennyPalColors.surface, PennyPalColors.nearBlack],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PennyPalColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: PennyPalColors.elevated,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: PennyPalColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: PennyPalColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      color: PennyPalColors.gray,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${role[0].toUpperCase()}${role.substring(1)}',
                    style: const TextStyle(
                      color: PennyPalColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const AppIcon(AppIcons.chevronRight, color: PennyPalColors.gray),
          ],
        ),
      ),
    );
  }
}

// ── Building blocks ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 2),
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

class _Group extends StatelessWidget {
  const _Group({required this.items});
  final List<Widget> items;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          return Column(
            children: [
              e.value,
              if (e.key < items.length - 1)
                const Divider(
                  height: 1,
                  indent: 60,
                  endIndent: 16,
                  color: PennyPalColors.mutedBorder,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingRow extends StatefulWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.subtitle,
    this.showChevron = true,
    this.destructive = false,
  });
  final List<List<dynamic>> icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final String? subtitle;
  final bool showChevron;
  final bool destructive;

  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final labelColor =
        widget.destructive ? PennyPalColors.danger : PennyPalColors.white;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.992 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.destructive
                      ? PennyPalColors.dangerSurface
                      : PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: AppIcon(
                    widget.icon,
                    color: widget.destructive
                        ? PennyPalColors.danger
                        : PennyPalColors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: labelColor,
                      ),
                    ),
                    if (widget.subtitle != null &&
                        widget.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: PennyPalColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.value.isNotEmpty) ...[
                  const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PennyPalColors.gray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (widget.showChevron) ...[
                  const SizedBox(width: 4),
                const AppIcon(
                  AppIcons.chevronRight,
                  color: PennyPalColors.muted,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final List<List<dynamic>> icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Center(
              child: AppIcon(icon, color: PennyPalColors.white, size: 16),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: PennyPalColors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: PennyPalColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: PennyPalColors.success.withValues(alpha: 0.6),
              activeThumbColor: PennyPalColors.white,
              inactiveTrackColor: PennyPalColors.elevated,
              inactiveThumbColor: PennyPalColors.gray,
              trackOutlineColor: const WidgetStatePropertyAll(
                PennyPalColors.mutedBorder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confirm dialog ──────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmText,
    this.danger = false,
  });
  final String title;
  final String body;
  final String confirmText;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: PennyPalColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: danger ? PennyPalColors.danger : PennyPalColors.border,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: danger
                  ? PennyPalColors.dangerSurface
                  : PennyPalColors.elevated,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: AppIcon(
                danger ? AppIcons.warning : AppIcons.help,
                size: 17,
                color: danger ? PennyPalColors.danger : PennyPalColors.gray,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: PennyPalColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        body,
        style: const TextStyle(
          color: PennyPalColors.lightGray,
          fontSize: 13.5,
          height: 1.45,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: PennyPalColors.gray, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                danger ? PennyPalColors.danger : PennyPalColors.white,
            foregroundColor:
                danger ? PennyPalColors.white : PennyPalColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
