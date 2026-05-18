import 'package:flutter/material.dart';
import '../models/recommendation_model.dart';
import '../services/offline_cache_service.dart';

class RecommendationsProvider extends ChangeNotifier {
  List<RecommendationModel> _recommendations = [];
  bool _loading = false;
  bool _generated = false;

  List<RecommendationModel> get recommendations => List.unmodifiable(_recommendations);
  bool get loading => _loading;
  bool get generated => _generated;

  Future<void> generate({
    required String crop,
    required String soilType,
    required String irrigationMethod,
    required String previousCrop,
    required double farmSize,
  }) async {
    _loading = true;
    _generated = false;
    notifyListeners();

    // Simulate AI processing delay, then use mock data
    // In production, call Gemini API here with form inputs + weather/soil context
    await Future.delayed(const Duration(seconds: 2));

    _recommendations = RecommendationModel.mock();
    _generated = true;
    _loading = false;

    // Cache to offline storage
    await OfflineCacheService.cacheRecommendations(_recommendations);

    notifyListeners();
  }

  void loadCached() {
    final raw = OfflineCacheService.getCachedRecommendationsRaw();
    if (raw != null && _recommendations.isEmpty) {
      _recommendations = RecommendationModel.mock(); // use mock as fallback shape
      notifyListeners();
    }
  }

  void clear() {
    _recommendations = [];
    _generated = false;
    notifyListeners();
  }
}
