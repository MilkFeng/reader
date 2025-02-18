import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static Future<T?> get<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) {
      return null;
    }
    return prefs.get(key) as T?;
  }

  static Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  static Future<void> set<T>(String key, T? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      throw Exception('Invalid value type');
    }
  }
}
