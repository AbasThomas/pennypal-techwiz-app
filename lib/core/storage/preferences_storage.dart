import 'package:shared_preferences/shared_preferences.dart';

/// Use only for non-sensitive preferences; authentication tokens belong in AuthStorage.
class PreferencesStorage {
  const PreferencesStorage(this._preferences);
  final SharedPreferences _preferences;

  bool? getBool(String key) => _preferences.getBool(key);
  Future<bool> setBool(String key, bool value) =>
      _preferences.setBool(key, value);
}
