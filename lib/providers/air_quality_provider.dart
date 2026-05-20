import 'package:flutter/material.dart';
import '../models/air_quality_model.dart';
import '../services/air_quality_service.dart';

class AirQualityProvider extends ChangeNotifier {
  final AirQualityService _service = AirQualityService();

  AirQualityModel? _airQuality;
  bool _loading = false;

  AirQualityModel? get airQuality => _airQuality;
  bool get loading => _loading;

  Future<void> fetch(double lat, double lon) async {
    _loading = true;
    notifyListeners();
    try {
      _airQuality = await _service.fetchAirQuality(lat, lon);
    } catch (_) {
      _airQuality = AirQualityModel.mock();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
