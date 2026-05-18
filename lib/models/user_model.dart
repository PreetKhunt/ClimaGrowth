import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String mobile;
  final String email;
  final GeoPoint? farmLocation;
  final String village;
  final double farmSizeAcres;
  final String language; // en / gu / hi
  final String theme;    // light / dark
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.mobile,
    required this.email,
    this.farmLocation,
    this.village = 'Padra',
    this.farmSizeAcres = 1.0,
    this.language = 'en',
    this.theme = 'light',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      farmLocation: map['farmLocation'] as GeoPoint?,
      village: map['village'] ?? 'Padra',
      farmSizeAcres: (map['farmSizeAcres'] ?? 1.0).toDouble(),
      language: map['language'] ?? 'en',
      theme: map['theme'] ?? 'light',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'mobile': mobile,
        'email': email,
        'farmLocation': farmLocation,
        'village': village,
        'farmSizeAcres': farmSizeAcres,
        'language': language,
        'theme': theme,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? mobile,
    String? email,
    GeoPoint? farmLocation,
    String? village,
    double? farmSizeAcres,
    String? language,
    String? theme,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      farmLocation: farmLocation ?? this.farmLocation,
      village: village ?? this.village,
      farmSizeAcres: farmSizeAcres ?? this.farmSizeAcres,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      createdAt: createdAt,
    );
  }
}
