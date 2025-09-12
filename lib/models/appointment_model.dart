import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { pending, confirmed, rejected }

// Type de réservation
enum AppointmentType { slot, morning, afternoon, fullDay }

class AppointmentModel {
  final String id;
  final String clientId;
  final String artisanId;
  final String serviceId;
  final DateTime dateTime;
  final int duration; // Durée en minutes
  final AppointmentStatus status;
  final AppointmentType type; // Type de réservation
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
    this.type = AppointmentType.slot, // Par défaut, c'est un créneau standard
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
      type: _typeFromString(data['type'] ?? 'slot'),
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
      'type': _typeToString(type),
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

  // Convertir une chaîne en AppointmentType
  static AppointmentType _typeFromString(String type) {
    switch (type) {
      case 'morning':
        return AppointmentType.morning;
      case 'afternoon':
        return AppointmentType.afternoon;
      case 'fullDay':
        return AppointmentType.fullDay;
      default:
        return AppointmentType.slot;
    }
  }

  // Convertir un AppointmentType en chaîne
  static String _typeToString(AppointmentType type) {
    switch (type) {
      case AppointmentType.morning:
        return 'morning';
      case AppointmentType.afternoon:
        return 'afternoon';
      case AppointmentType.fullDay:
        return 'fullDay';
      default:
        return 'slot';
    }
  }
}