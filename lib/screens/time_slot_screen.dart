import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/service_provider.dart';
import '../providers/user_provider.dart';

class TimeSlotScreen extends StatefulWidget {
  final String artisanId;
  final DateTime selectedDay;
  final List<AppointmentModel> appointmentsForDay;

  const TimeSlotScreen({
    super.key,
    required this.artisanId,
    required this.selectedDay,
    required this.appointmentsForDay,
  });

  @override
  State<TimeSlotScreen> createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends State<TimeSlotScreen> {
  List<ServiceModel> _services = [];
  ServiceModel? _selectedService;
  int _duration = 0;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      await serviceProvider.loadServices();

      if (mounted) {
        setState(() {
          _services = serviceProvider.services;
          if (_services.isNotEmpty) {
            _selectedService = _services[0];
            _duration = _selectedService!.defaultDuration;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des services: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choisissez un créneau'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rendez-vous pour le ${DateFormat.yMMMMd('fr_FR').format(widget.selectedDay)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Sélectionnez un service :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _buildTimeSlots() {
    List<Widget> timeSlots = [];
    for (int hour = 7; hour < 19; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final time = TimeOfDay(hour: hour, minute: minute);
        final isBooked = _isTimeSlotBooked(time);

        timeSlots.add(
          ElevatedButton(
            onPressed: isBooked ? null : () => _showConfirmationDialog(time),
            style: ElevatedButton.styleFrom(
              backgroundColor: isBooked ? Colors.grey : null,
            ),
            child: Text('${time.hour}:${time.minute.toString().padLeft(2, '0')}'),
          ),
        );
      }
    }
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: timeSlots,
    );
  }

  bool _isTimeSlotBooked(TimeOfDay time) {
    for (var appointment in widget.appointmentsForDay) {
      final appointmentTime = TimeOfDay.fromDateTime(appointment.dateTime);
      if (appointmentTime.hour == time.hour && appointmentTime.minute == time.minute) {
        return true;
      }
    }
    return false;
  }

  void _showConfirmationDialog(TimeOfDay time) {
    if (_selectedService == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer le rendez-vous'),
          content: Text(
            'Réserver pour "${_selectedService!.name}" le ${DateFormat.yMMMMd('fr_FR').format(widget.selectedDay)} à ${time.format(context)} pour une durée de $_duration minutes ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _bookAppointment(time);
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _bookAppointment(TimeOfDay time) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour réserver.')),
      );
      return;
    }

    final appointmentDateTime = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      time.hour,
      time.minute,
    );

    final appointment = AppointmentModel(
      id: '',
      clientId: authProvider.userId!,
      artisanId: widget.artisanId,
      serviceId: _selectedService!.id,
      dateTime: appointmentDateTime,
      duration: _duration,
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.createAppointment(appointment);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final client = await userProvider.getUserById(authProvider.userId!);
      final clientName = client?.name ?? 'Un client';

      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.notifyArtisanOfNewAppointment(
        artisanId: widget.artisanId,
        clientName: clientName,
        appointmentDate: appointmentDateTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande de rendez-vous envoyée.')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la réservation: $e')),
      );
    }
  }
}
