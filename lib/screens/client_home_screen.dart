import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
    Center(
      child: Text(
        ''
        ,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    BookingScreen(),
    AppointmentHistoryScreen(isArtisanView: false),
  ];

  static const List<String> _clientTitles = [
    'Accueil',
    'Prendre RDV',
    'Mes rendez-vous',
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
        title: Text('Client - ${_clientTitles[_selectedIndex]}'),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.signOut();
              // After sign out, navigate back to the welcome screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/logo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _clientScreens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Prendre RDV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Rendez-vous',
          ),
        ],
      ),
    );
  }
}
