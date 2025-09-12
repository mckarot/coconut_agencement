import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/appointment_model.dart';
import '../../../models/service_model.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/user_provider.dart';

class ArtisanTimeSlotScreen extends StatefulWidget {
  final String clientId;
  final DateTime selectedDay;
  final List<AppointmentModel> appointmentsForDay;
  final ServiceModel selectedService;

  const ArtisanTimeSlotScreen({
    super.key,
    required this.clientId,
    required this.selectedDay,
    required this.appointmentsForDay,
    required this.selectedService,
  });

  @override
  State<ArtisanTimeSlotScreen> createState() => _ArtisanTimeSlotScreenState();
}

class _ArtisanTimeSlotScreenState extends State<ArtisanTimeSlotScreen> {
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
                const TextSpan(text: 'Créer un rendez-vous pour le service '),
                TextSpan(
                  text: '\"${widget.selectedService.name}\"',
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
    final artisanId = authProvider.userId;
    
    if (artisanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur: Artisan non identifié')),
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
      clientId: widget.clientId,
      artisanId: artisanId,
      serviceId: widget.selectedService.id,
      dateTime: appointmentDateTime,
      duration: widget.selectedService.defaultDuration,
      status: AppointmentStatus.confirmed, // Confirmé directement par l'artisan
      createdAt: DateTime.now(),
    );

    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.createAppointment(appointment);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final client = await userProvider.getUserById(widget.clientId);
      // final clientName = client?.name ?? 'Un client';

      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.notifyClientOfAppointmentStatus(
        clientId: widget.clientId,
        artisanName: 'Vous', // On pourrait récupérer le nom de l'artisan
        appointmentDate: appointmentDateTime,
        isConfirmed: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rendez-vous créé avec succès.')),
      );
      
      // Retour à l'écran d'accueil de l'artisan
      Navigator.of(context).popUntil(ModalRoute.withName('/home'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création: $e')),
      );
    }
  }
}