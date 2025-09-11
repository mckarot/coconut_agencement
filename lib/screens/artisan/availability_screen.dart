import 'package:coconut_agencement/widgets/fade_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../user/time_slot_screen.dart';

class AvailabilityScreen extends StatefulWidget {
  final String artisanId;

  const AvailabilityScreen({super.key, required this.artisanId});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<AppointmentModel>> _groupedAppointments = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.loadArtisanAppointments(widget.artisanId);
      if (mounted) {
        setState(() {
          _groupAppointments(appointmentProvider.appointments);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des rendez-vous: $e")),
        );
      }
    }
  }

  void _groupAppointments(List<AppointmentModel> appointments) {
    _groupedAppointments = {};
    for (var appointment in appointments) {
      final date = DateTime.utc(appointment.dateTime.year, appointment.dateTime.month, appointment.dateTime.day);
      if (_groupedAppointments[date] == null) {
        _groupedAppointments[date] = [];
      }
      _groupedAppointments[date]!.add(appointment);
    }
  }

  List<AppointmentModel> _getAppointmentsForDay(DateTime day) {
    return _groupedAppointments[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      Navigator.push(
        context,
        FadeRoute(
          page: TimeSlotScreen(
            artisanId: widget.artisanId,
            selectedDay: selectedDay,
            appointmentsForDay: _getAppointmentsForDay(selectedDay),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clientId = authProvider.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisissez une date'),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          if (appointmentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          _groupAppointments(appointmentProvider.appointments);
          return TableCalendar<AppointmentModel>(
            locale: 'fr_FR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              final appointments = _getAppointmentsForDay(day);
              return appointments
                  .where((appointment) => appointment.clientId == clientId)
                  .toList();
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          );
        },
      ),
    );
  }
}
