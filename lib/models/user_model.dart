import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final Timestamp createdAt;
  // gonna use later bruh
  final String? faceEmbeddingUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'basic',
    required this.createdAt,
    this.faceEmbeddingUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': createdAt,
      'faceEmbeddingUrl': faceEmbeddingUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'basic',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      faceEmbeddingUrl: map['faceEmbeddingUrl'],
    );
  }
}
