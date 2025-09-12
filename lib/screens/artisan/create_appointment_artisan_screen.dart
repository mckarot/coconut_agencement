import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/appointment_provider.dart';

class CreateAppointmentArtisanScreen extends StatefulWidget {
  const CreateAppointmentArtisanScreen({super.key});

  @override
  State<CreateAppointmentArtisanScreen> createState() =>
      _CreateAppointmentArtisanScreenState();
}

class _CreateAppointmentArtisanScreenState
    extends State<CreateAppointmentArtisanScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Variables d'état
  String? _selectedClientId;
  String? _selectedServiceId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _duration = 60;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Données
  List<UserModel> _clients = [];
  List<ServiceModel> _services = [];
  
  // Timezone
  late tz.Location _location;

  @override
  void initState() {
    super.initState();
    _initializeTimezone();
    _loadData();
  }

  void _initializeTimezone() {
    tz_data.initializeTimeZones();
    _location = tz.getLocation('America/Martinique');
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger les clients
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchClients();
      
      // Charger les services
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      await serviceProvider.loadServices();
      
      if (mounted) {
        setState(() {
          _clients = userProvider.clients;
          _services = serviceProvider.services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur de chargement: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une heure')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer l'utilisateur courant (artisan)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final artisanId = authProvider.userId;
      
      if (artisanId == null) {
        throw Exception('Artisan non identifié');
      }

      // Créer le DateTime avec le fuseau horaire
      final dateTime = tz.TZDateTime(
        _location,
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Créer le rendez-vous
      final appointment = AppointmentModel(
        id: '', // Sera généré par Firebase
        clientId: _selectedClientId!,
        artisanId: artisanId,
        serviceId: _selectedServiceId!,
        dateTime: dateTime,
        duration: _duration,
        status: AppointmentStatus.confirmed, // Confirmé directement
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sauvegarder le rendez-vous
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.createAppointment(appointment);

      if (mounted) {
        // Message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rendez-vous créé avec succès')),
        );
        
        // Retour à l'écran précédent
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un rendez-vous'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations du rendez-vous',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Sélection du client
                        DropdownButtonFormField<String>(
                          value: _selectedClientId,
                          decoration: const InputDecoration(
                            labelText: 'Client *',
                            border: OutlineInputBorder(),
                          ),
                          items: _clients.map((client) {
                            return DropdownMenuItem(
                              value: client.id,
                              child: Text(client.name ?? client.email),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClientId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner un client';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Sélection du service
                        DropdownButtonFormField<String>(
                          value: _selectedServiceId,
                          decoration: const InputDecoration(
                            labelText: 'Service *',
                            border: OutlineInputBorder(),
                          ),
                          items: _services.map((service) {
                            return DropdownMenuItem(
                              value: service.id,
                              child: Text(service.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedServiceId = value;
                              
                              // Mettre à jour la durée par défaut depuis le service
                              if (value != null) {
                                final service = _services.firstWhere(
                                  (s) => s.id == value,
                                  orElse: () => ServiceModel(
                                    id: '',
                                    name: '',
                                    description: '',
                                    defaultDuration: 60,
                                  ),
                                );
                                _duration = service.defaultDuration;
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner un service';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Sélection de la date
                        ListTile(
                          title: const Text('Date *'),
                          subtitle: Text(
                            _selectedDate == null
                                ? 'Sélectionner une date'
                                : DateFormat.yMMMMd('fr_FR').format(_selectedDate!),
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _selectDate(context),
                          tileColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Sélection de l'heure
                        ListTile(
                          title: const Text('Heure *'),
                          subtitle: Text(
                            _selectedTime == null
                                ? 'Sélectionner une heure'
                                : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: const Icon(Icons.access_time),
                          onTap: () => _selectTime(context),
                          tileColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Durée
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Durée (minutes) *',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _duration.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                _duration = int.tryParse(value) ?? _duration;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une durée';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Veuillez entrer un nombre valide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Bouton de soumission
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Créer le rendez-vous',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}