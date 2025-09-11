import 'package:coconut_agencement/screens/guest/guest_time_slot_screen.dart';
import 'package:coconut_agencement/widgets/fade_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/appointment_model.dart';
import '../../models/service_model.dart';
import '../../providers/appointment_provider.dart';

class GuestAvailabilityScreen extends StatefulWidget {
  final String artisanId;
  final ServiceModel selectedService;

  const GuestAvailabilityScreen(
      {super.key, required this.artisanId, required this.selectedService});

  @override
  State<GuestAvailabilityScreen> createState() => _GuestAvailabilityScreenState();
}

class _GuestAvailabilityScreenState extends State<GuestAvailabilityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<AppointmentModel>> _groupedAppointments = {};

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
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
      final date = DateTime.utc(appointment.dateTime.year,
          appointment.dateTime.month, appointment.dateTime.day);
      if (_groupedAppointments[date] == null) {
        _groupedAppointments[date] = [];
      }
      _groupedAppointments[date]!.add(appointment);
    }
  }

  List<AppointmentModel> _getAppointmentsForDay(DateTime day) {
    return _groupedAppointments[DateTime.utc(day.year, day.month, day.day)] ??
        [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    if (selectedDate.isBefore(today)) {
      return;
    }

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    Navigator.push(
      context,
      FadeRoute(
        page: GuestTimeSlotScreen(
          artisanId: widget.artisanId,
          selectedDay: selectedDay,
          appointmentsForDay: _getAppointmentsForDay(selectedDay),
          selectedService: widget.selectedService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF5C6BC0),
                shape: BoxShape.circle,
              ),
            ),
            enabledDayPredicate: (day) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final date = DateTime(day.year, day.month, day.day);
              return !date.isBefore(today);
            },
          );
        },
      ),
    );
  }
}
