import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../auth/providers/auth_providers.dart';

// ── Persistent settings state ────────────────────────────────────────────────


class AppSettings {
  AppSettings({
    required this.currencySymbol,
    required this.currencyCode,
    required this.themeMode,
    required this.notifTransactions,
    required this.notifBudgets,
    required this.notifGoals,
    required this.reminderDaily,
    required this.reminderTime,
  });

  final String currencySymbol;
  final String currencyCode;
  final String themeMode;
  final bool notifTransactions;
  final bool notifBudgets;
  final bool notifGoals;
  final bool reminderDaily;
  final String reminderTime;

  AppSettings copyWith({
    String? currencySymbol,
    String? currencyCode,
    String? themeMode,
    bool? notifTransactions,
    bool? notifBudgets,
    bool? notifGoals,
    bool? reminderDaily,
    String? reminderTime,
  }) {
    return AppSettings(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
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
            currencySymbol:
                _prefs?.getString('prefs_currency_symbol') ?? '\u20A6',
            currencyCode:
                _prefs?.getString('prefs_currency_code') ?? 'NGN',
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
      p.setString('prefs_currency_symbol', s.currencySymbol),
      p.setString('prefs_currency_code', s.currencyCode),
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
            onPressed: () => _confirmReset(context, notifier),
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
                  notifier.tap();
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
                  notifier.tap();
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
                onChanged: (v) => update(s.copyWith(notifTransactions: v)),
              ),
              _SwitchRow(
                icon: AppIcons.target,
                label: 'Budget Alerts',
                subtitle: 'When spending nears or exceeds limits',
                value: s.notifBudgets,
                onChanged: (v) => update(s.copyWith(notifBudgets: v)),
              ),
              _SwitchRow(
                icon: AppIcons.piggyBank,
                label: 'Savings Goal Updates',
                subtitle: 'Progress milestones and completions',
                value: s.notifGoals,
                onChanged: (v) => update(s.copyWith(notifGoals: v)),
              ),
              _SwitchRow(
                icon: AppIcons.calendar,
                label: 'Daily Entry Reminder',
                subtitle: 'Remind me to log my expenses',
                value: s.reminderDaily,
                onChanged: (v) => update(s.copyWith(reminderDaily: v)),
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
              _SettingRow(
                icon: AppIcons.lockCheck,
                label: 'Change Password',
                value: '',
                onTap: () {
                  notifier.tap();
                  onSnack('Change password coming soon');
                },
              ),
              _SettingRow(
                icon: AppIcons.shield,
                label: 'Privacy & Permissions',
                value: '',
                onTap: () {
                  notifier.tap();
                  onSnack('Privacy center coming soon');
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
                value: '',
                onTap: () {
                  notifier.tap();
                  onSnack('Thanks! Rate dialog coming soon');
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
                value: '',
                onTap: () {
                  notifier.tap();
                  onSnack('Help center coming soon');
                },
              ),
              _SettingRow(
                icon: AppIcons.security,
                label: 'Terms of Service',
                value: '',
                onTap: () {
                  notifier.tap();
                  onSnack('Terms coming soon');
                },
              ),
              _SettingRow(
                icon: AppIcons.lock,
                label: 'Privacy Policy',
                value: '',
                onTap: () {
                  notifier.tap();
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
        ],
      ),
    );
  }

  // ── Dialog helpers ────────────────────────────────────────────────────────

  Future<void> _confirmReset(
    BuildContext context,
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
      await notifier.update(AppSettings(
        currencySymbol: '\u20A6',
        currencyCode: 'NGN',
        themeMode: 'dark',
        notifTransactions: true,
        notifBudgets: true,
        notifGoals: true,
        reminderDaily: false,
        reminderTime: '20:00',
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
