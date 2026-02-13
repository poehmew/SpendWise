import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode'; // system/light/dark
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get themeMode => _mode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key) ?? 'system';
    _mode = _fromString(s);
    notifyListeners();
  }

  ThemeMode _fromString(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _toStringMode(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _toStringMode(mode));
  }

  Future<void> toggleLightDark() async {
    await setMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
