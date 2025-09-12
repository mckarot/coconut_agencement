import 'dart:async';

import 'package:coconut_agencement/models/service_model.dart';
import 'package:coconut_agencement/providers/service_provider.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ArtisanPlanningScreen extends StatefulWidget {
  const ArtisanPlanningScreen({super.key});

  @override
  State<ArtisanPlanningScreen> createState() => _ArtisanPlanningScreenState();
}

class _ArtisanPlanningScreenState extends State<ArtisanPlanningScreen> {
  Map<String, UserModel> _clientDetails = {};
  Map<String, ServiceModel> _serviceDetails = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Timer? _timer;
  DateTime _now = DateTime.now();
  bool _isLoading = true;
  String? _errorMessage;
  Map<DateTime, List<AppointmentModel>> _appointmentsByDay = {};
  tz.Location? _location;
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  @override
  void initState() {
    super.initState();
    _initializeTimezoneAndLoadData();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeTimezoneAndLoadData() async {
    try {
      tz_data.initializeTimeZones();
      _location = tz.getLocation('America/Martinique');
      final nowInLocation = tz.TZDateTime.from(DateTime.now(), _location!);
      _focusedDay = nowInLocation;
      _selectedDay = nowInLocation;
      await _loadArtisanAppointments();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur d'initialisation: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadArtisanAppointments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final artisanId = authProvider.userId;

    if (artisanId == null) {
      setState(() {
        _errorMessage = "Artisan non connecté.";
        _isLoading = false;
      });
      return;
    }

    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);

      final appointments =
          await appointmentProvider.getArtisanAppointments(artisanId);

      final clientDetails = <String, UserModel>{};
      final serviceDetails = <String, ServiceModel>{};

      for (var appointment in appointments) {
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
          _clientDetails = clientDetails;
          _serviceDetails = serviceDetails;
          _groupAppointments(appointments);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              "Erreur de chargement des rendez-vous: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  void _groupAppointments(List<AppointmentModel> appointments) {
    final groupedAppointments = <DateTime, List<AppointmentModel>>{};
    for (var appointment in appointments) {
      final appointmentDate =
          tz.TZDateTime.from(appointment.dateTime, _location!);
      final dateKey = DateTime.utc(
          appointmentDate.year, appointmentDate.month, appointmentDate.day);
      if (groupedAppointments[dateKey] == null) {
        groupedAppointments[dateKey] = [];
      }
      groupedAppointments[dateKey]!.add(appointment);
    }
    _appointmentsByDay = groupedAppointments;
  }

  List<AppointmentModel> _getAppointmentsForDay(DateTime day) {
    final dateKey = DateTime.utc(day.year, day.month, day.day);
    return _appointmentsByDay[dateKey] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSelectedAppointments =
        _getAppointmentsForDay(_selectedDay ?? _focusedDay);
    final selectedAppointments = allSelectedAppointments
        .where((appt) => appt.status != AppointmentStatus.rejected)
        .toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    TableCalendar<AppointmentModel>(
                      locale: 'fr_FR',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: _onDaySelected,
                      eventLoader: (day) {
                        return _getAppointmentsForDay(day)
                            .where((appt) =>
                                appt.status != AppointmentStatus.rejected)
                            .toList();
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isEmpty) return null;
                          
                          // Compter les différents types de réservations
                          int slotCount = 0;
                          int morningCount = 0;
                          int afternoonCount = 0;
                          int fullDayCount = 0;
                          final hasPending = events.any((appointment) =>
                              appointment.status == AppointmentStatus.pending);
                          
                          for (var appointment in events) {
                            switch (appointment.type) {
                              case AppointmentType.slot:
                                slotCount++;
                                break;
                              case AppointmentType.morning:
                                morningCount++;
                                break;
                              case AppointmentType.afternoon:
                                afternoonCount++;
                                break;
                              case AppointmentType.fullDay:
                                fullDayCount++;
                                break;
                            }
                          }
                          
                          List<Widget> markers = [];
                          
                          // Ajouter des marqueurs pour chaque type de réservation
                          if (fullDayCount > 0) {
                            markers.add(
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.red,
                                ),
                                child: Center(
                                  child: Text(
                                    fullDayCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          if (morningCount > 0) {
                            markers.add(
                              Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.orange,
                                ),
                                child: Center(
                                  child: Text(
                                    morningCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          if (afternoonCount > 0) {
                            markers.add(
                              Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.blue,
                                ),
                                child: Center(
                                  child: Text(
                                    afternoonCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          if (slotCount > 0) {
                            markers.add(
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasPending ? Colors.red : Colors.blueAccent,
                                ),
                              ),
                            );
                          }
                          
                          return Positioned(
                            left: 0,
                            right: 0,
                            bottom: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: markers,
                            ),
                          );
                        },
                      ),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                            color: Colors.blueAccent, shape: BoxShape.circle),
                        selectedDecoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            shape: BoxShape.circle),
                      ),
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      headerStyle: const HeaderStyle(
                          formatButtonVisible: true, titleCentered: true),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: _buildTimeline(selectedAppointments),
                    ),
                  ],
                ),
      
    );
  }

