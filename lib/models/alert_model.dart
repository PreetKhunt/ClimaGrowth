import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertType { flood, rain, storm, heatwave }
enum AlertSeverity { low, medium, high }

class AlertModel {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final String advice;
  final String region;
  final DateTime timestamp;

  const AlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.advice,
    required this.region,
    required this.timestamp,
  });

  factory AlertModel.fromMap(String id, Map<String, dynamic> map) {
    return AlertModel(
      id: id,
      type: _parseType(map['type'] ?? ''),
      severity: _parseSeverity(map['severity'] ?? ''),
      message: map['message'] ?? '',
      advice: map['advice'] ?? '',
      region: map['region'] ?? 'Padra',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'severity': severity.name,
        'message': message,
        'advice': advice,
        'region': region,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  static AlertType _parseType(String s) =>
      AlertType.values.firstWhere((e) => e.name == s, orElse: () => AlertType.rain);
  static AlertSeverity _parseSeverity(String s) =>
      AlertSeverity.values.firstWhere((e) => e.name == s, orElse: () => AlertSeverity.low);

  static List<AlertModel> mockAlerts() => [
        AlertModel(
          id: '1',
          type: AlertType.rain,
          severity: AlertSeverity.high,
          message: 'Heavy rainfall expected in next 24 hours',
          advice: 'Ensure drainage channels are clear. Harvest ready crops immediately.',
          region: 'Padra',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AlertModel(
          id: '2',
          type: AlertType.heatwave,
          severity: AlertSeverity.medium,
          message: 'Heat wave alert: Temperature may reach 42°C',
          advice: 'Increase irrigation frequency. Provide shade for sensitive crops.',
          region: 'Vadodara district',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AlertModel(
          id: '3',
          type: AlertType.storm,
          severity: AlertSeverity.low,
          message: 'Strong winds expected (50–60 km/h)',
          advice: 'Secure greenhouse structures. Stake tall crops to prevent lodging.',
          region: 'Padra, Savli',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
}
