import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';


class CalendarScreen extends StatefulWidget {
  final bool isArtisanView; // true pour l'artisan, false pour le client

  const CalendarScreen({super.key, required this.isArtisanView});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  Map<DateTime, List<AppointmentModel>> _groupedAppointments = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Charger les rendez-vous au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (widget.isArtisanView) {
        appointmentProvider.loadArtisanAppointments(authProvider.userId!);
      } else {
        appointmentProvider.loadClientAppointments(authProvider.userId!);
      }
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
        title: Text(widget.isArtisanView 
            ? 'Mon Planning' 
            : 'Disponibilités de l\'artisan'),
      ),
      body: Column(
        children: [
          TableCalendar<AppointmentModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(4).map((appointment) {
                      return Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor(appointment.status),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            headerStyle: const HeaderStyle(
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
            child: _buildAppointmentsList(),
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

  Widget _buildAppointmentsList() {
    if (_selectedDay == null) {
      return const Center(child: Text('Sélectionnez un jour pour voir les rendez-vous'));
    }

    final appointments = _getEventsForDay(_selectedDay!);
    
    if (appointments.isEmpty) {
      return const Center(child: Text('Aucun rendez-vous pour cette date'));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(
              '${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}',
            ),
            subtitle: Text(
              '${appointment.duration} min',
            ),
            trailing: _buildStatusIndicator(appointment.status),
          ),
        );
      },
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.rejected:
        return Colors.red;
      case AppointmentStatus.pending:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusIndicator(AppointmentStatus status) {
    String text;
    
    switch (status) {
      case AppointmentStatus.confirmed:
        text = 'Confirmé';
        break;
      case AppointmentStatus.rejected:
        text = 'Rejeté';
        break;
      default:
        text = 'En attente';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12.0),
      ),
    );
  }
}

