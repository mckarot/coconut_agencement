import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  final bool isArtisanView;

  const AppointmentHistoryScreen({super.key, required this.isArtisanView});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  List<AppointmentModel> _appointments = [];
  Map<String, UserModel> _userDetails = {};
  bool _isLoading = true;
  AppointmentStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (authProvider.userId == null) {
        throw Exception("Utilisateur non connecté.");
      }

      if (widget.isArtisanView) {
        await appointmentProvider.loadArtisanAppointments(authProvider.userId!);
      } else {
        await appointmentProvider.loadClientAppointments(authProvider.userId!);
      }

      List<AppointmentModel> filteredAppointments =
          appointmentProvider.appointments;

      if (_filterStatus != null) {
        filteredAppointments = filteredAppointments
            .where((appointment) => appointment.status == _filterStatus)
            .toList();
      }

      Map<String, UserModel> userDetails = {};
      for (var appointment in filteredAppointments) {
        String userId = widget.isArtisanView
            ? appointment.clientId
            : appointment.artisanId;
        if (!userDetails.containsKey(userId)) {
          final user = await userProvider.getUserById(userId);
          if (user != null) {
            userDetails[userId] = user;
          }
        }
      }

      // Trier les rendez-vous du plus proche au plus lointain dans le temps
      filteredAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      if (mounted) {
        setState(() {
          _appointments = filteredAppointments;
          _userDetails = userDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur de chargement des rendez-vous: $e')),
        );
      }
    }
  }

  void _filterAppointments(AppointmentStatus? status) {
    setState(() {
      _filterStatus = status;
    });
    _loadAppointments();
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le rendez-vous'),
        content: const Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
        await appointmentProvider.deleteAppointment(appointmentId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rendez-vous annulé avec succès.')),
        );
        _loadAppointments(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'annulation: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterChips(theme),
                Expanded(
                  child: _appointments.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildAppointmentsList(theme),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildFilterChip(theme, 'Tous', null),
          _buildFilterChip(
              theme, 'Confirmés', AppointmentStatus.confirmed),
          _buildFilterChip(theme, 'Refusés', AppointmentStatus.rejected),
          _buildFilterChip(theme, 'En attente', AppointmentStatus.pending),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      ThemeData theme, String label, AppointmentStatus? status) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => _filterAppointments(status),
        selectedColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        final user = _userDetails[
            widget.isArtisanView ? appointment.clientId : appointment.artisanId];

        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(
              user?.name ?? user?.email ?? 'Utilisateur inconnu',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMMd('fr_FR').add_Hm().format(appointment.dateTime),
                ),
                Text('Durée: ${appointment.duration} minutes'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIndicator(appointment.status, theme),
                if (!widget.isArtisanView)
                  IconButton(
                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                    onPressed: () => _deleteAppointment(appointment.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun rendez-vous trouvé',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(AppointmentStatus status, ThemeData theme) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case AppointmentStatus.confirmed:
        color = Colors.green;
        text = 'Confirmé';
        icon = Icons.check_circle;
        break;
      case AppointmentStatus.rejected:
        color = Colors.red;
        text = 'Refusé';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        text = 'En attente';
        icon = Icons.hourglass_top;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 12.0),
        ),
      ],
    );
  }
}
