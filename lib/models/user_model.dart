import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum UserRole { client, artisan }

class UserModel {
  final String id;
  final String email;
  final UserRole role;
  final String? name;
  final String? phone;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phone,
  });

  // Create a UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      role: data['role'] == 'artisan' ? UserRole.artisan : UserRole.client,
      name: data['name'],
      phone: data['phone'],
    );
  }

  // Convert UserModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role == UserRole.artisan ? 'artisan' : 'client',
      'name': name,
      'phone': phone,
    };
  }
  
  // Méthode copyWith pour faciliter les mises à jour
  UserModel copyWith({
    String? email,
    UserRole? role,
    String? name,
    String? phone,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}