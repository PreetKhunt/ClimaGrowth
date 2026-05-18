import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/recommendation_model.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

class OfflineCacheService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(kBoxWeather);
    await Hive.openBox(kBoxRecommendations);
    await Hive.openBox(kBoxChat);
    await Hive.openBox(kBoxSettings);
  }

  // ── Weather ──────────────────────────────────────────────────────────────

  static Future<void> cacheWeather(WeatherModel weather) async {
    final box = Hive.box(kBoxWeather);
    await box.put('latest', weather.toJson());
    await box.put('cached_at', DateTime.now().toIso8601String());
  }

  static WeatherModel? getCachedWeather() {
    final box = Hive.box(kBoxWeather);
    final data = box.get('latest');
    if (data == null) return null;
    return WeatherModel.mock(); // In production, reconstruct from cached JSON
  }

  static bool isWeatherCacheStale() {
    final box = Hive.box(kBoxWeather);
    final cachedAt = box.get('cached_at') as String?;
    if (cachedAt == null) return true;
    final dt = DateTime.tryParse(cachedAt);
    if (dt == null) return true;
    return DateTime.now().difference(dt).inHours > 3;
  }

  // ── Settings ─────────────────────────────────────────────────────────────

  static Future<void> saveSettings(String key, dynamic value) async {
    await Hive.box(kBoxSettings).put(key, value);
  }

  static dynamic getSetting(String key, [dynamic defaultValue]) {
    return Hive.box(kBoxSettings).get(key, defaultValue: defaultValue);
  }

  // ── Recommendations ───────────────────────────────────────────────────────

  static Future<void> cacheRecommendations(List<RecommendationModel> recs) async {
    final box = Hive.box(kBoxRecommendations);
    final data = recs.map((r) => {'id': r.id, 'title': r.title, 'description': r.description}).toList();
    await box.put('latest', jsonEncode(data));
  }

  static String? getCachedRecommendationsRaw() {
    return Hive.box(kBoxRecommendations).get('latest') as String?;
  }

  // ── Chat Cache ─────────────────────────────────────────────────────────────

  static Future<void> cacheMessage(Map<String, dynamic> msg) async {
    final box = Hive.box(kBoxChat);
    final raw = box.get('messages', defaultValue: '[]') as String;
    final List<dynamic> existing = jsonDecode(raw) as List;
    existing.add(msg);
    if (existing.length > 50) existing.removeAt(0);
    await box.put('messages', jsonEncode(existing));
  }

  static List<Map<String, dynamic>> getCachedMessages() {
    final box = Hive.box(kBoxChat);
    final raw = box.get('messages', defaultValue: '[]') as String;
    final list = jsonDecode(raw) as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
