import 'package:coconut_agencement/models/service_model.dart';
import 'package:coconut_agencement/providers/service_provider.dart';
import 'package:coconut_agencement/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../availability_screen.dart';
import '../../../widgets/service_card.dart';

class ArtisanServiceSelectionScreen extends StatefulWidget {
  final String clientId;

  const ArtisanServiceSelectionScreen({super.key, required this.clientId});

  @override
  State<ArtisanServiceSelectionScreen> createState() =>
      _ArtisanServiceSelectionScreenState();
}

class _ArtisanServiceSelectionScreenState
    extends State<ArtisanServiceSelectionScreen> {
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
      if (mounted) {
        setState(() {
          _services = serviceProvider.services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des services: $e')),
        );
      }
    }
  }

  void _navigateToAvailability() {
    if (_selectedService != null) {
      // Obtenir l'ID de l'artisan courant
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final artisanId = authProvider.userId;
      
      if (artisanId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvailabilityScreen(
              artisanId: artisanId,
              selectedService: _selectedService!,
            ),
            settings: RouteSettings(
              arguments: {
                'clientId': widget.clientId, // Passer le clientId sélectionné
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Artisan non identifié')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection du service'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
                      child: Text(
                        'Choisissez un service',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return ServiceCard(
                            key: ValueKey(service.id), // Ajout d'une clé unique
                            service: service,
                            isSelected: _selectedService?.id == service.id,
                            onTap: () {
                              setState(() {
                                _selectedService = service;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: _selectedService != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToAvailability,
              label: const Text('Voir les disponibilités'),
              icon: const Icon(Icons.arrow_forward),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}