import 'package:climagrowth/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('accepts valid email', () {
      expect(Validators.email('farmer@gmail.com'), isNull);
    });
    test('rejects empty string', () {
      expect(Validators.email(''), isNotNull);
    });
    test('rejects missing @', () {
      expect(Validators.email('farmergmail.com'), isNotNull);
    });
    test('rejects no TLD', () {
      expect(Validators.email('farmer@gmail'), isNotNull);
    });
  });

  group('Validators.mobile', () {
    test('accepts 10-digit number', () {
      expect(Validators.mobile('9876543210'), isNull);
    });
    test('accepts number with +91 prefix', () {
      expect(Validators.mobile('+919876543210'), isNull);
    });
    test('rejects 9-digit number', () {
      expect(Validators.mobile('987654321'), isNotNull);
    });
    test('rejects empty', () {
      expect(Validators.mobile(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('accepts 6-char password', () {
      expect(Validators.password('abc123'), isNull);
    });
    test('rejects 5-char password', () {
      expect(Validators.password('abc12'), isNotNull);
    });
    test('rejects empty', () {
      expect(Validators.password(''), isNotNull);
    });
  });

  group('Validators.farmSize', () {
    test('accepts positive decimal', () {
      expect(Validators.farmSize('2.5'), isNull);
    });
    test('accepts integer', () {
      expect(Validators.farmSize('3'), isNull);
    });
    test('rejects zero', () {
      expect(Validators.farmSize('0'), isNotNull);
    });
    test('rejects negative', () {
      expect(Validators.farmSize('-1'), isNotNull);
    });
    test('rejects non-numeric', () {
      expect(Validators.farmSize('abc'), isNotNull);
    });
  });
}
