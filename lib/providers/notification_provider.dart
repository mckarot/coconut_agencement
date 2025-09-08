import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Envoyer une notification à l'artisan lors d'une nouvelle demande
  Future<void> notifyArtisanOfNewAppointment({
    required String artisanId,
    required String clientName,
    required DateTime appointmentDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Dans une vraie application, nous récupérerions le token FCM de l'artisan
      // Ici, nous simulons l'envoi d'une notification locale
      await _notificationService.scheduleNotification(
        title: 'Nouvelle demande de rendez-vous',
        body:
            '$clientName a demandé un rendez-vous pour le ${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}',
        scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
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
    required String clientId,
    required String artisanName,
    required DateTime appointmentDate,
    required bool isConfirmed,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Dans une vraie application, nous récupérerions le token FCM du client
      // Ici, nous simulons l'envoi d'une notification locale
      String status = isConfirmed ? 'confirmé' : 'refusé';
      await _notificationService.scheduleNotification(
        title: 'Rendez-vous $status',
        body:
            'Votre rendez-vous avec $artisanName pour le ${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year} a été $status',
        scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de la notification: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}