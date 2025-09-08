import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/user_model.dart';
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
  Map<String, UserModel> _clientDetails = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<AppointmentModel> _selectedAppointments = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userId != null) {
        final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
        await appointmentProvider.loadArtisanAppointments(authProvider.userId!);
        await _loadClientDetails();
        if (mounted) {
          setState(() {
            _selectedAppointments = _getAppointmentsForDay(_selectedDay!);
          });
        }
      }
    });
  }

  Future<void> _loadClientDetails() async {
    if (!mounted) return;
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Map<String, UserModel> clientDetails = {};

    for (var appointment in appointmentProvider.appointments) {
      if (!clientDetails.containsKey(appointment.clientId)) {
        final client = await userProvider.getUserById(appointment.clientId);
        if (client != null) {
          clientDetails[appointment.clientId] = client;
        }
      }
    }
    if (mounted) {
      setState(() {
        _clientDetails = clientDetails;
      });
    }
  }

  List<AppointmentModel> _getAppointmentsForDay(DateTime day) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final localDay = day.toLocal();
    return appointmentProvider.appointments.where((appointment) {
      final appointmentDate = appointment.dateTime;
      return appointmentDate.year == localDay.year &&
          appointmentDate.month == localDay.month &&
          appointmentDate.day == localDay.day;
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedAppointments = _getAppointmentsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          if (appointmentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              TableCalendar<AppointmentModel>(
                locale: 'fr_FR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: _getAppointmentsForDay,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: _buildAppointmentList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentList() {
    if (_selectedAppointments.isEmpty) {
      return const Center(
        child: Text('Aucun rendez-vous pour ce jour.'),
      );
    }

    _selectedAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return ListView.builder(
      itemCount: _selectedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _selectedAppointments[index];
        final client = _clientDetails[appointment.clientId];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Text(client?.name ?? client?.email ?? 'Client inconnu'),
            subtitle: Text(
              DateFormat.Hm('fr_FR').format(appointment.dateTime),
            ),
            trailing: _buildStatusIndicator(appointment.status),
            onTap: () => _showAppointmentDetails(appointment),
          ),
        );
      },
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
              Text('Date: ${DateFormat.yMMMMd('fr_FR').format(appointment.dateTime)}'),
              Text('Heure: ${DateFormat.Hm('fr_FR').format(appointment.dateTime)}'),
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
