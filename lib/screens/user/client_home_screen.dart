import 'package:coconut_agencement/services/appointment_service.dart';
import 'package:coconut_agencement/services/user_service.dart';
import 'package:coconut_agencement/widgets/fade_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'appointment_history_screen.dart';
import 'booking_screen.dart';
import 'welcome_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;

  // Écrans pour le client
  static const List<Widget> _clientScreens = [
    BookingScreen(),
    AppointmentHistoryScreen(isArtisanView: false),
  ];

  static const List<String> _clientTitles = [
    'Prendre RDV',
    'Mes rendez-vous',
  ];

  void _onItemTapped(int index) {
    // L'index 2 est réservé pour la suppression de compte
    if (index == 2) {
      _deleteAccount();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _deleteAccount() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et toutes vos données seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.userId;
        if (userId == null) {
          throw Exception("Utilisateur non trouvé.");
        }

        final authService = authProvider;

        // 1. Supprimer tous les rendez-vous du client
        await AppointmentService().deleteClientAppointments(userId);

        // 2. Supprimer les données de l'utilisateur de Firestore
        await UserService().deleteUser(userId);

        // 3. Supprimer le compte d'authentification Firebase
        await authService.deleteAccount();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte supprimé avec succès.')),
        );

        Navigator.of(context).pushAndRemoveUntil(
          FadeRoute(page: const WelcomeScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la suppression du compte: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_clientTitles[_selectedIndex]),
        actions: [
          IconButton(
            onPressed: () async {
              final bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmation'),
                  content:
                      const Text('Voulez-vous vraiment vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Se déconnecter'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await authProvider.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  FadeRoute(page: const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _clientScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Prendre RDV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Rendez-vous',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_forever, color: Colors.red),
            label: 'Supprimer compte',
          ),
        ],
      ),
    );
  }
}
