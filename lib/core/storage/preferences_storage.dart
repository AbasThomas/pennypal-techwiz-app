import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Use only for non-sensitive preferences; authentication tokens belong in AuthStorage.
class PreferencesStorage {
  const PreferencesStorage(this._preferences);
  final SharedPreferences _preferences;

  bool? getBool(String key) => _preferences.getBool(key);
  Future<bool> setBool(String key, bool value) =>
      _preferences.setBool(key, value);

  String? getString(String key) => _preferences.getString(key);
  Future<bool> setString(String key, String value) =>
      _preferences.setString(key, value);

  int? getInt(String key) => _preferences.getInt(key);
  Future<bool> setInt(String key, int value) => _preferences.setInt(key, value);

  Future<bool> remove(String key) => _preferences.remove(key);
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() after '
    'SharedPreferences.getInstance() has completed.',
  );
});

final preferencesStorageProvider = Provider<PreferencesStorage>(
  (ref) => PreferencesStorage(ref.watch(sharedPreferencesProvider)),
);

class AppCurrency {
  const AppCurrency(this.symbol, this.code);
  final String symbol;
  final String code;

  static const naira = AppCurrency('\u20A6', 'NGN');
}

final appCurrencyProvider = Provider<AppCurrency>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppCurrency(
    prefs.getString('prefs_currency_symbol') ?? '\u20A6',
    prefs.getString('prefs_currency_code') ?? 'NGN',
  );
});

NumberFormat currencyFormatRef(WidgetRef ref, {int decimalDigits = 0}) {
  final c = ref.watch(appCurrencyProvider);
  return NumberFormat.currency(symbol: c.symbol, decimalDigits: decimalDigits);
}

String currencyFormatNum(WidgetRef ref, num value, {int decimalDigits = 0}) =>
    currencyFormatRef(ref, decimalDigits: decimalDigits).format(value);

String currencySymbolRef(WidgetRef ref) => ref.watch(appCurrencyProvider).symbol;
String currencyCodeRef(WidgetRef ref) => ref.watch(appCurrencyProvider).code;
