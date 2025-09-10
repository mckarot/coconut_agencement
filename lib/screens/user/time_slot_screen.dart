import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../models/service_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/user_provider.dart';

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
  ServiceModel? _selectedService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);
      await serviceProvider.loadServices();

      if (mounted) {
        setState(() {
          if (serviceProvider.services.isNotEmpty) {
            _selectedService = serviceProvider.services.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des services: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisissez un créneau'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.9),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        DateFormat.yMMMMd('fr_FR').format(widget.selectedDay),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Service: ${_selectedService?.name ?? 'Non sélectionné'}',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'Durée: ${_selectedService?.defaultDuration ?? 0} minutes',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Horaires disponibles',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildTimeSlotsGrid(),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTimeSlotsGrid() {
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(widget.selectedDay, now);
    final theme = Theme.of(context);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 24, // 12 hours * 2 slots per hour (7h to 19h)
      itemBuilder: (context, index) {
        final hour = 7 + (index ~/ 2);
        final minute = (index % 2) * 30;
        final time = TimeOfDay(hour: hour, minute: minute);

        final slotDateTime = DateTime(widget.selectedDay.year,
            widget.selectedDay.month, widget.selectedDay.day, hour, minute);

        final isBooked = _isTimeSlotBooked(time);
        final isPast = isToday && slotDateTime.isBefore(now);
        final bool isEnabled = !isBooked && !isPast;

        return ChoiceChip(
          label: Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: isEnabled
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          selected: false, // We handle selection via onTap
          onSelected: isEnabled ? (_) => _showConfirmationDialog(time) : null,
          backgroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          disabledColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: isEnabled
                  ? theme.colorScheme.primary
                  : Colors.transparent,
            ),
          ),
        );
      },
    );
  }

  bool _isTimeSlotBooked(TimeOfDay time) {
    final selectedDateTime = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      time.hour,
      time.minute,
    );

    for (var appointment in widget.appointmentsForDay) {
      final appointmentStart = appointment.dateTime;
      final appointmentEnd =
          appointmentStart.add(Duration(minutes: appointment.duration));

      if (selectedDateTime.isAtSameMomentAs(appointmentStart) ||
          (selectedDateTime.isAfter(appointmentStart) &&
              selectedDateTime.isBefore(appointmentEnd))) {
        return true;
      }
    }
    return false;
  }

  void _showConfirmationDialog(TimeOfDay time) {
    if (_selectedService == null) return;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Confirmer le rendez-vous'),
          content: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Réserver pour le service '),
                TextSpan(
                  text: '"${_selectedService!.name}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' le '),
                TextSpan(
                  text: DateFormat.yMMMMd('fr_FR').format(widget.selectedDay),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' à '),
                TextSpan(
                  text: time.format(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' ?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _bookAppointment(time);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
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
        const SnackBar(
            content: Text('Vous devez être connecté pour réserver.')),
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
      duration: _selectedService!.defaultDuration,
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.createAppointment(appointment);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final client = await userProvider.getUserById(authProvider.userId!);
      final clientName = client?.name ?? 'Un client';

      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.notifyArtisanOfNewAppointment(
        artisanId: widget.artisanId,
        clientName: clientName,
        appointmentDate: appointmentDateTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande de rendez-vous envoyée.')),
      );
      Navigator.of(context).popUntil(ModalRoute.withName('/client-home'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la réservation: $e')),
      );
    }
  }
}