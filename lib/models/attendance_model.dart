import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String userId;
  final String type;
  final GeoPoint location;
  final double distanceToTargetMeters;
  final Timestamp timestamp;
  final String? id;

  AttendanceModel({
    required this.userId,
    required this.type,
    required this.location,
    required this.distanceToTargetMeters,
    required this.timestamp,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'location': location,
      'distance': distanceToTargetMeters,
      'timestamp': timestamp,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as String?,
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      location: map['location'] ?? GeoPoint(0, 0),
      distanceToTargetMeters: map['distance'] ?? 0.0,
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}
