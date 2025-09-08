import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  final bool isArtisanView; // true pour l'artisan, false pour le client

  const AppointmentHistoryScreen({super.key, required this.isArtisanView});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  List<AppointmentModel> _appointments = [];
  Map<String, UserModel> _userDetails = {};
  bool _isLoading = true;
  AppointmentStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Charger les rendez-vous en fonction du rôle de l'utilisateur
      if (widget.isArtisanView) {
        await appointmentProvider.loadArtisanAppointments(authProvider.userId!);
      } else {
        await appointmentProvider.loadClientAppointments(authProvider.userId!);
      }

      List<AppointmentModel> filteredAppointments = appointmentProvider.appointments;

      // Appliquer le filtre par statut si nécessaire
      if (_filterStatus != null) {
        filteredAppointments = filteredAppointments
            .where((appointment) => appointment.status == _filterStatus)
            .toList();
      }

      // Charger les détails des utilisateurs (clients pour les artisans, artisans pour les clients)
      Map<String, UserModel> userDetails = {};
      for (var appointment in filteredAppointments) {
        String userId = widget.isArtisanView
            ? appointment.clientId
            : appointment.artisanId;
            
        if (!userDetails.containsKey(userId)) {
          final user = await userProvider.getUserById(userId);
          if (user != null) {
            userDetails[userId] = user;
          }
        }
      }

      setState(() {
        _appointments = filteredAppointments;
        _userDetails = userDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors du chargement des rendez-vous: $e')),
        );
      }
    }
  }

  void _filterAppointments(AppointmentStatus? status) {
    setState(() {
      _filterStatus = status;
    });
    _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isArtisanView
            ? 'Historique des rendez-vous clients'
            : 'Mes rendez-vous'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres par statut
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tous'),
                        selected: _filterStatus == null,
                        onSelected: (selected) =>
                            _filterAppointments(null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Confirmés'),
                        selected: _filterStatus == AppointmentStatus.confirmed,
                        onSelected: (selected) => _filterAppointments(
                            selected ? AppointmentStatus.confirmed : null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Refusés'),
                        selected: _filterStatus == AppointmentStatus.rejected,
                        onSelected: (selected) => _filterAppointments(
                            selected ? AppointmentStatus.rejected : null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('En attente'),
                        selected: _filterStatus == AppointmentStatus.pending,
                        onSelected: (selected) => _filterAppointments(
                            selected ? AppointmentStatus.pending : null),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Liste des rendez-vous
                Expanded(
                  child: _appointments.isEmpty
                      ? const Center(
                          child: Text('Aucun rendez-vous trouvé'),
                        )
                      : ListView.builder(
                          itemCount: _appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _appointments[index];
                            final user = _userDetails[
                                widget.isArtisanView
                                    ? appointment.clientId
                                    : appointment.artisanId];

                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(user?.name ??
                                    user?.email ??
                                    (widget.isArtisanView
                                        ? 'Client inconnu'
                                        : 'Artisan inconnu')),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year} à ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}',
                                    ),
                                    Text(
                                      'Durée: ${appointment.duration} minutes',
                                    ),
                                  ],
                                ),
                                trailing: _buildStatusIndicator(
                                    appointment.status),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
        text = 'Refusé';
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
}