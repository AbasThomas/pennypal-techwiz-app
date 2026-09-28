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

  @override
  bool operator ==(Object other) =>
      other is AppCurrency && other.symbol == symbol && other.code == code;

  @override
  int get hashCode => Object.hash(symbol, code);
}

const _currencySymbolKey = 'prefs_currency_symbol';
const _currencyCodeKey = 'prefs_currency_code';

/// Owns the app-wide currency. Held at the root scope so writing it here
/// rebuilds every screen that formats an amount, wherever it sits.
class AppCurrencyNotifier extends StateNotifier<AppCurrency> {
  AppCurrencyNotifier(this._prefs)
      : super(
          AppCurrency(
            _prefs.getString(_currencySymbolKey) ?? AppCurrency.naira.symbol,
            _prefs.getString(_currencyCodeKey) ?? AppCurrency.naira.code,
          ),
        );

  final SharedPreferences _prefs;

  Future<void> set(AppCurrency currency) async {
    if (currency == state) return;
    state = currency;
    await Future.wait([
      _prefs.setString(_currencySymbolKey, currency.symbol),
      _prefs.setString(_currencyCodeKey, currency.code),
    ]);
  }
}

final appCurrencyProvider =
    StateNotifierProvider<AppCurrencyNotifier, AppCurrency>(
  (ref) => AppCurrencyNotifier(ref.watch(sharedPreferencesProvider)),
);

NumberFormat currencyFormatRef(WidgetRef ref, {int decimalDigits = 0}) {
  final c = ref.watch(appCurrencyProvider);
  return NumberFormat.currency(symbol: c.symbol, decimalDigits: decimalDigits);
}

String currencyFormatNum(WidgetRef ref, num value, {int decimalDigits = 0}) =>
    currencyFormatRef(ref, decimalDigits: decimalDigits).format(value);

String currencySymbolRef(WidgetRef ref) => ref.watch(appCurrencyProvider).symbol;
String currencyCodeRef(WidgetRef ref) => ref.watch(appCurrencyProvider).code;
