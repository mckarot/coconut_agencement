import 'package:coconut_agencement/widgets/fade_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServices();
    });
  }

  Future<void> _loadServices() async {
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    await serviceProvider.loadServices();
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: serviceProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : serviceProvider.services.isEmpty
              ? _buildEmptyState(theme, authProvider.userId)
              : _buildServicesList(
                  theme, serviceProvider.services, authProvider.userId),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (authProvider.userId != null) {
            Navigator.push(
              context,
              FadeRoute(
                page: AddServiceScreen(artisanId: authProvider.userId!),
              ),
            ).then((_) => _loadServices());
          }
        },
        label: const Text('Ajouter un service'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildServicesList(
      ThemeData theme, List<ServiceModel> services, String? artisanId) {
    return RefreshIndicator(
      onRefresh: _loadServices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: services.length,
        itemBuilder: (context, index) {
          ServiceModel service = services[index];
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
                  Icons.design_services,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(
                service.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(service.description),
                  const SizedBox(height: 8),
                  Text(
                    'Durée: ${service.defaultDuration} minutes',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.secondary),
                  ),
                ],
              ),
              trailing: Icon(Icons.edit, color: theme.colorScheme.outline),
              onTap: () {
                if (artisanId != null) {
                  Navigator.push(
                    context,
                    FadeRoute(
                      page: EditServiceScreen(
                        service: service,
                        artisanId: artisanId,
                      ),
                    ),
                  ).then((_) => _loadServices());
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String? artisanId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 80,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun service trouvé',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre premier service pour que les clients puissent prendre rendez-vous.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
