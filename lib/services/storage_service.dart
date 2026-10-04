import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Service managing persistent key-value local storage.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// Get stored ThemeMode (system, light, dark).
  ThemeMode getThemeMode() {
    final mode = _prefs.getString(AppConstants.keyThemeMode);
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Save ThemeMode preference.
  Future<bool> setThemeMode(ThemeMode mode) async {
    return await _prefs.setString(AppConstants.keyThemeMode, mode.name);
  }

  /// Check if notifications are enabled.
  bool getNotificationsEnabled() {
    return _prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true;
  }

  /// Save notifications enabled state.
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs.setBool(AppConstants.keyNotificationsEnabled, enabled);
  }
}
