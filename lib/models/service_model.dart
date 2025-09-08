import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final int defaultDuration; // Durée par défaut en minutes

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultDuration,
  });

  // Créer un ServiceModel à partir d'un document Firestore
  factory ServiceModel.fromMap(Map<String, dynamic> data, String id) {
    return ServiceModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      defaultDuration: data['defaultDuration'] ?? 0,
    );
  }

  // Convertir un ServiceModel en map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'defaultDuration': defaultDuration,
    };
  }
}