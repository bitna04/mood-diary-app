import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> saveThemeMode(ThemeMode mode) async {
    return await _prefs.setString(_themeKey, mode.toString());
  }

  static ThemeMode getSavedThemeMode() {
    final savedMode = _prefs.getString(_themeKey);
    if (savedMode == null) return ThemeMode.light;

    if (savedMode.contains('dark')) return ThemeMode.dark;
    if (savedMode.contains('system')) return ThemeMode.system;
    return ThemeMode.light;
  }
}
