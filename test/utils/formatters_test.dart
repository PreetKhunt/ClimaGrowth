import 'package:climagrowth/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters', () {
    test('temperature formats with degree symbol', () {
      expect(Formatters.temperature(31.5), '31.5°C');
    });

    test('humidity formats with percent symbol', () {
      expect(Formatters.humidity(68.0), '68%');
    });

    test('windSpeed formats with km/h unit', () {
      expect(Formatters.windSpeed(14.2), '14.2 km/h');
    });

    test('moisture rounds to 0 decimals', () {
      expect(Formatters.moisture(62.7), '63%');
    });

    test('price formats with rupee symbol and comma', () {
      expect(Formatters.price(6850), '₹6,850');
    });

    test('acres formats with two decimal places', () {
      expect(Formatters.acres(2.5), '2.50 acres');
    });

    test('litres rounds to 0 decimals', () {
      expect(Formatters.litres(1800.7), '1801 L');
    });

    test('greeting returns non-empty string', () {
      expect(Formatters.greeting().isNotEmpty, isTrue);
    });
  });
}
