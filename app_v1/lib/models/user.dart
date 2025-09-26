import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class User {
  final ObjectId id;
  final String email;
  final String hashedPassword;
  final String name;
  final String role; // e.g., 'collector', 'admin'
  final DateTime createdAt;

  User({
    ObjectId? id,
    required this.email,
    required this.hashedPassword,
    required this.name,
    required this.role,
    DateTime? createdAt,
  }) : id = id ?? ObjectId(),
       createdAt = createdAt ?? DateTime.now();

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] as ObjectId,
      email: map['email'] as String,
      hashedPassword: map['hashedPassword'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      createdAt: map['createdAt'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'email': email,
      'hashedPassword': hashedPassword,
      'name': name,
      'role': role,
      'createdAt': createdAt,
    };
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
