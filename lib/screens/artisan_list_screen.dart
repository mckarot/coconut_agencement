import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'client_service_selection_screen.dart';

class ArtisanListScreen extends StatefulWidget {
  const ArtisanListScreen({super.key});

  @override
  State<ArtisanListScreen> createState() => _ArtisanListScreenState();
}

class _ArtisanListScreenState extends State<ArtisanListScreen> {
  bool _isLoading = false;

  Future<void> _startBookingFlow() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchArtisans();

      if (mounted) {
        if (userProvider.artisans.isNotEmpty) {
          // On prend le premier artisan de la liste par défaut
          final artisanId = userProvider.artisans.first.id;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientServiceSelectionScreen(
                artisanId: artisanId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun artisan n\'est disponible pour le moment.'))
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}'))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bienvenue chez Coconut Agencement',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Nous sommes prêts à vous accueillir. Prenez rendez-vous en quelques clics.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32.0),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _startBookingFlow,
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Prendre un rendez-vous'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
