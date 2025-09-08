import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../models/user_model.dart';

class PendingAppointmentsScreen extends StatefulWidget {
  const PendingAppointmentsScreen({super.key});

  @override
  State<PendingAppointmentsScreen> createState() =>
      _PendingAppointmentsScreenState();
}

class _PendingAppointmentsScreenState extends State<PendingAppointmentsScreen> {
  List<AppointmentModel> _pendingAppointments = [];
  Map<String, UserModel> _clientDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingAppointments();
  }

  Future<void> _loadPendingAppointments() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Charger les rendez-vous en attente de l'artisan
      await appointmentProvider.loadArtisanAppointments(authProvider.userId!);

      // Filtrer les rendez-vous en attente
      final pendingAppointments = appointmentProvider.appointments
          .where((appointment) => appointment.status == AppointmentStatus.pending)
          .toList();

      // Charger les détails des clients
      Map<String, UserModel> clientDetails = {};
      for (var appointment in pendingAppointments) {
        if (!clientDetails.containsKey(appointment.clientId)) {
          final client = await userProvider.getUserById(appointment.clientId);
          if (client != null) {
            clientDetails[appointment.clientId] = client;
          }
        }
      }

      setState(() {
        _pendingAppointments = pendingAppointments;
        _clientDetails = clientDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des rendez-vous: $e')),
        );
      }
    }
  }

  Future<void> _updateAppointmentStatus(
      AppointmentModel appointment, AppointmentStatus status) async {
    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Créer un objet AppointmentModel mis à jour
      final updatedAppointment = AppointmentModel(
        id: appointment.id,
        clientId: appointment.clientId,
        artisanId: appointment.artisanId,
        serviceId: appointment.serviceId,
        dateTime: appointment.dateTime,
        duration: appointment.duration,
        status: status,
        createdAt: appointment.createdAt,
        updatedAt: DateTime.now(),
      );

      // Mettre à jour le rendez-vous
      await appointmentProvider.updateAppointment(
          appointment.id, updatedAppointment);

      // Envoyer une notification au client
      final artisan = await userProvider.getUserById(authProvider.userId!);
      final artisanName = artisan?.name ?? artisan?.email ?? 'Artisan';
      
      final client = _clientDetails[appointment.clientId];
      if (client != null) {
        await notificationProvider.notifyClientOfAppointmentStatus(
          clientId: appointment.clientId,
          artisanName: artisanName,
          appointmentDate: appointment.dateTime,
          isConfirmed: status == AppointmentStatus.confirmed,
        );
      }

      // Rafraîchir la liste
      await _loadPendingAppointments();

      if (mounted) {
        String statusText = status == AppointmentStatus.confirmed
            ? 'confirmé'
            : 'rejeté';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Rendez-vous $statusText avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes en attente'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingAppointments.isEmpty
              ? const Center(
                  child: Text('Aucune demande de rendez-vous en attente'),
                )
              : ListView.builder(
                  itemCount: _pendingAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _pendingAppointments[index];
                    final client = _clientDetails[appointment.clientId];

                    return Card(
                      key: ValueKey(appointment.id),
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                            client?.name ?? client?.email ?? 'Client inconnu'),
                        subtitle: Text(
                          '${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year} à ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}Durée: ${appointment.duration} minutes',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _updateAppointmentStatus(
                                  appointment, AppointmentStatus.confirmed),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _updateAppointmentStatus(
                                  appointment, AppointmentStatus.rejected),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}