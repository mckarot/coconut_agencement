import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'services';

  // Récupérer tous les services
  Stream<List<ServiceModel>> getServices() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Récupérer un service par ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection(_collection).doc(serviceId).get();
      
      if (snapshot.exists) {
        return ServiceModel.fromMap(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du service: $e');
    }
  }

  // Créer un nouveau service
  Future<String> createService(ServiceModel service) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(_collection).add(service.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création du service: $e');
    }
  }

  // Mettre à jour un service
  Future<void> updateService(String serviceId, ServiceModel service) async {
    try {
      await _firestore.collection(_collection).doc(serviceId).update(service.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du service: $e');
    }
  }

  // Supprimer un service
  Future<void> deleteService(String serviceId) async {
    try {
      await _firestore.collection(_collection).doc(serviceId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du service: $e');
    }
  }
}