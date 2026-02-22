import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _biometricKey = 'biometric_enabled';
  static const String _themeKey = 'theme_dark';
  static const String _langKey = 'app_language';

  late SharedPreferences _prefs;
  bool _biometricEnabled = true;
  bool _isDarkMode = true;
  String _currentLanguage = 'en'; // 'en' or 'id'

  bool get biometricEnabled => _biometricEnabled;
  bool get isDarkMode => _isDarkMode;
  String get currentLanguage => _currentLanguage;

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
    _currentLanguage = _prefs.getString(_langKey) ?? 'id'; // Default to ID as requested
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

  Future<void> setLanguage(String langCode) async {
    _currentLanguage = langCode;
    await _prefs.setString(_langKey, langCode);
    notifyListeners();
  }
}
