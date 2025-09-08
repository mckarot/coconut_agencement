import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_model.dart';
import '../providers/service_provider.dart';
import '../providers/auth_provider.dart';
import 'availability_screen.dart';

class ClientServiceSelectionScreen extends StatefulWidget {
  final String artisanId;

  const ClientServiceSelectionScreen({super.key, required this.artisanId});

  @override
  State<ClientServiceSelectionScreen> createState() =>
      _ClientServiceSelectionScreenState();
}

class _ClientServiceSelectionScreenState
    extends State<ClientServiceSelectionScreen> {
  List<ServiceModel> _services = [];
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
      setState(() {
        _services = serviceProvider.services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des services: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un service'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choisissez un service :',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(service.name),
                            subtitle: Text(service.description),
                            trailing:
                                Text('${service.defaultDuration} minutes'),
                            onTap: () {
                              setState(() {
                                _selectedService = service;
                              });
                              // Naviguer vers l'écran de disponibilité
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AvailabilityScreen(
                                    artisanId: widget.artisanId,
                                  ),
                                ),
                              );
                            },
                            selected: _selectedService?.id == service.id,
                            selectedTileColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_selectedService != null) ...[
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // Naviguer vers l'écran de disponibilité
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvailabilityScreen(
                              artisanId: widget.artisanId,
                            ),
                          ),
                        );
                      },
                      child: const Text('Voir les disponibilités'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}