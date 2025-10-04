import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String username;
  final String? phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final String role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.phone,
    this.profileImageUrl,
    required this.createdAt,
    this.role = "user",
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: map['role'] ?? "user",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'role': role,
    };
  }

  bool get isAdmin => role == "admin";
}
