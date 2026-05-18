import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

class WeatherService {
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  Future<WeatherModel> fetchWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '$kOpenMeteoBaseUrl/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': [
            'temperature_2m',
            'relativehumidity_2m',
            'apparent_temperature',
            'rain',
            'weathercode',
            'windspeed_10m',
          ].join(','),
          'hourly': [
            'temperature_2m',
            'precipitation_probability',
            'weathercode',
          ].join(','),
          'daily': [
            'temperature_2m_max',
            'temperature_2m_min',
            'precipitation_probability_max',
          ].join(','),
          'timezone': 'Asia/Kolkata',
          'forecast_days': 7,
        },
      );
      return WeatherModel.fromOpenMeteo(response.data as Map<String, dynamic>);
    } catch (_) {
      return WeatherModel.mock();
    }
  }
}
