import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../providers/service_provider.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';

class AvailabilityScreen extends StatefulWidget {
  final String artisanId;
  final ServiceModel? selectedService;

  const AvailabilityScreen({super.key, required this.artisanId, this.selectedService});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<AppointmentModel>> _groupedAppointments = {};
  List<ServiceModel> _services = [];
  ServiceModel? _selectedService;
  TimeOfDay? _selectedTime;
  int _duration = 0; // Durée du rendez-vous en minutes

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedService = widget.selectedService;
    
    // Charger les rendez-vous et les services au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);
      
      // Charger les rendez-vous de l'artisan
      appointmentProvider.loadArtisanAppointments(widget.artisanId);
      
      // Charger les services
      serviceProvider.loadServices().then((_) {
        setState(() {
          _services = serviceProvider.services;
          // Si aucun service n'est pré-sélectionné, sélectionner le premier
          if (_selectedService == null && _services.isNotEmpty) {
            _selectedService = _services[0];
            _duration = _selectedService!.defaultDuration;
          } else if (_selectedService != null) {
            _duration = _selectedService!.defaultDuration;
          }
        });
      });
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
        title: const Text('Disponibilités de l\'artisan'),
      ),
      body: Column(
        children: [
          TableCalendar<AppointmentModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              // Style des cellules du calendrier
              outsideDaysVisible: true,
              markerSize: 5,
              markersMaxCount: 3,
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
            child: _buildAvailabilityView(),
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

  Widget _buildAvailabilityView() {
    if (_selectedDay == null) {
      return const Center(child: Text('Sélectionnez un jour pour voir les disponibilités'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sélectionnez un service :',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          DropdownButton<ServiceModel>(
            value: _selectedService,
            hint: const Text('Choisissez un service'),
            isExpanded: true,
            items: _services.map((service) {
              return DropdownMenuItem<ServiceModel>(
                value: service,
                child: Text(service.name),
              );
            }).toList(),
            onChanged: (ServiceModel? service) {
              setState(() {
                _selectedService = service;
                if (service != null) {
                  _duration = service.defaultDuration;
                }
              });
            },
          ),
          const SizedBox(height: 16.0),
          if (_selectedService != null) ...[
            Text(
              'Durée : $_duration minutes',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                _showDurationDialog();
              },
              child: const Text('Modifier la durée'),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Horaires disponibles (7h-19h) :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: _buildTimeSlots(),
            ),
          ],
        ],
      ),
    );
  }

  void _showDurationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempDuration = _duration;
        return AlertDialog(
          title: const Text('Modifier la durée'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Durée (minutes)',
                ),
                controller: TextEditingController(text: _duration.toString()),
                onChanged: (value) {
                  tempDuration = int.tryParse(value) ?? _duration;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _duration = tempDuration;
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeSlots() {
    List<Widget> timeSlots = [];
    
    // Générer les créneaux horaires de 7h à 19h
    for (int hour = 7; hour < 19; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final time = TimeOfDay(hour: hour, minute: minute);
        final isBooked = _isTimeSlotBooked(time);
        
        timeSlots.add(
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton(
              onPressed: isBooked ? null : () => _selectTimeSlot(time),
              style: ElevatedButton.styleFrom(
                backgroundColor: isBooked ? Colors.grey : null,
                foregroundColor: isBooked ? Colors.white : null,
                disabledBackgroundColor: Colors.grey,
                disabledForegroundColor: Colors.white,
              ),
              child: Text(
                '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ),
        );
      }
    }
    
    return GridView.count(
      crossAxisCount: 4,
      children: timeSlots,
    );
  }

  bool _isTimeSlotBooked(TimeOfDay time) {
    if (_selectedDay == null) return false;
    
    final appointments = _getEventsForDay(_selectedDay!);
    
    for (var appointment in appointments) {
      final appointmentTime = TimeOfDay(
        hour: appointment.dateTime.hour,
        minute: appointment.dateTime.minute,
      );
      
      // Vérifier si le créneau est déjà réservé
      if (appointmentTime == time) {
        return true;
      }
    }
    
    return false;
  }

  void _selectTimeSlot(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
    
    // Afficher une confirmation ou passer à l'étape suivante
    _showConfirmationDialog(time);
  }

  void _showConfirmationDialog(TimeOfDay time) {
    if (_selectedDay == null || _selectedService == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer le rendez-vous'),
          content: Text(
            'Voulez-vous réserver un rendez-vous pour le service "${_selectedService!.name}" le ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} à ${time.hour}:${time.minute.toString().padLeft(2, '0')} pour une durée de $_duration minutes ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _bookAppointment(time);
                Navigator.of(context).pop();
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void _bookAppointment(TimeOfDay time) async {
    if (_selectedDay == null || _selectedService == null) return;
    
    // Créer un objet DateTime à partir de la date sélectionnée et de l'heure
    final DateTime appointmentDateTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      time.hour,
      time.minute,
    );
    
    // Récupérer l'ID du client actuel
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clientId = authProvider.userId;
    
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Utilisateur non authentifié'),
        ),
      );
      return;
    }
    
    // Créer un nouveau rendez-vous
    final appointment = AppointmentModel(
      id: '', // L'ID sera généré par Firestore
      clientId: clientId,
      artisanId: widget.artisanId,
      serviceId: _selectedService!.id,
      dateTime: appointmentDateTime,
      duration: _duration,
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
    );
    
    // Enregistrer le rendez-vous
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    try {
      await appointmentProvider.createAppointment(appointment);
      
      // Récupérer les informations du client pour la notification
      final client = await userProvider.getUserById(clientId);
      final clientName = client?.name ?? client?.email ?? 'Client';
      
      // Envoyer une notification à l'artisan
      await notificationProvider.notifyArtisanOfNewAppointment(
        artisanId: widget.artisanId,
        clientName: clientName,
        appointmentDate: appointmentDateTime,
      );
      
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande de rendez-vous envoyée avec succès'),
        ),
      );
      
      // Retourner à l'écran précédent
      Navigator.of(context).pop();
    } catch (e) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la réservation: $e'),
        ),
      );
    }
  }
}