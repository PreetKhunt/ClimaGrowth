import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPriceModel {
  final String crop;
  final String mandi;
  final double price; // Rs per quintal
  final DateTime date;
  final String region;

  const MarketPriceModel({
    required this.crop,
    required this.mandi,
    required this.price,
    required this.date,
    required this.region,
  });

  factory MarketPriceModel.fromMap(Map<String, dynamic> map) {
    return MarketPriceModel(
      crop: map['crop'] ?? '',
      mandi: map['mandi'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      region: map['region'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'crop': crop,
        'mandi': mandi,
        'price': price,
        'date': Timestamp.fromDate(date),
        'region': region,
      };

  static List<MarketPriceModel> mockPrices() {
    final now = DateTime.now();
    return [
      MarketPriceModel(crop: 'Cotton', mandi: 'Vadodara APMC', price: 6850, date: now, region: 'Vadodara'),
      MarketPriceModel(crop: 'Cotton', mandi: 'Padra Mandi', price: 6500, date: now, region: 'Padra'),
      MarketPriceModel(crop: 'Cotton', mandi: 'Karjan Mandi', price: 6620, date: now, region: 'Karjan'),
      MarketPriceModel(crop: 'Wheat', mandi: 'Vadodara APMC', price: 2150, date: now, region: 'Vadodara'),
      MarketPriceModel(crop: 'Wheat', mandi: 'Padra Mandi', price: 2080, date: now, region: 'Padra'),
      MarketPriceModel(crop: 'Tomato', mandi: 'Padra Mandi', price: 1200, date: now, region: 'Padra'),
      MarketPriceModel(crop: 'Tomato', mandi: 'Savli Mandi', price: 1350, date: now, region: 'Savli'),
      MarketPriceModel(crop: 'Cabbage', mandi: 'Karjan Mandi', price: 800, date: now, region: 'Karjan'),
      MarketPriceModel(crop: 'Groundnut', mandi: 'Vadodara APMC', price: 5200, date: now, region: 'Vadodara'),
      MarketPriceModel(crop: 'Groundnut', mandi: 'Padra Mandi', price: 5050, date: now, region: 'Padra'),
    ];
  }

  // 7-day price history for a crop
  static List<double> mockTrend(String crop) {
    final base = mockPrices().firstWhere((p) => p.crop == crop && p.mandi.contains('Padra'),
        orElse: () => MarketPriceModel(crop: crop, mandi: 'Padra', price: 2000, date: DateTime.now(), region: 'Padra'));
    final b = base.price;
    return [b * 0.92, b * 0.95, b * 0.97, b * 0.99, b * 1.01, b * 1.0, b * 1.02];
  }
}
