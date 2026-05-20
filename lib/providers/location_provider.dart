import 'package:flutter/material.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _service = LocationService();
  final GeocodingService _geocoding = GeocodingService();

  double _lat = kDefaultLat;
  double _lon = kDefaultLon;
  String _village = 'Padra';
  bool _locationGranted = false;

  double get lat => _lat;
  double get lon => _lon;
  String get village => _village;
  bool get locationGranted => _locationGranted;

  Future<void> detectLocation() async {
    final pos = await _service.getCurrentLocation();
    if (pos != null) {
      _lat = pos.latitude;
      _lon = pos.longitude;
      _locationGranted = true;
      notifyListeners();
    }
  }

  Future<void> setManualVillage(String name) async {
    _village = name;
    final coords = _villageCoords[name];
    if (coords != null) {
      _lat = coords.$1;
      _lon = coords.$2;
    } else {
      // Resolve unknown village via Open-Meteo geocoding API
      final result = await _geocoding.geocode(name);
      if (result != null) {
        _lat = result.latitude;
        _lon = result.longitude;
      }
    }
    notifyListeners();
  }

  static const Map<String, (double, double)> _villageCoords = {
    'Padra': (22.2354, 73.0842),
    'Vadodara': (22.3072, 73.1812),
    'Karjan': (22.0513, 73.1232),
    'Savli': (22.5242, 73.3012),
    'Waghodia': (22.2983, 73.3142),
    'Dabhoi': (22.1833, 73.4333),
    'Shinor': (21.9333, 73.4833),
  };
}
