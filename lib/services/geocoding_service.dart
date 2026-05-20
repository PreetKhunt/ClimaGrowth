import 'package:dio/dio.dart';
import '../utils/constants.dart';

class GeocodingResult {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;

  const GeocodingResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
    );
  }
}

class GeocodingService {
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  Future<GeocodingResult?> geocode(String locationName) async {
    try {
      final response = await _dio.get(
        '$kGeocodingBaseUrl/search',
        queryParameters: {
          'name': locationName,
          'count': 5,
          'language': 'en',
        },
      );
      final results = (response.data['results'] as List?)?.cast<Map<String, dynamic>>();
      if (results == null || results.isEmpty) return null;
      // Prefer India result to disambiguate common names
      final hit = results.firstWhere(
        (r) => r['country'] == 'India',
        orElse: () => results.first,
      );
      return GeocodingResult.fromJson(hit);
    } catch (_) {
      return null;
    }
  }
}
