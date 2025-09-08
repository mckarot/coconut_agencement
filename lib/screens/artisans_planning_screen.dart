import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../models/appointment_model.dart';
import '../providers/user_provider.dart';
import 'dart:collection';

class ArtisanPlanningScreen extends StatefulWidget {
  const ArtisanPlanningScreen({super.key});

  @override
  State<ArtisanPlanningScreen> createState() => _ArtisanPlanningScreenState();
}

class _ArtisanPlanningScreenState extends State<ArtisanPlanningScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<AppointmentModel>> _groupedAppointments = {};
  Map<DateTime, List<AppointmentModel>> _blockedPeriods = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Charger les rendez-vous au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      appointmentProvider.loadArtisanAppointments(authProvider.userId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    // Regrouper les rendez-vous par date
    if (!appointmentProvider.isLoading && appointmentProvider.appointments.isNotEmpty) {
      _groupedAppointments = groupAppointmentsByDate(appointmentProvider.appointments);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Planning'),
        actions: [
          IconButton(
            onPressed: _addBlockedPeriod,
            icon: const Icon(Icons.block),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<AppointmentModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            rangeSelectionMode: RangeSelectionMode.toggledOff,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              // Style des cellules du calendrier
              outsideDaysVisible: true,
              markerSize: 5,
              markersMaxCount: 3,
              // Marquer les périodes bloquées
              selectedDecoration: BoxDecoration(
                color: Colors.red.withOpacity(0.5),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildPlanningView(),
          ),
        ],
      ),
    );
  }

  List<AppointmentModel> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _groupedAppointments[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  Map<DateTime, List<AppointmentModel>> groupAppointmentsByDate(
      List<AppointmentModel> appointments) {
    Map<DateTime, List<AppointmentModel>> grouped = {};
    
    for (var appointment in appointments) {
      final date = DateTime(
        appointment.dateTime.year,
        appointment.dateTime.month,
        appointment.dateTime.day,
      );
      
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(appointment);
    }
    
    return grouped;
  }

  Widget _buildPlanningView() {
    if (_selectedDay == null) {
      return const Center(child: Text('Sélectionnez un jour pour voir votre planning'));
    }

    final appointments = _getEventsForDay(_selectedDay!);
    
    // Vérifier si la journée est bloquée
    final isBlocked = _isDayBlocked(_selectedDay!);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBlocked) ...[
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.red.withOpacity(0.2),
              child: const Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8.0),
                  Text(
                    'Journée bloquée',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],
          const Text(
            'Rendez-vous prévus :',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          if (appointments.isEmpty)
            const Text('Aucun rendez-vous pour cette date')
          else
            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(
                        '${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')} - ${appointment.duration} min',
                      ),
                      subtitle: Text(
                        appointment.status.toString().split('.').last,
                      ),
                      trailing: _buildStatusIndicator(appointment.status),
                      onTap: () => _showAppointmentDetails(appointment),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  bool _isDayBlocked(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _blockedPeriods.containsKey(normalizedDay);
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

  void _showAppointmentDetails(AppointmentModel appointment) {
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
              Text('Date: ${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year}'),
              Text('Heure: ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}'),
              Text('Durée: ${appointment.duration} minutes'),
              Text('Statut: ${appointment.status.toString().split('.').last}'),
              const SizedBox(height: 16.0),
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
      final userProvider = Provider.of<UserProvider>(context, listen: false);
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
      
      // Note: Pour envoyer une vraie notification au client, nous aurions besoin
      // d'implémenter un système de notification push. Pour cette démonstration,
      // nous utilisons un SnackBar.
      
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

  void _addBlockedPeriod() {
    // Cette méthode sera implémentée dans une prochaine étape
    // Elle permettra de bloquer une période
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de blocage de période à implémenter'),
      ),
    );
  }
}