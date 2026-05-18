class WeatherModel {
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double rainfall;
  final double windSpeed;
  final String condition; // sunny / cloudy / rainy / stormy / heatwave
  final double rainProbability;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;
  final DateTime fetchedAt;

  const WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
    required this.condition,
    required this.rainProbability,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });

  factory WeatherModel.fromOpenMeteo(Map<String, dynamic> json) {
    final current = Map<String, dynamic>.from(json['current'] as Map? ?? {});
    final hourlyRaw = Map<String, dynamic>.from(json['hourly'] as Map? ?? {});
    final dailyRaw = Map<String, dynamic>.from(json['daily'] as Map? ?? {});

    final temps = (hourlyRaw['temperature_2m'] as List?)?.cast<double>() ?? [];
    final precipProb = (hourlyRaw['precipitation_probability'] as List?)?.cast<int>() ?? [];
    final times = (hourlyRaw['time'] as List?)?.cast<String>() ?? [];
    final codes = (hourlyRaw['weathercode'] as List?)?.cast<int>() ?? [];

    final List<HourlyWeather> hourly = [];
    for (int i = 0; i < times.length && i < 24; i++) {
      hourly.add(HourlyWeather(
        time: DateTime.tryParse(times[i]) ?? DateTime.now(),
        temperature: i < temps.length ? temps[i] : 0,
        precipitationProbability: i < precipProb.length ? precipProb[i] : 0,
        weatherCode: i < codes.length ? codes[i] : 0,
      ));
    }

    final dTimes = (dailyRaw['time'] as List?)?.cast<String>() ?? [];
    final maxTemps = (dailyRaw['temperature_2m_max'] as List?)?.cast<double>() ?? [];
    final minTemps = (dailyRaw['temperature_2m_min'] as List?)?.cast<double>() ?? [];
    final dPrecip = (dailyRaw['precipitation_probability_max'] as List?)?.cast<int>() ?? [];

    final List<DailyWeather> daily = [];
    for (int i = 0; i < dTimes.length && i < 7; i++) {
      daily.add(DailyWeather(
        date: DateTime.tryParse(dTimes[i]) ?? DateTime.now(),
        maxTemp: i < maxTemps.length ? maxTemps[i] : 0,
        minTemp: i < minTemps.length ? minTemps[i] : 0,
        precipitationProbability: i < dPrecip.length ? dPrecip[i] : 0,
      ));
    }

    final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 28.0;
    final wind = (current['windspeed_10m'] as num?)?.toDouble() ?? 12.0;
    final hum = (current['relativehumidity_2m'] as num?)?.toDouble() ?? 65.0;
    final rain = (current['rain'] as num?)?.toDouble() ?? 0.0;
    final code = (current['weathercode'] as int?) ?? 0;

    return WeatherModel(
      temperature: temp,
      feelsLike: temp - 2,
      humidity: hum,
      rainfall: rain,
      windSpeed: wind,
      condition: _codeToCondition(code),
      rainProbability: (precipProb.isNotEmpty ? precipProb[0] : 0).toDouble(),
      hourly: hourly,
      daily: daily,
      fetchedAt: DateTime.now(),
    );
  }

  static String _codeToCondition(int code) {
    if (code == 0 || code == 1) return 'sunny';
    if (code <= 3) return 'cloudy';
    if (code >= 95) return 'stormy';
    if (code >= 61) return 'rainy';
    return 'cloudy';
  }

  factory WeatherModel.mock() => WeatherModel(
        temperature: 31.5,
        feelsLike: 33.0,
        humidity: 68.0,
        rainfall: 0.0,
        windSpeed: 14.2,
        condition: 'sunny',
        rainProbability: 15.0,
        hourly: List.generate(
          24,
          (i) => HourlyWeather(
            time: DateTime.now().add(Duration(hours: i)),
            temperature: 28.0 + (i % 6) * 1.5,
            precipitationProbability: (i * 3) % 40,
            weatherCode: 0,
          ),
        ),
        daily: List.generate(
          7,
          (i) => DailyWeather(
            date: DateTime.now().add(Duration(days: i)),
            maxTemp: 32.0 + i,
            minTemp: 22.0 + i,
            precipitationProbability: (i * 10) % 60,
          ),
        ),
        fetchedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'feelsLike': feelsLike,
        'humidity': humidity,
        'rainfall': rainfall,
        'windSpeed': windSpeed,
        'condition': condition,
        'rainProbability': rainProbability,
        'fetchedAt': fetchedAt.toIso8601String(),
      };
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int precipitationProbability;
  final int weatherCode;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.weatherCode,
  });
}

class DailyWeather {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int precipitationProbability;

  const DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationProbability,
  });
}
