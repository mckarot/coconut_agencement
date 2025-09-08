import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;

  // Charger tous les rendez-vous
  Future<void> loadAppointments() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      _appointmentService.getAppointments().listen((appointments) {
        _appointments = appointments;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors du chargement des rendez-vous: $e');
    }
  }

  // Charger les rendez-vous d'un client
  Future<void> loadClientAppointments(String clientId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      _appointmentService.getClientAppointments(clientId).listen((appointments) {
        _appointments = appointments;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors du chargement des rendez-vous du client: $e');
    }
  }

  // Charger les rendez-vous d'un artisan
  Future<void> loadArtisanAppointments(String artisanId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      _appointmentService.getArtisanAppointments(artisanId).listen((appointments) {
        _appointments = appointments;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors du chargement des rendez-vous de l\'artisan: $e');
    }
  }

  // Récupérer un rendez-vous par ID
  Future<AppointmentModel?> getAppointmentById(String appointmentId) async {
    try {
      return await _appointmentService.getAppointmentById(appointmentId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du rendez-vous: $e');
    }
  }

  // Créer un nouveau rendez-vous
  Future<void> createAppointment(AppointmentModel appointment) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _appointmentService.createAppointment(appointment);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors de la création du rendez-vous: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Mettre à jour un rendez-vous
  Future<void> updateAppointment(
      String appointmentId, AppointmentModel appointment) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _appointmentService.updateAppointment(appointmentId, appointment);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors de la mise à jour du rendez-vous: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Supprimer un rendez-vous
  Future<void> deleteAppointment(String appointmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _appointmentService.deleteAppointment(appointmentId);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors de la suppression du rendez-vous: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
}