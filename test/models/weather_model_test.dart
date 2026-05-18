import 'package:climagrowth/models/weather_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherModel', () {
    test('mock() returns valid data', () {
      final w = WeatherModel.mock();
      expect(w.temperature, greaterThan(0));
      expect(w.humidity, inInclusiveRange(0, 100));
      expect(w.hourly.length, equals(24));
      expect(w.daily.length, equals(7));
    });

    test('condition maps correctly from Open-Meteo code', () {
      // Code 0 = clear sky → sunny
      final json = _buildJson(weatherCode: 0, temp: 32.0);
      final model = WeatherModel.fromOpenMeteo(json);
      expect(model.condition, 'sunny');
    });

    test('rainy condition for code 61', () {
      final json = _buildJson(weatherCode: 61, temp: 28.0);
      final model = WeatherModel.fromOpenMeteo(json);
      expect(model.condition, 'rainy');
    });

    test('stormy condition for code 95', () {
      final json = _buildJson(weatherCode: 95, temp: 25.0);
      final model = WeatherModel.fromOpenMeteo(json);
      expect(model.condition, 'stormy');
    });

    test('toJson() round-trips temperature', () {
      final w = WeatherModel.mock();
      final json = w.toJson();
      expect(json['temperature'], closeTo(w.temperature, 0.01));
    });

    test('feelsLike is 2 degrees less than temperature (mock)', () {
      final w = WeatherModel.mock();
      expect(w.feelsLike, closeTo(w.temperature - 2, 0.01));
    });
  });
}

Map<String, dynamic> _buildJson({required int weatherCode, required double temp}) {
  return {
    'current': {
      'temperature_2m': temp,
      'relativehumidity_2m': 65.0,
      'apparent_temperature': temp - 2,
      'rain': 0.0,
      'weathercode': weatherCode,
      'windspeed_10m': 12.0,
    },
    'hourly': {
      'time': List.generate(24, (i) => '2026-05-10T${i.toString().padLeft(2, '0')}:00'),
      'temperature_2m': List.generate(24, (i) => temp + (i % 4 - 2) * 1.0),
      'precipitation_probability': List.generate(24, (i) => i * 2),
      'weathercode': List.generate(24, (_) => weatherCode),
    },
    'daily': {
      'time': List.generate(7, (i) => '2026-05-${(10 + i).toString().padLeft(2, '0')}'),
      'temperature_2m_max': List.generate(7, (i) => temp + i),
      'temperature_2m_min': List.generate(7, (i) => temp - 5 + i),
      'precipitation_probability_max': List.generate(7, (i) => i * 10),
    },
  };
}
