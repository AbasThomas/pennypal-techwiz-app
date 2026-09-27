import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../auth/providers/auth_providers.dart';

// ── Persistent settings state ────────────────────────────────────────────────

final _prefsProvider = Provider<SharedPreferences?>((_) => null);

class AppSettings {
  AppSettings({
    required this.currencySymbol,
    required this.currencyCode,
    required this.dateFormat,
    required this.themeMode,
    required this.hapticEnabled,
    required this.notifTransactions,
    required this.notifBudgets,
    required this.notifGoals,
    required this.notifTips,
    required this.reminderDaily,
    required this.reminderTime,
    required this.secureApp,
    required this.biometricEnabled,
    required this.autoBackup,
    required this.analyticsEnabled,
    required this.decimalPlaces,
    required this.firstDayOfWeek,
    required this.groupByCategory,
    required this.includePendingInReports,
  });

  final String currencySymbol;
  final String currencyCode;
  final String dateFormat;
  final String themeMode;
  final bool hapticEnabled;
  final bool notifTransactions;
  final bool notifBudgets;
  final bool notifGoals;
  final bool notifTips;
  final bool reminderDaily;
  final String reminderTime;
  final bool secureApp;
  final bool biometricEnabled;
  final bool autoBackup;
  final bool analyticsEnabled;
  final int decimalPlaces;
  final int firstDayOfWeek;
  final bool groupByCategory;
  final bool includePendingInReports;

  AppSettings copyWith({
    String? currencySymbol,
    String? currencyCode,
    String? dateFormat,
    String? themeMode,
    bool? hapticEnabled,
    bool? notifTransactions,
    bool? notifBudgets,
    bool? notifGoals,
    bool? notifTips,
    bool? reminderDaily,
    String? reminderTime,
    bool? secureApp,
    bool? biometricEnabled,
    bool? autoBackup,
    bool? analyticsEnabled,
    int? decimalPlaces,
    int? firstDayOfWeek,
    bool? groupByCategory,
    bool? includePendingInReports,
  }) {
    return AppSettings(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      dateFormat: dateFormat ?? this.dateFormat,
      themeMode: themeMode ?? this.themeMode,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      notifTransactions: notifTransactions ?? this.notifTransactions,
      notifBudgets: notifBudgets ?? this.notifBudgets,
      notifGoals: notifGoals ?? this.notifGoals,
      notifTips: notifTips ?? this.notifTips,
      reminderDaily: reminderDaily ?? this.reminderDaily,
      reminderTime: reminderTime ?? this.reminderTime,
      secureApp: secureApp ?? this.secureApp,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoBackup: autoBackup ?? this.autoBackup,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      groupByCategory: groupByCategory ?? this.groupByCategory,
      includePendingInReports:
          includePendingInReports ?? this.includePendingInReports,
    );
  }
}

class _SettingsNotifier extends StateNotifier<AppSettings> {
  _SettingsNotifier(this._prefs)
      : super(
          AppSettings(
            currencySymbol:
                _prefs?.getString('prefs_currency_symbol') ?? '\u20A6',
            currencyCode:
                _prefs?.getString('prefs_currency_code') ?? 'NGN',
            dateFormat:
                _prefs?.getString('prefs_date_format') ?? 'dd MMM yyyy',
            themeMode: _prefs?.getString('prefs_theme') ?? 'dark',
            hapticEnabled:
                _prefs?.getBool('prefs_haptic') ?? true,
            notifTransactions:
                _prefs?.getBool('prefs_notif_tx') ?? true,
            notifBudgets:
                _prefs?.getBool('prefs_notif_budget') ?? true,
            notifGoals:
                _prefs?.getBool('prefs_notif_goals') ?? true,
            notifTips:
                _prefs?.getBool('prefs_notif_tips') ?? false,
            reminderDaily:
                _prefs?.getBool('prefs_reminder') ?? false,
            reminderTime:
                _prefs?.getString('prefs_reminder_time') ?? '20:00',
            secureApp: _prefs?.getBool('prefs_secure') ?? false,
            biometricEnabled:
                _prefs?.getBool('prefs_biometric') ?? false,
            autoBackup:
                _prefs?.getBool('prefs_auto_backup') ?? true,
            analyticsEnabled:
                _prefs?.getBool('prefs_analytics') ?? true,
            decimalPlaces:
                _prefs?.getInt('prefs_decimals') ?? 0,
            firstDayOfWeek:
                _prefs?.getInt('prefs_first_day') ?? 1,
            groupByCategory:
                _prefs?.getBool('prefs_group_cat') ?? true,
            includePendingInReports:
                _prefs?.getBool('prefs_pending_reports') ?? false,
          ),
        );

