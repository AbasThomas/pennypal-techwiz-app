import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const alertsChannelId = 'pennypal_alerts';
const reminderChannelId = 'pennypal_daily_reminder';
const dailyReminderNotificationId = 90001;

/// Monochrome drawable in `android/app/src/main/res/drawable/`.
const _smallIcon = 'ic_stat_pennypal';

const _alertsChannel = AndroidNotificationChannel(
  alertsChannelId,
  'PennyPal Alerts',
  description: 'Transaction, budget and savings goal alerts',
  importance: Importance.high,
);

const _reminderChannel = AndroidNotificationChannel(
  reminderChannelId,
  'Daily Entry Reminder',
  description: 'Reminds you to record your daily transactions',
  importance: Importance.high,
);

const _alertDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    alertsChannelId,
    'PennyPal Alerts',
    channelDescription: 'Transaction, budget and savings goal alerts',
    importance: Importance.high,
    priority: Priority.high,
    icon: _smallIcon,
  ),
  iOS: DarwinNotificationDetails(),
);

const _reminderDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    reminderChannelId,
    'Daily Entry Reminder',
    channelDescription: 'Reminds you to record your daily transactions',
    importance: Importance.high,
    priority: Priority.high,
    icon: _smallIcon,
  ),
  iOS: DarwinNotificationDetails(),
);

/// Handles data-only messages while the app is backgrounded/terminated.
/// Notification-type messages are displayed by the OS itself.
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) return;
  final data = message.data;
  final title = data['title']?.toString();
  final body = data['body']?.toString();
  if (title == null && body == null) return;
  try {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_smallIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
    );
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_alertsChannel);
    await plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: _alertDetails,
      payload: data['route']?.toString(),
    );
  } catch (_) {
    // Background isolate has no plugin registrant or no permission — the OS
    // will still surface notification-type messages.
  }
}

/// Central hub for local (scheduled + foreground) and push (FCM) notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Route the app should navigate to once a notification is tapped.
  final ValueNotifier<String?> pendingRoute = ValueNotifier<String?>(null);

  final _messageSubs = <StreamSubscription<dynamic>>[];
  String? _uid;
  bool _initialized = false;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get _isIOS =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Falls back to UTC when the platform timezone cannot be resolved.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_smallIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          pendingRoute.value = response.payload;
        }
      },
    );

    if (_isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(_alertsChannel);
      await android?.createNotificationChannel(_reminderChannel);
    }

    final messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(notificationBackgroundHandler);
    _messageSubs.add(
      FirebaseMessaging.onMessage.listen(_onForegroundMessage),
    );
    _messageSubs.add(
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        pendingRoute.value = _routeFrom(message);
      }),
    );
    try {
      final initial = await messaging.getInitialMessage();
      if (initial != null) pendingRoute.value = _routeFrom(initial);
    } catch (_) {}
  }

  // ── Permissions ────────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    if (_isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission() ?? true;
      return granted;
    }
    if (_isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? true;
    }
    return true;
  }

  /// Whether the OS currently allows this app to post notifications.
  Future<bool> permissionGranted() async {
    if (_isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? true;
    }
    if (_isIOS) {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
    return true;
  }

  // ── Local notifications ────────────────────────────────────────────────────

  Future<bool> showTestNotification() async {
    final granted = await requestPermission();
    if (!granted) return false;
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Notifications are working',
      body: 'PennyPal will alert you about transactions, budgets and goals.',
      notificationDetails: _alertDetails,
      payload: '/notifications',
    );
    return true;
  }

  // ── Daily entry reminder ───────────────────────────────────────────────────

  Future<void> scheduleDailyReminder(String hhmm) async {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.first) ?? 20;
    final minute = parts.length > 1 ? int.tryParse(parts.last) ?? 0 : 0;

    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id: dailyReminderNotificationId,
      title: 'Log today\u2019s transactions',
      body:
          'Take a minute to record your spending and keep your budget on track.',
      scheduledDate: next,
      notificationDetails: _reminderDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/add-expense',
    );
  }

  Future<void> cancelDailyReminder() =>
      _plugin.cancel(id: dailyReminderNotificationId);

  Future<bool> isDailyReminderScheduled() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((r) => r.id == dailyReminderNotificationId);
  }

  /// Re-arms the reminder after app start when it is enabled in preferences.
  Future<void> ensureDailyReminder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('prefs_reminder') ?? false;
      if (!enabled) return;
      if (await isDailyReminderScheduled()) return;
      if (!await permissionGranted()) return;
      await scheduleDailyReminder(
        prefs.getString('prefs_reminder_time') ?? '20:00',
      );
    } catch (_) {}
  }

  // ── Push (FCM) ─────────────────────────────────────────────────────────────

  Future<void> registerDevice(String uid) async {
    _uid = uid;
    final messaging = FirebaseMessaging.instance;
    var permission = await messaging.getNotificationSettings();
    if (permission.authorizationStatus == AuthorizationStatus.notDetermined) {
      permission = await messaging.requestPermission();
    }
    try {
      final token = await messaging.getToken();
      if (token != null) await _saveToken(uid, token);
    } catch (_) {}
    try {
      await messaging.subscribeToTopic('user_$uid');
      await messaging.subscribeToTopic('pennypal_users');
    } catch (_) {}
    await syncPreferences();
  }

  Future<void> unregisterDevice(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance.collection('userProfiles').doc(uid).set({
        if (token != null) 'fcmTokens': FieldValue.arrayRemove([token]),
        'fcmToken': FieldValue.delete(),
      }, SetOptions(merge: true));
    } catch (_) {}
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('user_$uid');
    } catch (_) {}
    if (_uid == uid) _uid = null;
  }

  /// Mirrors the in-app alert toggles to Firestore so a backend sender can
  /// honour them when addressing this user's devices.
  Future<void> syncPreferences({
    bool? transactions,
    bool? budgets,
    bool? goals,
    bool? reminder,
    String? reminderTime,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    try {
      final data = <String, dynamic>{
        'transactionAlerts': transactions ?? prefs.getBool('prefs_notif_tx') ?? true,
        'budgetAlerts': budgets ?? prefs.getBool('prefs_notif_budget') ?? true,
        'goalAlerts': goals ?? prefs.getBool('prefs_notif_goals') ?? true,
        'dailyReminder': reminder ?? prefs.getBool('prefs_reminder') ?? false,
        'reminderTime': reminderTime ?? prefs.getString('prefs_reminder_time') ?? '20:00',
      };
      await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(uid)
          .set({'notificationPrefs': data}, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(uid)
          .set({
            'fcmTokens': FieldValue.arrayUnion([token]),
            'fcmToken': token,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      FirebaseMessaging.instance.onTokenRefresh.listen((fresh) {
        FirebaseFirestore.instance.collection('userProfiles').doc(uid).set({
          'fcmTokens': FieldValue.arrayUnion([fresh]),
          'fcmToken': fresh,
        }, SetOptions(merge: true));
      });
    } catch (_) {}
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final type = message.data['type']?.toString();
    final allowed = switch (type) {
      'transaction' => prefs.getBool('prefs_notif_tx') ?? true,
      'budget' => prefs.getBool('prefs_notif_budget') ?? true,
      'goal' => prefs.getBool('prefs_notif_goals') ?? true,
      _ => true,
    };
    if (!allowed) return;

    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if (title == null && body == null) return;

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: _alertDetails,
      payload: _routeFrom(message),
    );
  }

  String _routeFrom(RemoteMessage message) {
    final route = message.data['route']?.toString();
    return (route == null || route.isEmpty) ? '/notifications' : route;
  }
}
