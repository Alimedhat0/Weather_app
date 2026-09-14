import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _sharedPreferences;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setBool(String key, bool value) =>
      _sharedPreferences.setBool(key, value);

  static bool? getBool(String key) => _sharedPreferences.getBool(key);
}
