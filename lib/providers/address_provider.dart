import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';

class AddressProvider extends ChangeNotifier {
  static const _prefKey = 'delivery_addresses';
  List<DeliveryAddress> _addresses = [];
  bool _loaded = false;

  List<DeliveryAddress> get addresses => List.unmodifiable(_addresses);
  bool get hasAddresses => _addresses.isNotEmpty;
  DeliveryAddress? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _addresses = list
          .map((e) => DeliveryAddress.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(DeliveryAddress address) async {
    if (address.isDefault) _clearDefaults();
    _addresses.add(address);
    await _persist();
    notifyListeners();
  }

  Future<void> update(DeliveryAddress address) async {
    final idx = _addresses.indexWhere((a) => a.id == address.id);
    if (idx < 0) return;
    if (address.isDefault) _clearDefaults();
    _addresses[idx] = address;
    await _persist();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _addresses.removeWhere((a) => a.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> setDefault(String id) async {
    _addresses = _addresses.map((a) {
      final m = a.toJson();
      m['isDefault'] = a.id == id;
      return DeliveryAddress.fromJson(m);
    }).toList();
    await _persist();
    notifyListeners();
  }

  void _clearDefaults() {
    _addresses = _addresses.map((a) {
      final m = a.toJson();
      m['isDefault'] = false;
      return DeliveryAddress.fromJson(m);
    }).toList();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_addresses.map((a) => a.toJson()).toList());
    await prefs.setString(_prefKey, json);
  }
}
