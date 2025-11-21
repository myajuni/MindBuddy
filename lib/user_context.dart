// lib/user_context.dart

import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  static String id = 'default_user';
  static String name = '';
  static String? pin;

  /// 이름 불러오기
  static Future<void> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString("profile_name") ?? "";
  }

  /// 이름 저장
  static Future<void> saveName(String newName) async {
    name = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_name", newName);
  }

  /// PIN 불러오기
  static Future<void> loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    pin = prefs.getString("profile_pin");
  }

  /// PIN 저장
  static Future<void> savePin(String newPin) async {
    pin = newPin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_pin", newPin);
  }
}
