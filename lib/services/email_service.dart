import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/logger_service.dart';

class EmailService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<void> sendAppointmentRequestEmail({
    required String artisanEmail,
    required String clientName,
    required DateTime appointmentDate,
    required String serviceName,
    String? clientEmail,
    String? artisanName,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final HttpsCallable callable = _functions.httpsCallable(
        'sendAppointmentRequestEmail',
        options: HttpsCallableOptions(timeout: Duration(seconds: 30)),
      );

      await callable.call(<String, dynamic>{
        'artisanEmail': artisanEmail,
        'clientName': clientName,
        'appointmentDate': appointmentDate.toIso8601String(),
        'serviceName': serviceName,
        'clientEmail': clientEmail,
        'artisanName': artisanName,
      });

      LoggerService.info('Email de demande de rendez-vous envoyé avec succès');
    } catch (e) {
      LoggerService.error('Erreur lors de l\'envoi de l\'email de demande: $e');
      rethrow;
    }
  }

  static Future<void> sendAppointmentStatusEmail({
    required String clientEmail,
    required String artisanName,
    required DateTime appointmentDate,
    required String serviceName,
    required bool isConfirmed,
    String? clientName,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final HttpsCallable callable = _functions.httpsCallable(
        'sendAppointmentStatusEmail',
        options: HttpsCallableOptions(timeout: Duration(seconds: 30)),
      );

      await callable.call(<String, dynamic>{
        'clientEmail': clientEmail,
        'artisanName': artisanName,
        'appointmentDate': appointmentDate.toIso8601String(),
        'serviceName': serviceName,
        'isConfirmed': isConfirmed,
        'clientName': clientName,
      });

      LoggerService.info('Email de statut de rendez-vous envoyé avec succès');
    } catch (e) {
      LoggerService.error('Erreur lors de l\'envoi de l\'email de statut: $e');
      rethrow;
    }
  }
}