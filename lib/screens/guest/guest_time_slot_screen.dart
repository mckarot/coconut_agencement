import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../models/service_model.dart';

class GuestTimeSlotScreen extends StatefulWidget {
  final String artisanId;
  final DateTime selectedDay;
  final List<AppointmentModel> appointmentsForDay;
  final ServiceModel selectedService;

  const GuestTimeSlotScreen({
    super.key,
    required this.artisanId,
    required this.selectedDay,
    required this.appointmentsForDay,
    required this.selectedService,
  });

  @override
  State<GuestTimeSlotScreen> createState() => _GuestTimeSlotScreenState();
}

class _GuestTimeSlotScreenState extends State<GuestTimeSlotScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disponibilités'),
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
        child: SafeArea(
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
                  'Service: ${widget.selectedService.name}',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  'Durée: ${widget.selectedService.defaultDuration} minutes',
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
            widget.selectedDay.month,
            widget.selectedDay.day, hour, minute);

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
          selected: false,
          onSelected: isEnabled ? (_) => _showLoginRequiredDialog() : null,
          backgroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          disabledColor:
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color:
                  isEnabled ? theme.colorScheme.primary : Colors.transparent,
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

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connexion requise'),
        content: const Text(
            'Pour continuer, veuillez vous connecter ou créer un compte depuis la page d\'accueil.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    );
  }
}
