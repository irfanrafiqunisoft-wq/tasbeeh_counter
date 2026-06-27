import 'package:shared_preferences/shared_preferences.dart';
import '../models/tasbeeh.dart';

/// Sare tasbeehs aur app-wide settings device storage mein save karta hai.
class StorageService {
  static const _tasbeehListKey = 'tasbeeh_list';
  static const _vibrationKey = 'vibration_enabled';
  static const _darkModeKey = 'dark_mode_enabled';

  static Future<void> saveTasbeehList(List<Tasbeeh> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasbeehListKey, Tasbeeh.encodeList(list));
  }

  static Future<List<Tasbeeh>> getTasbeehList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_tasbeehListKey) ?? '';
    if (jsonStr.isEmpty) return [];
    try {
      return Tasbeeh.decodeList(jsonStr);
    } catch (e) {
      return [];
    }
  }

  static Future<void> setVibration(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, enabled);
  }

  static Future<bool> getVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? true;
  }

  static Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }
}
