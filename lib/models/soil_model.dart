import 'package:cloud_firestore/cloud_firestore.dart';

class SoilModel {
  final String uid;
  final DateTime timestamp;
  final double moistureLevel; // 0–100
  final String soilType;
  final String irrigationMethod;
  final String healthStatus; // good / moderate / low
  final double waterRequirementLitresPerAcre;
  final String irrigationAdvice;
  final List<double> weeklyMoisture; // last 7 days

  const SoilModel({
    required this.uid,
    required this.timestamp,
    required this.moistureLevel,
    required this.soilType,
    required this.irrigationMethod,
    required this.healthStatus,
    required this.waterRequirementLitresPerAcre,
    required this.irrigationAdvice,
    required this.weeklyMoisture,
  });

  factory SoilModel.fromMap(Map<String, dynamic> map) {
    return SoilModel(
      uid: map['uid'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      moistureLevel: (map['moistureLevel'] ?? 0).toDouble(),
      soilType: map['soilType'] ?? 'loamy',
      irrigationMethod: map['irrigationMethod'] ?? 'Drip irrigation',
      healthStatus: map['healthStatus'] ?? 'good',
      waterRequirementLitresPerAcre:
          (map['waterRequirementLitresPerAcre'] ?? 0).toDouble(),
      irrigationAdvice: map['irrigationAdvice'] ?? '',
      weeklyMoisture:
          ((map['weeklyMoisture'] as List?) ?? []).map((e) => (e as num).toDouble()).toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'timestamp': Timestamp.fromDate(timestamp),
        'moistureLevel': moistureLevel,
        'soilType': soilType,
        'irrigationMethod': irrigationMethod,
        'healthStatus': healthStatus,
        'waterRequirementLitresPerAcre': waterRequirementLitresPerAcre,
        'irrigationAdvice': irrigationAdvice,
        'weeklyMoisture': weeklyMoisture,
      };

  static SoilModel mock(String uid) => SoilModel(
        uid: uid,
        timestamp: DateTime.now(),
        moistureLevel: 62.0,
        soilType: 'Black cotton',
        irrigationMethod: 'Drip irrigation',
        healthStatus: 'moderate',
        waterRequirementLitresPerAcre: 1800,
        irrigationAdvice: 'Irrigation needed in 2 days. Monitor moisture levels.',
        weeklyMoisture: [55, 58, 60, 65, 62, 68, 62],
      );
}
