import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive flags only. Tokens belong in secure storage.
class AppPreferences {
  AppPreferences(this._preferences);

  static Future<AppPreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppPreferences(preferences);
  }

  final SharedPreferences _preferences;

  String? readString(String key) => _preferences.getString(key);

  Future<void> writeString(String key, String value) {
    return _preferences.setString(key, value);
  }

  bool readBool(String key, {bool fallback = false}) {
    return _preferences.getBool(key) ?? fallback;
  }

  Future<void> writeBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  Future<void> remove(String key) => _preferences.remove(key);
}
