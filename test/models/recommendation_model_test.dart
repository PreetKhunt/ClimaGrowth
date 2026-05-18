import 'package:climagrowth/models/recommendation_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecommendationModel', () {
    test('mock() returns 7 recommendations', () {
      final recs = RecommendationModel.mock();
      expect(recs.length, equals(7));
    });

    test('all recommendation types are represented', () {
      final recs = RecommendationModel.mock();
      final types = recs.map((r) => r.type).toSet();
      expect(types, containsAll(RecommendationType.values));
    });

    test('each recommendation has a non-empty title', () {
      for (final rec in RecommendationModel.mock()) {
        expect(rec.title.isNotEmpty, isTrue,
            reason: '${rec.type} title is empty');
      }
    });

    test('each recommendation has a non-empty description', () {
      for (final rec in RecommendationModel.mock()) {
        expect(rec.description.isNotEmpty, isTrue);
      }
    });

    test('market recommendation has detail content', () {
      final market = RecommendationModel.mock()
          .firstWhere((r) => r.type == RecommendationType.market);
      expect(market.detailContent, isNotNull);
      expect(market.detailContent!.isNotEmpty, isTrue);
    });
  });
}
