import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_provider.dart';
import '../providers/user_provider.dart';

class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  UserModel? _selectedClient;
  ServiceModel? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchClients();
      Provider.of<ServiceProvider>(context, listen: false).loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un rendez-vous'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClientDropdown(),
                const SizedBox(height: 20),
                _buildServiceDropdown(),
                const SizedBox(height: 20),
                _buildDateTimePicker(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Créer le rendez-vous'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientDropdown() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading && userProvider.clients.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userProvider.clients.isEmpty) {
          return const Text('Aucun client trouvé.');
        }
        return DropdownButtonFormField<UserModel>(
          initialValue: _selectedClient,
          hint: const Text('Sélectionner un client'),
          onChanged: (client) {
            setState(() {
              _selectedClient = client;
            });
          },
          items: userProvider.clients.map((client) {
            return DropdownMenuItem(
              value: client,
              child: Text(client.name ?? client.email),
            );
          }).toList(),
          validator: (value) =>
              value == null ? 'Veuillez sélectionner un client' : null,
        );
      },
    );
  }

  Widget _buildServiceDropdown() {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        if (serviceProvider.isLoading && serviceProvider.services.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return DropdownButtonFormField<ServiceModel>(
          initialValue: _selectedService,
          hint: const Text('Sélectionner un service'),
          onChanged: (service) {
            setState(() {
              _selectedService = service;
            });
          },
          items: serviceProvider.services.map((service) {
            return DropdownMenuItem(
              value: service,
              child: Text(service.name),
            );
          }).toList(),
          validator: (value) =>
              value == null ? 'Veuillez sélectionner un service' : null,
        );
      },
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _selectedDate != null
                    ? DateFormat.yMd('fr_FR').format(_selectedDate!)
                    : 'Sélectionner une date',
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _selectedTime = time;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Heure',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Sélectionner une heure',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final appointment = AppointmentModel(
        id: '',
        clientId: _selectedClient!.id,
        artisanId: authProvider.userId!,
        serviceId: _selectedService!.id,
        dateTime: appointmentDateTime,
        duration: _selectedService!.defaultDuration,
        status: AppointmentStatus.confirmed, // Confirmed by default
        createdAt: DateTime.now(),
      );

      await appointmentProvider.createAppointment(appointment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rendez-vous créé avec succès')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}