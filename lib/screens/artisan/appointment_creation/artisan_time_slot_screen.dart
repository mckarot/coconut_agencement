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
                const SizedBox(height: 24),
                Text(
                  'Options de réservation',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildReservationOptions(),
                const SizedBox(height: 16),
                Text(
                  'Ou choisissez un créneau horaire',
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

  Widget _buildReservationOptions() {
    final theme = Theme.of(context);
    final isSunday = widget.selectedDay.weekday == DateTime.sunday;
    
    // Vérifier si les demi-journées ou la journée entière sont déjà réservées
    final isMorningBooked = _isMorningBooked();
    final isAfternoonBooked = _isAfternoonBooked();
    final isFullDayBooked = _isFullDayBooked();
    
    return Column(
      children: [
        // Matin (8h-12h)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSunday || isMorningBooked 
                ? null 
                : () => _showConfirmationDialogForPeriod(AppointmentType.morning),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSunday || isMorningBooked
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primary,
              foregroundColor: isSunday || isMorningBooked
                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                  : theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isSunday 
                  ? 'Fermé le dimanche' 
                  : isMorningBooked 
                      ? 'Matin indisponible' 
                      : 'Réserver le matin (8h-12h)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Après-midi (13h-19h)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSunday || isAfternoonBooked 
                ? null 
                : () => _showConfirmationDialogForPeriod(AppointmentType.afternoon),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSunday || isAfternoonBooked
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primary,
              foregroundColor: isSunday || isAfternoonBooked
                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                  : theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isSunday 
                  ? 'Fermé le dimanche' 
 : isAfternoonBooked
 ? 'Après-midi indisponible'
 : 'Réserver l\'après-midi (13h-19h)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Journée entière
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSunday || isFullDayBooked 
                ? null 
                : () => _showConfirmationDialogForPeriod(AppointmentType.fullDay),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSunday || isFullDayBooked
                  ? theme.colorScheme.surfaceContainerHighest
                  : Colors.orangeAccent,
              foregroundColor: isSunday || isFullDayBooked
                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                  : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isSunday 
                  ? 'Fermé le dimanche' 
                  : isFullDayBooked 
                      ? 'Journée indisponible' 
                      : 'Réserver la journée entière',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
          onSelected: isEnabled ? (_) => _showConfirmationDialogForSlot(time) : null,
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
      // Si une réservation de type journée entière existe, tous les créneaux sont bloqués
      if (appointment.type == AppointmentType.fullDay) {
        return true;
      }
      
      // Si une réservation de type matin existe, bloquer les créneaux de 8h à 12h
      if (appointment.type == AppointmentType.morning && time.hour >= 8 && time.hour < 12) {
        return true;
      }
      
      // Si une réservation de type après-midi existe, bloquer les créneaux de 13h à 19h
      if (appointment.type == AppointmentType.afternoon && time.hour >= 13 && time.hour < 19) {
        return true;
      }

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

  bool _isMorningBooked() {
    // Vérifier s'il y a déjà une réservation pour le matin (8h-12h)
    for (var appointment in widget.appointmentsForDay) {
      // Si une réservation de type journée entière existe, le matin est bloqué
      if (appointment.type == AppointmentType.fullDay) {
        return true;
      }
      
      // Si une réservation de type matin existe
      if (appointment.type == AppointmentType.morning) {
        return true;
      }
      
      // Si une réservation classique existe dans la plage du matin
      final startHour = appointment.dateTime.hour;
      final endHour = startHour + (appointment.duration ~/ 60);
      if ((startHour >= 8 && startHour < 12) || (endHour > 8 && endHour <= 12)) {
        return true;
      }
    }
    return false;
  }

  bool _isAfternoonBooked() {
    // Vérifier s'il y a déjà une réservation pour l'après-midi (13h-19h)
    for (var appointment in widget.appointmentsForDay) {
      // Si une réservation de type journée entière existe, l'après-midi est bloqué
      if (appointment.type == AppointmentType.fullDay) {
        return true;
      }
      
      // Si une réservation de type après-midi existe
      if (appointment.type == AppointmentType.afternoon) {
        return true;
      }
      
      // Si une réservation classique existe dans la plage de l'après-midi
      final startHour = appointment.dateTime.hour;
      final endHour = startHour + (appointment.duration ~/ 60);
      if ((startHour >= 13 && startHour < 19) || (endHour > 13 && endHour <= 19)) {
        return true;
      }
    }
    return false;
  }

  bool _isFullDayBooked() {
    // Vérifier s'il y a déjà une réservation pour la journée entière
    for (var appointment in widget.appointmentsForDay) {
      // Si une réservation de type journée entière, matin ou après-midi existe
      if (appointment.type == AppointmentType.fullDay || 
          appointment.type == AppointmentType.morning || 
          appointment.type == AppointmentType.afternoon) {
        return true;
      }
    }
    return false;
  }

  void _showConfirmationDialogForSlot(TimeOfDay time) {
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
                _bookAppointmentForSlot(time);
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

  void _showConfirmationDialogForPeriod(AppointmentType type) {
    final theme = Theme.of(context);
    String periodText = '';
    String timeText = '';
    
    switch (type) {
      case AppointmentType.morning:
        periodText = 'le matin';
        timeText = '(8h-12h)';
        break;
 case AppointmentType.afternoon:
 periodText = 'l\'après-midi';
 timeText = '(13h-19h)';
 break;
 case AppointmentType.fullDay:
        periodText = 'la journée entière';
        timeText = '';
        break;
      default:
        periodText = '';
        timeText = '';
    }

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
                TextSpan(text: ' $periodText '),
                if (timeText.isNotEmpty)
                  TextSpan(
                    text: timeText,
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
                _bookAppointmentForPeriod(type);
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

  Future<void> _bookAppointmentForSlot(TimeOfDay time) async {
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
      type: AppointmentType.slot, // Créneau standard
      createdAt: DateTime.now(),
    );

    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.createAppointment(appointment);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // ignore: unused_local_variable
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

  Future<void> _bookAppointmentForPeriod(AppointmentType type) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final artisanId = authProvider.userId;
    
    if (artisanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur: Artisan non identifié')),
      );
      return;
    }

    // Définir l'heure de début selon le type de réservation
    late DateTime appointmentDateTime;
    late int duration;
    
    switch (type) {
      case AppointmentType.morning:
        appointmentDateTime = DateTime(
          widget.selectedDay.year,
          widget.selectedDay.month,
          widget.selectedDay.day,
          8, // 8h du matin
          0,
        );
        duration = 4 * 60; // 4 heures en minutes
        break;
      case AppointmentType.afternoon:
        appointmentDateTime = DateTime(
          widget.selectedDay.year,
          widget.selectedDay.month,
          widget.selectedDay.day,
          13, // 13h de l'après-midi
          0,
        );
        duration = 6 * 60; // 6 heures en minutes
        break;
      case AppointmentType.fullDay:
        appointmentDateTime = DateTime(
          widget.selectedDay.year,
          widget.selectedDay.month,
          widget.selectedDay.day,
          8, // 8h du matin
          0,
        );
        duration = 11 * 60; // 11 heures en minutes (8h à 19h)
        break;
      default:
        appointmentDateTime = DateTime(
          widget.selectedDay.year,
          widget.selectedDay.month,
          widget.selectedDay.day,
          8,
          0,
        );
        duration = widget.selectedService.defaultDuration;
    }

    final appointment = AppointmentModel(
      id: '',
      clientId: widget.clientId,
      artisanId: artisanId,
      serviceId: widget.selectedService.id,
      dateTime: appointmentDateTime,
      duration: duration,
      status: AppointmentStatus.confirmed, // Confirmé directement par l'artisan
      type: type, // Type de réservation
      createdAt: DateTime.now(),
    );

    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.createAppointment(appointment);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // ignore: unused_local_variable
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