import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String id; // ID de l'artisan
  final String? businessName; // Nom de l'entreprise
  final String? description; // Description des services
  final List<String>? photos; // URLs des photos de réalisations
  final String? address; // Adresse
  final String? phone; // Numéro de téléphone
  final String? email; // Email de contact

  ProfileModel({
    required this.id,
    this.businessName,
    this.description,
    this.photos,
    this.address,
    this.phone,
    this.email,
  });

  // Créer un ProfileModel à partir d'un document Firestore
  factory ProfileModel.fromMap(Map<String, dynamic> data, String id) {
    return ProfileModel(
      id: id,
      businessName: data['businessName'],
      description: data['description'],
      photos: List<String>.from(data['photos'] ?? []),
      address: data['address'],
      phone: data['phone'],
      email: data['email'],
    );
  }

  // Convertir un ProfileModel en map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'description': description,
      'photos': photos ?? [],
      'address': address,
      'phone': phone,
      'email': email,
    };
  }
}