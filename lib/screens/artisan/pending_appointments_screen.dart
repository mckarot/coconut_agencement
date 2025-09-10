import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../models/service_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/user_model.dart';

class PendingAppointmentsScreen extends StatefulWidget {
  const PendingAppointmentsScreen({super.key});

  @override
  State<PendingAppointmentsScreen> createState() =>
      _PendingAppointmentsScreenState();
}

class _PendingAppointmentsScreenState extends State<PendingAppointmentsScreen> {
  List<AppointmentModel> _pendingAppointments = [];
  Map<String, UserModel> _clientDetails = {};
  Map<String, ServiceModel> _serviceDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingAppointments();
  }

  Future<void> _loadPendingAppointments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);

      if (authProvider.userId == null) {
        throw Exception("Utilisateur non connecté.");
      }

      await appointmentProvider.loadArtisanAppointments(authProvider.userId!);

      final pendingAppointments = appointmentProvider.appointments
          .where((appointment) => appointment.status == AppointmentStatus.pending)
          .toList();

      Map<String, UserModel> clientDetails = {};
      Map<String, ServiceModel> serviceDetails = {};
      for (var appointment in pendingAppointments) {
        if (!clientDetails.containsKey(appointment.clientId)) {
          final client = await userProvider.getUserById(appointment.clientId);
          if (client != null) {
            clientDetails[appointment.clientId] = client;
          }
        }
        if (!serviceDetails.containsKey(appointment.serviceId)) {
          final service =
              await serviceProvider.getServiceById(appointment.serviceId);
          if (service != null) {
            serviceDetails[appointment.serviceId] = service;
          }
        }
      }

      if (mounted) {
        setState(() {
          _pendingAppointments = pendingAppointments;
          _clientDetails = clientDetails;
          _serviceDetails = serviceDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors du chargement des rendez-vous: $e')),
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
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final updatedAppointment = appointment.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      await appointmentProvider.updateAppointment(
          appointment.id, updatedAppointment);

      final artisan = await userProvider.getUserById(authProvider.userId!);
      final artisanName = artisan?.name ?? artisan?.email ?? 'Artisan';

      await notificationProvider.notifyClientOfAppointmentStatus(
        clientId: appointment.clientId,
        artisanName: artisanName,
        appointmentDate: appointment.dateTime,
        isConfirmed: status == AppointmentStatus.confirmed,
      );

      await _loadPendingAppointments();

      if (mounted) {
        String statusText =
            status == AppointmentStatus.confirmed ? 'confirmé' : 'rejeté';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rendez-vous $statusText avec succès')),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingAppointments.isEmpty
              ? _buildEmptyState(theme)
              : _buildAppointmentsList(theme),
    );
  }

  Widget _buildAppointmentsList(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadPendingAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _pendingAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _pendingAppointments[index];
          final client = _clientDetails[appointment.clientId];
          final service = _serviceDetails[appointment.serviceId];

          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client?.name ?? client?.email ?? 'Client inconnu',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (service != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      theme,
                      Icons.calendar_today,
                      DateFormat.yMMMMd('fr_FR')
                          .add_Hm()
                          .format(appointment.dateTime)),
                  const SizedBox(height: 8),
                  _buildInfoRow(theme, Icons.timer_outlined,
                      '${appointment.duration} minutes'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Rejeter',
                            style: TextStyle(color: Colors.red)),
                        onPressed: () => _updateAppointmentStatus(
                            appointment, AppointmentStatus.rejected),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _updateAppointmentStatus(
                            appointment, AppointmentStatus.confirmed),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.secondary),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add_check,
            size: 80,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune demande en attente',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Les nouvelles demandes de rendez-vous apparaîtront ici.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

extension AppointmentModelCopy on AppointmentModel {
  AppointmentModel copyWith({
    AppointmentStatus? status,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id,
      clientId: clientId,
      artisanId: artisanId,
      serviceId: serviceId,
      dateTime: dateTime,
      duration: duration,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
