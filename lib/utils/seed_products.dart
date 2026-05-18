import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supply_product.dart';
import 'market_data.dart';

/// Run once from admin panel or dev console to seed Firestore.
Future<void> seedProducts() async {
  final col = FirebaseFirestore.instance.collection('supplies');
  final batch = FirebaseFirestore.instance.batch();
  for (final p in MarketData.allProducts) {
    batch.set(col.doc(p.id), p.toMap());
  }
  await batch.commit();
}