  final SharedPreferences? _prefs;

  Future<void> update(AppSettings s) async {
    state = s;
    final p = _prefs;
    if (p == null) return;
    await Future.wait([
      p.setString('prefs_currency_symbol', s.currencySymbol),
      p.setString('prefs_currency_code', s.currencyCode),
      p.setString('prefs_date_format', s.dateFormat),
      p.setString('prefs_theme', s.themeMode),
      p.setBool('prefs_haptic', s.hapticEnabled),
      p.setBool('prefs_notif_tx', s.notifTransactions),
      p.setBool('prefs_notif_budget', s.notifBudgets),
      p.setBool('prefs_notif_goals', s.notifGoals),
      p.setBool('prefs_notif_tips', s.notifTips),
      p.setBool('prefs_reminder', s.reminderDaily),
      p.setString('prefs_reminder_time', s.reminderTime),
      p.setBool('prefs_secure', s.secureApp),
      p.setBool('prefs_biometric', s.biometricEnabled),
      p.setBool('prefs_auto_backup', s.autoBackup),
      p.setBool('prefs_analytics', s.analyticsEnabled),
      p.setInt('prefs_decimals', s.decimalPlaces),
      p.setInt('prefs_first_day', s.firstDayOfWeek),
      p.setBool('prefs_group_cat', s.groupByCategory),
      p.setBool('prefs_pending_reports', s.includePendingInReports),
    ]);
  }

  void tap(bool haptic) {
    if (haptic && state.hapticEnabled) HapticFeedback.selectionClick();
  }

  void impact(bool heavy) {
    if (state.hapticEnabled) {
      heavy
          ? HapticFeedback.mediumImpact()
          : HapticFeedback.lightImpact();
    }
  }
}

final _settingsProvider =
    StateNotifierProvider<_SettingsNotifier, AppSettings>(
  (ref) {
    final prefs = ref.watch(_prefsProvider);
    return _SettingsNotifier(prefs);
  },
  dependencies: [_prefsProvider],
);

// ── Settings screen ──────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _prefs = p);
  }

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
    if (_prefs == null) {
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
    return ProviderScope(
      overrides: [_prefsProvider.overrideWithValue(_prefs)],
      child: _SettingsView(
        onSnack: _snack,
        onLogout: () {
          ref.read(authControllerProvider.notifier).logout();
        },
      ),
    );
  }
}

