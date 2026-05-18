import 'package:flutter/material.dart';
import '../models/soil_model.dart';
import '../services/soil_service.dart';

class SoilProvider extends ChangeNotifier {
  final SoilService _service = SoilService();

  SoilModel? _soil;
  bool _loading = false;

  SoilModel? get soil => _soil;
  bool get loading => _loading;

  Future<void> fetch(String uid) async {
    _loading = true;
    notifyListeners();
    _soil = await _service.getSoilData(uid);
    _loading = false;
    notifyListeners();
  }
}
