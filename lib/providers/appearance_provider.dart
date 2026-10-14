import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceProvider extends ChangeNotifier {
  static const _themeModeKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedMode = preferences.getString(_themeModeKey);
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == savedMode,
      orElse: () => ThemeMode.light,
    );
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, themeMode.name);
    _themeMode = themeMode;
    notifyListeners();
  }
}