class _SettingsView extends ConsumerWidget {
  const _SettingsView({required this.onSnack, required this.onLogout});
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
            onPressed: () => _confirmReset(context, notifier, update),
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
              notifier.tap(true);
              context.push('/profile');
            },
          ),
          const SizedBox(height: 24),

          // APPEARANCE
          const _SectionLabel('Appearance'),
          const SizedBox(height: 8),
          _Group(
            items: [
              _SettingRow(
                icon: AppIcons.settings,
                label: 'Theme Mode',
                subtitle: 'Light, Dark, or System default',
                value: s.themeMode == 'light'
                    ? 'Light'
                    : s.themeMode == 'dark'
                        ? 'Dark'
                        : 'System',
                onTap: () async {
                  notifier.tap(true);
                  final r = await _SingleOptionPicker.show(
                    context,
                    title: 'Theme Mode',
                    options: const ['Light', 'Dark', 'System'],
                    current: s.themeMode == 'light'
                        ? 'Light'
                        : s.themeMode == 'dark'
                            ? 'Dark'
                            : 'System',
                  );
                  if (r != null) {
                    update(
                      s.copyWith(
                        themeMode: r == 'Light'
                            ? 'light'
                            : r == 'Dark'
                                ? 'dark'
                                : 'system',
                      ),
                    );
                    onSnack('Theme updated');
                  }
                },
              ),
              _SettingRow(
                icon: AppIcons.wallet,
                label: 'Currency',
                subtitle: 'Symbol and code for amounts',
                value: '${s.currencySymbol}  ${s.currencyCode}',
                onTap: () async {
                  notifier.tap(true);
                  final r = await _CurrencyPicker.show(
                    context,
                    currentSymbol: s.currencySymbol,
                    currentCode: s.currencyCode,
                  );
                  if (r != null) {
                    update(
                      s.copyWith(currencySymbol: r.$1, currencyCode: r.$2),
                    );
                    onSnack('Currency updated to ${r.$2}');
                  }
                },
              ),
              _SettingRow(
                icon: AppIcons.calendar,
                label: 'Date Format',
                subtitle: 'How dates appear everywhere',
                value: s.dateFormat,
                onTap: () async {
                  notifier.tap(true);
                  final r = await _SingleOptionPicker.show(
                    context,
                    title: 'Date Format',
                    options: const [
                      'dd MMM yyyy',
                      'MMM dd, yyyy',
                      'dd/MM/yyyy',
                      'MM/dd/yyyy',
                      'yyyy-MM-dd',
                    ],
                    current: s.dateFormat,
                  );
                  if (r != null) {
                    update(s.copyWith(dateFormat: r));
                    onSnack('Date format updated');
                  }
                },
              ),
              _SettingRow(
                icon: AppIcons.money,
                label: 'Decimal Places',
                subtitle: 'Precision for money values',
                value: '${s.decimalPlaces}',
                onTap: () async {
                  notifier.tap(true);
                  final r = await _SingleOptionPicker.show(
                    context,
                    title: 'Decimal Places',
                    options: const ['0', '1', '2'],
                    current: '${s.decimalPlaces}',
                  );
                  if (r != null) {
                    update(s.copyWith(decimalPlaces: int.parse(r)));
                  }
                },
              ),
              _SettingRow(
                icon: AppIcons.calendar,
                label: 'First Day of Week',
                subtitle: 'For calendars and reports',
                value: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][
                    (s.firstDayOfWeek - 1).clamp(0, 6)],
                onTap: () async {
                  notifier.tap(true);
                  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday',
                      'Friday', 'Saturday', 'Sunday'];
                  final r = await _SingleOptionPicker.show(
                    context,
                    title: 'First Day of Week',
                    options: days,
                    current: days[(s.firstDayOfWeek - 1).clamp(0, 6)],
                  );
                  if (r != null) {
                    final idx = days.indexOf(r) + 1;
                    update(s.copyWith(firstDayOfWeek: idx));
                  }
                },
              ),
              _SwitchRow(
                icon: AppIcons.coins,
                label: 'Group by Category',
                subtitle: 'Group transactions in list views',
                value: s.groupByCategory,
                onChanged: (v) {
                  update(s.copyWith(groupByCategory: v));
                  notifier.tap(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

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
                  update(s.copyWith(notifTransactions: v));
                  notifier.tap(v);
                },
              ),
              _SwitchRow(
                icon: AppIcons.target,
                label: 'Budget Alerts',
                subtitle: 'When spending nears or exceeds limits',
                value: s.notifBudgets,
                onChanged: (v) {
                  update(s.copyWith(notifBudgets: v));
                  notifier.tap(v);
                },
              ),
              _SwitchRow(
                icon: AppIcons.piggyBank,
                label: 'Savings Goal Updates',
                subtitle: 'Progress milestones and completions',
                value: s.notifGoals,
                onChanged: (v) {
                  update(s.copyWith(notifGoals: v));
                  notifier.tap(v);
                },
              ),
              _SwitchRow(
                icon: AppIcons.bulb,
                label: 'Daily Financial Tips',
                subtitle: 'Short tips every morning',
                value: s.notifTips,
                onChanged: (v) {
                  update(s.copyWith(notifTips: v));
                  notifier.tap(v);
                },
              ),
              _SwitchRow(
                icon: AppIcons.calendar,
                label: 'Daily Entry Reminder',
                subtitle: 'Remind me to log my expenses',
                value: s.reminderDaily,
                onChanged: (v) {
                  update(s.copyWith(reminderDaily: v));
                  notifier.tap(v);
                },
              ),
              if (s.reminderDaily)
                _SettingRow(
                  icon: AppIcons.invoice,
                  label: '  Reminder Time',
                  value: s.reminderTime,
                  onTap: () async {
                    notifier.tap(true);
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
                      update(s.copyWith(reminderTime: hm));
                    }
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
              _SwitchRow(
                icon: AppIcons.lock,
                label: 'App Lock',
                subtitle: 'Require authentication to open the app',
                value: s.secureApp,
                onChanged: (v) {
                  update(s.copyWith(secureApp: v));
                  notifier.impact(v);
                },
              ),
              _SwitchRow(
                icon: AppIcons.security,
                label: 'Biometric Unlock',
                subtitle: 'Use fingerprint or face ID',
                value: s.biometricEnabled,
                onChanged: (v) {
                  update(s.copyWith(biometricEnabled: v));
                  notifier.tap(v);
                },
              ),
              _SettingRow(
                icon: AppIcons.lockCheck,
                label: 'Change Password',
                value: '',
                onTap: () {
                  notifier.tap(true);
                  onSnack('Change password coming soon');
                },
              ),
              _SettingRow(
                icon: AppIcons.creditCard,
                label: 'Connected Devices',
                value: '1 active',
                onTap: () {
                  notifier.tap(true);
                  onSnack('Session manager coming soon');
                },
              ),
              _SettingRow(
                icon: AppIcons.shield,
                label: 'Privacy & Permissions',
                value: '',
                onTap: () {
                  notifier.tap(true);
                  onSnack('Privacy center coming soon');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // DATA & BACKUP
          const _SectionLabel('Data & Backup'),
          const SizedBox(height: 8),
          _Group(
            items: [
              _SwitchRow(
                icon: AppIcons.refresh,
                label: 'Auto Cloud Backup',
                subtitle: 'Backup transactions to cloud daily',
                value: s.autoBackup,
                onChanged: (v) {
                  update(s.copyWith(autoBackup: v));
                  notifier.tap(v);
                },
              ),
              _SettingRow(
                icon: AppIcons.upload,
                label: 'Manual Backup Now',
                value: '',
                onTap: () {
                  notifier.impact(false);
                  onSnack('Backup started — this may take a moment');
                },
              ),
              _SettingRow(
                icon: AppIcons.download,
                label: 'Restore from Backup',
                value: '',
                onTap: () {
                  notifier.tap(true);
                  _confirmRestore(context, () => onSnack('Restore not yet available'));
                },
              ),
              _SettingRow(
                icon: AppIcons.coins,
                label: 'Export Transactions (CSV)',
                value: '',
                onTap: () {
                  notifier.impact(false);
                  onSnack('Exporting CSV… coming soon');
                },
              ),
              _SettingRow(
                icon: AppIcons.download,
                label: 'Export Reports (PDF)',
                value: '',
                onTap: () {
                  notifier.tap(true);
                  onSnack('PDF export coming soon');
                },
              ),
              _SettingRow(
                icon: AppIcons.delete,
                label: 'Clear Local Cache',
                value: '',
                destructive: true,
                onTap: () => _confirmClear(context, () {
                  onSnack('Local cache cleared');
                }),
              ),
              _SettingRow(
                icon: AppIcons.delete,
                label: 'Delete All My Data',
                value: '',
                destructive: true,
                onTap: () => _confirmDeleteAll(context, () {
                  onSnack(
                    'Please contact support to delete your account data',
                    error: true,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // PREFERENCES
          const _SectionLabel('Preferences'),
          const SizedBox(height: 8),
          _Group(
            items: [
              _SwitchRow(
                icon: AppIcons.coins,
                label: 'Haptic Feedback',
                subtitle: 'Vibrate on taps and actions',
                value: s.hapticEnabled,
                onChanged: (v) {
                  update(s.copyWith(hapticEnabled: v));
                  if (v) HapticFeedback.lightImpact();
                },
              ),
              _SwitchRow(
                icon: AppIcons.chartBar,
                label: 'Include Pending in Reports',
                subtitle: 'Include pending/uncleared entries',
                value: s.includePendingInReports,
                onChanged: (v) {
                  update(s.copyWith(includePendingInReports: v));
                  notifier.tap(v);
                },
              ),
              _SwitchRow(
                icon: AppIcons.chartBar,
                label: 'Share Usage Analytics',
                subtitle: 'Anonymous data to improve the app',
                value: s.analyticsEnabled,
                onChanged: (v) {
                  update(s.copyWith(analyticsEnabled: v));
                  notifier.tap(v);
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
                  notifier.tap(true);
                  context.push('/about');
                },
              ),
              _SettingRow(
                icon: AppIcons.support,
                label: 'Contact Support',
                value: '',
                onTap: () {
                  notifier.tap(true);
                  context.push('/support');
                },
              ),
              _SettingRow(
                icon: AppIcons.star,
                label: 'Rate the App',
                value: '',
                onTap: () {
                  notifier.tap(true);
                  onSnack('Thanks! Rate dialog coming soon');
                },
              ),
              _SettingRow(
                icon: AppIcons.bulb,
                label: 'Send Feedback',
                value: '',
                onTap: () {
                  notifier.tap(true);
                  context.push('/feedback');
                },
              ),
              _SettingRow(
                icon: AppIcons.help,
                label: 'Help & FAQs',
                value: '',
                onTap: () {
                  notifier.tap(true);
                  onSnack('Help center coming soon');
                },
              ),
              _SettingRow(
                icon: AppIcons.security,
                label: 'Terms of Service',
                value: '',
                onTap: () {
                  notifier.tap(true);
                  onSnack('Terms coming soon');
                },
              ),
              _SettingRow(
                icon: AppIcons.lock,
                label: 'Privacy Policy',
                value: '',
                onTap: () {
                  notifier.tap(true);
                  onSnack('Privacy policy coming soon');
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
          const SizedBox(height: 24),

          const Center(
            child: Text(
              'Made with \u2764\ufe0f for students',
              style: TextStyle(
                fontSize: 12,
                color: PennyPalColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialog helpers ────────────────────────────────────────────────────────

  Future<void> _confirmReset(
    BuildContext context,
    _SettingsNotifier notifier,
    void Function(AppSettings) update,
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
      await notifier.update(AppSettings(
        currencySymbol: '\u20A6',
        currencyCode: 'NGN',
        dateFormat: 'dd MMM yyyy',
        themeMode: 'dark',
        hapticEnabled: true,
        notifTransactions: true,
        notifBudgets: true,
        notifGoals: true,
        notifTips: false,
        reminderDaily: false,
        reminderTime: '20:00',
        secureApp: false,
        biometricEnabled: false,
        autoBackup: true,
        analyticsEnabled: true,
        decimalPlaces: 0,
        firstDayOfWeek: 1,
        groupByCategory: true,
        includePendingInReports: false,
      ));
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

  Future<void> _confirmRestore(BuildContext context, VoidCallback onOk) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ConfirmDialog(
        title: 'Restore from Backup?',
        body:
            'Restoring a backup will replace all current data on this device with the backed-up version. This cannot be undone.',
        confirmText: 'Restore',
        danger: true,
      ),
    );
    if (r == true) onOk();
  }

  Future<void> _confirmClear(BuildContext context, VoidCallback onOk) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ConfirmDialog(
        title: 'Clear Local Cache?',
        body:
            'Temporary cached images and files will be removed. This will free up storage and will not delete your saved data.',
        confirmText: 'Clear',
      ),
    );
    if (r == true) onOk();
  }

  Future<void> _confirmDeleteAll(BuildContext context, VoidCallback onOk) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ConfirmDialog(
        title: 'Delete All Your Data?',
        body:
            'This will permanently delete all transactions, budgets, savings goals and account data from PennyPal. This action is irreversible.',
        confirmText: 'Delete Everything',
        danger: true,
      ),
    );
    if (r == true) onOk();
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.destructive
                      ? PennyPalColors.dangerSurface
                      : PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: AppIcon(
                    widget.icon,
                    color: widget.destructive
                        ? PennyPalColors.danger
                        : PennyPalColors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 15,
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
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: PennyPalColors.gray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (widget.showChevron) ...[
                const SizedBox(width: 6),
                const AppIcon(
                  AppIcons.chevronRight,
                  color: PennyPalColors.muted,
                  size: 18,
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PennyPalColors.elevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AppIcon(icon, color: PennyPalColors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
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

// ── Picker modals ───────────────────────────────────────────────────────────

class _CurrencyPicker {
  static const currencies = [
    ('\u20A6', 'NGN', 'Nigerian Naira'),
    ('\$', 'USD', 'US Dollar'),
    ('\u20AC', 'EUR', 'Euro'),
    ('\u00A3', 'GBP', 'British Pound'),
    ('R', 'ZAR', 'South African Rand'),
    ('KSh', 'KES', 'Kenyan Shilling'),
    ('GH\u20B5', 'GHS', 'Ghanaian Cedi'),
    ('\u00A5', 'JPY', 'Japanese Yen'),
    ('\u20B9', 'INR', 'Indian Rupee'),
    ('C\$', 'CAD', 'Canadian Dollar'),
    ('AU\$', 'AUD', 'Australian Dollar'),
  ];

  static Future<(String, String)?> show(
    BuildContext context, {
    required String currentSymbol,
    required String currentCode,
  }) {
    return showModalBottomSheet<(String, String)>(
      context: context,
      backgroundColor: PennyPalColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PennyPalColors.muted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Select Currency',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PennyPalColors.white,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 320,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: currencies.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: PennyPalColors.mutedBorder,
                    ),
                    itemBuilder: (_, i) {
                      final c = currencies[i];
                      final selected = c.$2 == currentCode;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => Navigator.pop(ctx, (c.$1, c.$2)),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selected
                                ? PennyPalColors.successSurface
                                : PennyPalColors.elevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              c.$1,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: selected
                                    ? PennyPalColors.success
                                    : PennyPalColors.white,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          c.$3,
                          style: const TextStyle(
                            color: PennyPalColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          c.$2,
                          style: const TextStyle(
                            color: PennyPalColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        trailing: selected
                            ? const AppIcon(
                                AppIcons.check,
                                color: PennyPalColors.success,
                                size: 18,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SingleOptionPicker {
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String current,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: PennyPalColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PennyPalColors.muted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PennyPalColors.white,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: options.length > 6 ? 320 : null,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: PennyPalColors.mutedBorder,
                    ),
                    itemBuilder: (_, i) {
                      final o = options[i];
                      final selected = o == current;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => Navigator.pop(ctx, o),
                        leading: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? PennyPalColors.success
                                : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? PennyPalColors.success
                                  : PennyPalColors.mutedBorder,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Center(
                                  child: AppIcon(
                                    AppIcons.check,
                                    color: PennyPalColors.black,
                                    size: 12,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          o,
                          style: TextStyle(
                            color: selected
                                ? PennyPalColors.success
                                : PennyPalColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
