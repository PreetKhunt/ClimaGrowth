import 'package:flutter/material.dart';
import '../services/offline_cache_service.dart';

class SettingsProvider extends ChangeNotifier {
  String _language = 'en';
  bool _darkMode = false;
  Map<String, bool> _notifPrefs = {
    'weather_alerts': true,
    'irrigation_reminders': true,
    'farming_tips': true,
    'market_updates': true,
  };

  String get language => _language;
  bool get darkMode => _darkMode;
  Map<String, bool> get notifPrefs => Map.unmodifiable(_notifPrefs);
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  void loadFromCache() {
    _language = OfflineCacheService.getSetting('language', 'en') as String;
    _darkMode = OfflineCacheService.getSetting('darkMode', false) as bool;
    _notifPrefs = {
      'weather_alerts': OfflineCacheService.getSetting('notif_weather', true) as bool,
      'irrigation_reminders': OfflineCacheService.getSetting('notif_irrigation', true) as bool,
      'farming_tips': OfflineCacheService.getSetting('notif_tips', true) as bool,
      'market_updates': OfflineCacheService.getSetting('notif_market', true) as bool,
    };
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await OfflineCacheService.saveSettings('language', lang);
    notifyListeners();
  }

  Future<void> setDarkMode(bool v) async {
    _darkMode = v;
    await OfflineCacheService.saveSettings('darkMode', v);
    notifyListeners();
  }

  Future<void> setNotifPref(String key, bool v) async {
    _notifPrefs[key] = v;
    await OfflineCacheService.saveSettings('notif_$key', v);
    notifyListeners();
  }
}
