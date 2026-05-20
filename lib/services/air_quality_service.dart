import 'package:dio/dio.dart';
import '../models/air_quality_model.dart';
import '../utils/constants.dart';

class AirQualityService {
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  Future<AirQualityModel> fetchAirQuality(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '$kAirQualityBaseUrl/air-quality',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': [
            'european_aqi',
            'pm2_5',
            'pm10',
            'uv_index',
          ].join(','),
          'timezone': 'Asia/Kolkata',
        },
      );
      return AirQualityModel.fromOpenMeteo(response.data as Map<String, dynamic>);
    } catch (_) {
      return AirQualityModel.mock();
    }
  }
}
