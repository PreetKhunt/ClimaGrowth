import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/soil_model.dart';

class SoilService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<SoilModel> getSoilData(String uid) async {
    try {
      final snap = await _db
          .collection('soilData')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        return SoilModel.fromMap(snap.docs.first.data());
      }
    } catch (_) {}
    return SoilModel.mock(uid);
  }

  Future<void> saveSoilData(SoilModel soil) async {
    await _db.collection('soilData').add(soil.toMap());
  }
}
