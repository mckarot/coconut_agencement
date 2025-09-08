import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../models/appointment_model.dart';
import '../providers/user_provider.dart';

class ArtisanPlanningScreen extends StatefulWidget {
  const ArtisanPlanningScreen({super.key});

  @override
  State<ArtisanPlanningScreen> createState() => _ArtisanPlanningScreenState();
}

class _ArtisanPlanningScreenState extends State<ArtisanPlanningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userId != null) {
        Provider.of<AppointmentProvider>(context, listen: false)
            .loadArtisanAppointments(authProvider.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Planning'),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          if (appointmentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appointmentProvider.appointments.isEmpty) {
            return const Center(child: Text('Aucun rendez-vous programmé.'));
          }

          // Trier les rendez-vous par date
          final sortedAppointments = List<AppointmentModel>.from(appointmentProvider.appointments);
          sortedAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

          return ListView.builder(
            itemCount: sortedAppointments.length,
            itemBuilder: (context, index) {
              final appointment = sortedAppointments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(
                    '${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year} à ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}',
                  ),
                  subtitle: Text(
                    'Durée: ${appointment.duration} min - Statut: ${appointment.status.toString().split('.').last}',
                  ),
                  trailing: _buildStatusIndicator(appointment.status),
                  onTap: () => _showAppointmentDetails(appointment),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(AppointmentStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case AppointmentStatus.confirmed:
        color = Colors.green;
        text = 'Confirmé';
        break;
      case AppointmentStatus.rejected:
        color = Colors.red;
        text = 'Rejeté';
        break;
      default:
        color = Colors.orange;
        text = 'En attente';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12.0),
      ),
    );
  }

  void _showAppointmentDetails(AppointmentModel appointment) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final client = await userProvider.getUserById(appointment.clientId);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Détails du rendez-vous',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              Text('Client: ${client?.name ?? 'Non trouvé'}'),
              Text('Email: ${client?.email ?? 'Non trouvé'}'),
              const Divider(height: 20),
              Text('Date: ${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year}'),
              Text('Heure: ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}'),
              Text('Durée: ${appointment.duration} minutes'),
              Text('Statut: ${appointment.status.toString().split('.').last}'),
              const SizedBox(height: 16.0),
              if (appointment.status == AppointmentStatus.pending)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _updateAppointmentStatus(appointment, AppointmentStatus.confirmed),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Confirmer'),
                    ),
                    ElevatedButton(
                      onPressed: () => _updateAppointmentStatus(appointment, AppointmentStatus.rejected),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Rejeter'),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateAppointmentStatus(AppointmentModel appointment, AppointmentStatus status) async {
    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      
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

      await appointmentProvider.updateAppointment(
          appointment.id, updatedAppointment);

      if (mounted) {
        Navigator.pop(context);
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }
}
