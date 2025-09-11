import 'package:coconut_agencement/widgets/fade_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../artisan/availability_screen.dart';
import '../../widgets/service_card.dart';


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
      Navigator.push(
        context,
        FadeRoute(
          page: AvailabilityScreen(
            artisanId: widget.artisanId,
            selectedService: _selectedService!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nos Prestations'),
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
