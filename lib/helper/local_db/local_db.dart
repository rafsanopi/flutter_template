import 'package:shared_preferences/shared_preferences.dart';

class SharePrefsHelper {
  static Future<String> getString(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(key) ?? '';
  }

  static Future<List<String>> getListOfString(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(key) ?? <String>[];
  }

  @Deprecated('Use getListOfString instead.')
  static Future<List<String>> getLisOfString(String key) {
    return getListOfString(key);
  }

  static Future<bool?> getBool(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(key);
  }

  static Future<int> getInt(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(key) ?? -1;
  }

  static Future<void> setString(String key, String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }

  static Future<bool> setListOfString(String key, List<String> value) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setStringList(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(key, value);
  }

  static Future<bool> remove(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.remove(key);
  }
}
