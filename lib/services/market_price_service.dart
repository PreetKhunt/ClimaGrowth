import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_price_model.dart';

class MarketPriceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<MarketPriceModel>> getPrices({String? crop, String? region}) async {
    try {
      Query query = _db.collection('marketPrices');
      if (crop != null) query = query.where('crop', isEqualTo: crop);
      if (region != null) query = query.where('region', isEqualTo: region);
      final snap = await query.limit(50).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) => MarketPriceModel.fromMap(d.data() as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return MarketPriceModel.mockPrices();
  }
}
