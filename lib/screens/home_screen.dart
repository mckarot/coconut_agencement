import 'package:coconut_agencement/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/services_list_screen.dart';
import 'artisans_planning_screen.dart';
import 'pending_appointments_screen.dart';
import 'artisan_profile_screen.dart';
import 'appointment_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Déterminer si l'utilisateur est un artisan
    final isArtisan = userProvider.user?.role == UserRole.artisan;

    // Options de navigation en fonction du rôle
    final List<Widget> artisanScreens = [
      const ArtisanPlanningScreen(),
      const PendingAppointmentsScreen(),
      const ServicesListScreen(),
      const ArtisanProfileScreen(),
      AppointmentHistoryScreen(isArtisanView: true),
    ];

    final List<String> artisanTitles = [
      'Mon Planning',
      'Rendez-vous en attente',
      'Mes Services',
      'Mon Profil',
      'Historique',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(artisanTitles[_selectedIndex]),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: artisanScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
            icon: Icon(Icons.person),
            label: 'Profil',
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