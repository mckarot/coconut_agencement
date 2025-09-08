import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { pending, confirmed, rejected }

class AppointmentModel {
  final String id;
  final String clientId;
  final String artisanId;
  final String serviceId;
  final DateTime dateTime;
  final int duration; // Durée en minutes
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.artisanId,
    required this.serviceId,
    required this.dateTime,
    required this.duration,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  // Créer un AppointmentModel à partir d'un document Firestore
  factory AppointmentModel.fromMap(Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      clientId: data['clientId'] ?? '',
      artisanId: data['artisanId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      duration: data['duration'] ?? 0,
      status: _statusFromString(data['status'] ?? ''),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convertir un AppointmentModel en map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'artisanId': artisanId,
      'serviceId': serviceId,
      'dateTime': Timestamp.fromDate(dateTime),
      'duration': duration,
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Convertir une chaîne en AppointmentStatus
  static AppointmentStatus _statusFromString(String status) {
    switch (status) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'rejected':
        return AppointmentStatus.rejected;
      default:
        return AppointmentStatus.pending;
    }
  }

  // Convertir un AppointmentStatus en chaîne
  static String _statusToString(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.rejected:
        return 'rejected';
      default:
        return 'pending';
    }
  }
}