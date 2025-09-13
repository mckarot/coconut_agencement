import 'package:flutter/material.dart';
import '../services/local_notification_service.dart';
import '../services/email_service.dart';

class NotificationProvider with ChangeNotifier {
  final LocalNotificationService _localNotificationService = 
      LocalNotificationService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Envoyer une notification à l'artisan lors d'une nouvelle demande
  Future<void> notifyArtisanOfNewAppointment({
    required String artisanEmail,
    required String clientName,
    required DateTime appointmentDate,
    required String serviceName,
    String? clientEmail,
    String? artisanName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Envoyer notification locale
      await _localNotificationService.scheduleNotification(
        title: 'Nouvelle demande de rendez-vous',
        body:
            '$clientName a demandé un rendez-vous pour le ${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}',
        scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
      );

      // Envoyer email à l'artisan
      await EmailService.sendAppointmentRequestEmail(
        artisanEmail: artisanEmail,
        clientName: clientName,
        appointmentDate: appointmentDate,
        serviceName: serviceName,
        clientEmail: clientEmail,
        artisanName: artisanName,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de la notification: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Envoyer une notification au client lorsqu'un rendez-vous est confirmé/refusé
  Future<void> notifyClientOfAppointmentStatus({
    required String clientEmail,
    required String artisanName,
    required DateTime appointmentDate,
    required String serviceName,
    required bool isConfirmed,
    String? clientName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Envoyer notification locale
      String status = isConfirmed ? 'confirmé' : 'refusé';
      await _localNotificationService.scheduleNotification(
        title: 'Rendez-vous $status',
        body:
            'Votre rendez-vous avec $artisanName pour le ${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year} a été $status',
        scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
      );

      // Envoyer email au client
      await EmailService.sendAppointmentStatusEmail(
        clientEmail: clientEmail,
        artisanName: artisanName,
        appointmentDate: appointmentDate,
        serviceName: serviceName,
        isConfirmed: isConfirmed,
        clientName: clientName,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de la notification: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
