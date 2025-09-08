import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceService _serviceService = ServiceService();
  List<ServiceModel> _services = [];
  bool _isLoading = false;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;

  // Charger tous les services
  Future<void> loadServices() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      _serviceService.getServices().listen((services) {
        _services = services;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors du chargement des services: $e');
    }
  }

  // Récupérer un service par ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      return await _serviceService.getServiceById(serviceId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du service: $e');
    }
  }

  // Créer un nouveau service
  Future<void> createService(ServiceModel service) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      await _serviceService.createService(service);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors de la création du service: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Mettre à jour un service
  Future<void> updateService(String serviceId, ServiceModel service) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      await _serviceService.updateService(serviceId, service);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors de la mise à jour du service: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Supprimer un service
  Future<void> deleteService(String serviceId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      await _serviceService.deleteService(serviceId);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erreur lors de la suppression du service: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
}