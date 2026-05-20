class AirQualityModel {
  final int europeanAqi;
  final double pm25;
  final double pm10;
  final double uvIndex;
  final DateTime fetchedAt;

  const AirQualityModel({
    required this.europeanAqi,
    required this.pm25,
    required this.pm10,
    required this.uvIndex,
    required this.fetchedAt,
  });

  /// Human-readable label based on European AQI scale.
  String get label {
    if (europeanAqi <= 20) return 'Good';
    if (europeanAqi <= 40) return 'Fair';
    if (europeanAqi <= 60) return 'Moderate';
    if (europeanAqi <= 80) return 'Poor';
    if (europeanAqi <= 100) return 'Very Poor';
    return 'Extremely Poor';
  }

  /// UV exposure advice for farmers.
  String get uvAdvice {
    if (uvIndex < 3) return 'Low – no protection needed';
    if (uvIndex < 6) return 'Moderate – wear sunscreen';
    if (uvIndex < 8) return 'High – hat & sunscreen required';
    if (uvIndex < 11) return 'Very High – limit midday exposure';
    return 'Extreme – avoid outdoor work 10am–4pm';
  }

  factory AirQualityModel.fromOpenMeteo(Map<String, dynamic> json) {
    final current = Map<String, dynamic>.from(json['current'] as Map? ?? {});
    return AirQualityModel(
      europeanAqi: (current['european_aqi'] as num?)?.toInt() ?? 0,
      pm25: (current['pm2_5'] as num?)?.toDouble() ?? 0.0,
      pm10: (current['pm10'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (current['uv_index'] as num?)?.toDouble() ?? 0.0,
      fetchedAt: DateTime.now(),
    );
  }

  factory AirQualityModel.mock() => AirQualityModel(
        europeanAqi: 28,
        pm25: 18.5,
        pm10: 32.0,
        uvIndex: 6.2,
        fetchedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'europeanAqi': europeanAqi,
        'pm25': pm25,
        'pm10': pm10,
        'uvIndex': uvIndex,
        'fetchedAt': fetchedAt.toIso8601String(),
      };
}
