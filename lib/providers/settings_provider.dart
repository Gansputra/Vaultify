import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _biometricKey = 'biometric_enabled';
  static const String _themeKey = 'theme_dark';

  late SharedPreferences _prefs;
  bool _biometricEnabled = true;
  bool _isDarkMode = true;

  bool get biometricEnabled => _biometricEnabled;
  bool get isDarkMode => _isDarkMode;

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _biometricEnabled = _prefs.getBool(_biometricKey) ?? true;
    _isDarkMode = _prefs.getBool(_themeKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleBiometric(bool value) async {
    _biometricEnabled = value;
    await _prefs.setBool(_biometricKey, value);
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool(_themeKey, value);
    notifyListeners();
  }

}
