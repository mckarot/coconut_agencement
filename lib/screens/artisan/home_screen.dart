import 'package:coconut_agencement/screens/user/register_screen.dart';
import 'package:coconut_agencement/widgets/fade_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'services_list_screen.dart';
import 'artisans_planning_screen.dart';
import 'pending_appointments_screen.dart';
import '../user/appointment_history_screen.dart';
import '../user/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Options de navigation pour l'artisan
  static const List<Widget> _artisanScreens = [
    ArtisanPlanningScreen(),
    PendingAppointmentsScreen(),
    ServicesListScreen(),
    AppointmentHistoryScreen(isArtisanView: true),
  ];

  static const List<String> _artisanTitles = [
    'Mon Planning',
    'Rendez-vous en attente',
    'Mes Services',
    'Historique',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_artisanTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                FadeRoute(page: const RegisterScreen()),
              );
            },
          ),
          IconButton(
            onPressed: () async {
              final bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmation'),
                  content: const Text('Voulez-vous vraiment vous déconnecter ?'),
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
      body: _artisanScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Planning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'En attente',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
        ],
      ),
    );
  }
}
