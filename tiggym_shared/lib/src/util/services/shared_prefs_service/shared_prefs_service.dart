import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  bool initialized = false;
  late SharedPreferences sharedPreferences;
  SharedPrefsService._privateConstructor();

  static final SharedPrefsService instance = SharedPrefsService._privateConstructor();

  Future<void> initialize() async {
    initialized = true;
    sharedPreferences = await SharedPreferences.getInstance();
  }

  String? getString(String key) => sharedPreferences.getString(key);
  bool? getBool(String key) => sharedPreferences.getBool(key);

  Future<bool> setString(String key, String value) => sharedPreferences.setString(key, value);
  Future<bool> setBool(String key, bool value) => sharedPreferences.setBool(key, value);

  Future<void> remove(String key) => sharedPreferences.remove(key);
}
