import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/offline_cache_service.dart';
import '../services/weather_service.dart';
import '../utils/constants.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  WeatherModel? _weather;
  bool _loading = false;
  bool _isOffline = false;

  WeatherModel? get weather => _weather;
  bool get loading => _loading;
  bool get isOffline => _isOffline;

  List<Color> get gradientColors {
    switch (_weather?.condition) {
      case 'sunny': return kSunnyGradient;
      case 'rainy': return kRainyGradient;
      case 'stormy': return kStormGradient;
      case 'heatwave': return kHeatwaveGradient;
      case 'cloudy': return kCloudyGradient;
      default:
        final hour = DateTime.now().hour;
        return (hour < 6 || hour > 20) ? kNightGradient : kSunnyGradient;
    }
  }

  Future<void> fetch(double lat, double lon) async {
    _loading = true;
    notifyListeners();
    try {
      _weather = await _service.fetchWeather(lat, lon);
      _isOffline = false;
      await OfflineCacheService.cacheWeather(_weather!);
    } catch (_) {
      _weather = OfflineCacheService.getCachedWeather() ?? WeatherModel.mock();
      _isOffline = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
