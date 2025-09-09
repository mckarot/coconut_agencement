import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'appointments';

  // Récupérer tous les rendez-vous
  Stream<List<AppointmentModel>> getAppointments() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Récupérer les rendez-vous d'un client
  Future<List<AppointmentModel>> getClientAppointments(String clientId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .get();
    return snapshot.docs
        .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Récupérer les rendez-vous d'un artisan
  Future<List<AppointmentModel>> getArtisanAppointments(String artisanId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('artisanId', isEqualTo: artisanId)
        .get();
    return snapshot.docs
        .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Récupérer un rendez-vous par ID
  Future<AppointmentModel?> getAppointmentById(String appointmentId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection(_collection).doc(appointmentId).get();
      
      if (snapshot.exists) {
        return AppointmentModel.fromMap(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du rendez-vous: $e');
    }
  }

  // Créer un nouveau rendez-vous
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      // Vérifier les chevauchements
      final artisanAppointments = await getArtisanAppointments(appointment.artisanId);
      final newAppointmentStart = appointment.dateTime;
      final newAppointmentEnd = newAppointmentStart.add(Duration(minutes: appointment.duration));

      for (final existingAppointment in artisanAppointments) {
        if (DateUtils.isSameDay(existingAppointment.dateTime, newAppointmentStart)) {
          final existingAppointmentStart = existingAppointment.dateTime;
          final existingAppointmentEnd = existingAppointmentStart.add(Duration(minutes: existingAppointment.duration));

          if (newAppointmentStart.isBefore(existingAppointmentEnd) &&
              newAppointmentEnd.isAfter(existingAppointmentStart)) {
            throw Exception('Le créneau horaire est déjà pris.');
          }
        }
      }

      DocumentReference docRef =
          await _firestore.collection(_collection).add(appointment.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création du rendez-vous: $e');
    }
  }

  // Mettre à jour un rendez-vous
  Future<void> updateAppointment(
      String appointmentId, AppointmentModel appointment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointmentId)
          .update(appointment.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du rendez-vous: $e');
    }
  }

  // Supprimer un rendez-vous
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du rendez-vous: $e');
    }
  }
}