  Widget _buildTimeline(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return const Center(child: Text('Aucun rendez-vous pour ce jour.'));
    }

    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    const double hourHeight = 80.0;
    const int startHour = 7;
    const int endHour = 21;
    final double timelineHeight = (endHour - startHour + 1) * hourHeight;

    final today = _location != null ? tz.TZDateTime.from(DateTime.now(), _location!) : DateTime.now();
    final isTodaySelected = _selectedDay != null &&
        _selectedDay!.year == today.year &&
        _selectedDay!.month == today.month &&
        _selectedDay!.day == today.day;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        height: timelineHeight,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(double.infinity, timelineHeight),
              painter: TimelinePainter(
                  hourHeight: hourHeight,
                  startHour: startHour,
                  endHour: endHour),
            ),
            ..._buildHourLabels(hourHeight, startHour, endHour),
            ..._buildAppointmentItems(appointments, hourHeight, startHour),
            if (isTodaySelected)
              _buildCurrentTimeIndicator(hourHeight, startHour),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHourLabels(double hourHeight, int startHour, int endHour) {
    List<Widget> labels = [];
    for (int i = startHour; i <= endHour; i++) {
      final y = (i - startHour) * hourHeight;
      labels.add(
        Positioned(
          top: y - 8, // Center text vertically on the line
          left: 0,
          child: SizedBox(
            width: 50,
            child: Text(
              '${i.toString().padLeft(2, '0')}:00',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      );
    }
    return labels;
  }

  List<Widget> _buildAppointmentItems(
      List<AppointmentModel> appointments, double hourHeight, int startHour) {
    List<Widget> items = [];
    
    for (var appointment in appointments) {
      final localDateTime =
          tz.TZDateTime.from(appointment.dateTime, _location!);
      
      // Pour les réservations de type journée entière, matin ou après-midi,
      // nous affichons un indicateur spécial
      if (appointment.type == AppointmentType.fullDay || 
          appointment.type == AppointmentType.morning || 
          appointment.type == AppointmentType.afternoon) {
        
        String periodText = '';
        double top = 0;
        double height = 0;
        
        switch (appointment.type) {
          case AppointmentType.morning:
            periodText = 'Matin (8h-12h)';
            top = (8 - startHour) * hourHeight;
            height = 4 * hourHeight;
            break;
          case AppointmentType.afternoon:
            periodText = 'Après-midi (13h-19h)';
            top = (13 - startHour) * hourHeight;
            height = 6 * hourHeight;
            break;
          case AppointmentType.fullDay:
            periodText = 'Journée entière';
            top = (8 - startHour) * hourHeight;
            height = 11 * hourHeight;
            break;
          default:
            periodText = '';
            top = ((localDateTime.hour - startHour) * hourHeight) +
                (localDateTime.minute / 60.0 * hourHeight);
            height = (appointment.duration / 60.0) * hourHeight;
        }
        
        final client = _clientDetails[appointment.clientId];
        final service = _serviceDetails[appointment.serviceId];
        final cardColor = appointment.status == AppointmentStatus.pending
            ? Colors.red.withOpacity(0.8)
            : Theme.of(context).primaryColor.withOpacity(0.8);
        
        items.add(
          Positioned(
            top: top,
            left: 70.0,
            right: 0,
            height: height,
            child: GestureDetector(
              onTap: () => _showAppointmentDetails(appointment),
              child: Card(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        client?.name ?? client?.email ?? 'Client inconnu',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        service?.name ?? 'Service inconnu',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        periodText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Statut: ${appointment.status.toString().split('.').last}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        // Pour les créneaux standards
        final double top = ((localDateTime.hour - startHour) * hourHeight) +
            (localDateTime.minute / 60.0 * hourHeight);
        final double height = (appointment.duration / 60.0) * hourHeight;
        final client = _clientDetails[appointment.clientId];
        final service = _serviceDetails[appointment.serviceId];
        final cardColor = appointment.status == AppointmentStatus.pending
            ? Colors.red.withOpacity(0.8)
            : Theme.of(context).primaryColor.withOpacity(0.8);

        items.add(
          Positioned(
            top: top,
            left: 70.0,
            right: 0,
            height: height,
            child: GestureDetector(
              onTap: () => _showAppointmentDetails(appointment),
              child: Card(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                client?.name ?? client?.email ?? 'Client inconnu',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Expanded(
                              child: Text(
                                service?.name ?? 'Service inconnu',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${DateFormat.Hm('fr_FR').format(localDateTime)} - ${DateFormat.Hm('fr_FR').format(localDateTime.add(Duration(minutes: appointment.duration)))}',
                          style:
                              const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return items;
  }

  Widget _buildCurrentTimeIndicator(double hourHeight, int startHour) {
    final now = tz.TZDateTime.from(_now, _location!);
    final double minutesFromStart =
        (now.hour - startHour) * 60.0 + now.minute;
    final double top = minutesFromStart / 60.0 * hourHeight;

    if (top < 0 || top > (21 - startHour + 1) * hourHeight) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: top,
      left: 60,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration:
                const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
          Expanded(
            child: Container(height: 2, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
    final client = _clientDetails[appointment.clientId];
    final service = _serviceDetails[appointment.serviceId];
    final localDateTime =
        tz.TZDateTime.from(appointment.dateTime, _location!);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Détails du rendez-vous',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16.0),
                Text('Client: ${client?.name ?? 'Non trouvé'}'),
                Text('Email: ${client?.email ?? 'Non trouvé'}'),
                const Divider(height: 20),
                Text('Service: ${service?.name ?? 'Non trouvé'}'),
                Text(
                    'Date: ${DateFormat.yMMMMd('fr_FR').format(localDateTime)}'),
                Text('Heure: ${DateFormat.Hm('fr_FR').format(localDateTime)}'),
                if (appointment.type != AppointmentType.slot)
                  Text('Période: ${_getPeriodText(appointment.type)}'),
                Text('Durée: ${appointment.duration} minutes'),
                Text(
                    'Statut: ${appointment.status.toString().split('.').last}'),
                const SizedBox(height: 16.0),
                if (appointment.status == AppointmentStatus.pending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateAppointmentStatus(
                            appointment, AppointmentStatus.confirmed),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.black),
                        child: const Text('Confirmer'),
                      ),
                      ElevatedButton(
                        onPressed: () => _updateAppointmentStatus(
                            appointment, AppointmentStatus.rejected),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.black),
                        child: const Text('Rejeter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPeriodText(AppointmentType type) {
    switch (type) {
      case AppointmentType.morning:
        return 'Matin (8h-12h)';
      case AppointmentType.afternoon:
        return 'Après-midi (13h-19h)';
      case AppointmentType.fullDay:
        return 'Journée entière';
      default:
        return '';
    }
  }

  Future<void> _updateAppointmentStatus(
      AppointmentModel appointment, AppointmentStatus status) async {
    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final updatedAppointment =
          appointment.copyWith(status: status, updatedAt: DateTime.now());
      await appointmentProvider.updateAppointment(
          appointment.id, updatedAppointment);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Rendez-vous ${status == AppointmentStatus.confirmed ? 'confirmé' : 'rejeté'}')),
        );
        _loadArtisanAppointments(); // Refresh the list
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

class TimelinePainter extends CustomPainter {
  final double hourHeight;
  final int startHour;
  final int endHour;

  TimelinePainter({
    required this.hourHeight,
    required this.startHour,
    required this.endHour,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    for (int i = startHour; i <= endHour; i++) {
      final y = (i - startHour) * hourHeight;
      canvas.drawLine(Offset(60, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

extension AppointmentModelCopy on AppointmentModel {
  AppointmentModel copyWith({
    AppointmentStatus? status,
    AppointmentType? type,
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
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}