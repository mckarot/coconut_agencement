import 'package:coconut_agencement/models/user_model.dart';
import 'package:coconut_agencement/providers/user_provider.dart';
import 'package:coconut_agencement/widgets/fade_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'artisan_service_selection_screen.dart';

class ClientSelectionScreen extends StatefulWidget {
  const ClientSelectionScreen({super.key});

  @override
  State<ClientSelectionScreen> createState() => _ClientSelectionScreenState();
}

class _ClientSelectionScreenState extends State<ClientSelectionScreen> {
  List<UserModel> _clients = [];
  UserModel? _selectedClient;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchClients();
      
      if (mounted) {
        setState(() {
          _clients = userProvider.clients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur lors du chargement des clients: $e";
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToServiceSelection() {
    if (_selectedClient != null) {
      Navigator.push(
        context,
        FadeRoute(
          page: ArtisanServiceSelectionScreen(
            clientId: _selectedClient!.id,
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
        title: const Text('Sélection du client'),
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
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadClients,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
                          child: Text(
                            'Choisissez un client',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _clients.length,
                            itemBuilder: (context, index) {
                              final client = _clients[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4.0),
                                child: ListTile(
                                  title: Text(client.name ?? client.email),
                                  subtitle: Text(client.email),
                                  selected: _selectedClient?.id == client.id,
                                  onTap: () {
                                    setState(() {
                                      _selectedClient = client;
                                    });
                                  },
                                  trailing: _selectedClient?.id == client.id
                                      ? const Icon(Icons.check, color: Colors.green)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: _selectedClient != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToServiceSelection,
              label: const Text('Suivant'),
              icon: const Icon(Icons.arrow_forward),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}