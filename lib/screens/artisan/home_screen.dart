import 'package:coconut_agencement/screens/user/register_screen.dart';
import 'package:coconut_agencement/widgets/fade_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'services_list_screen.dart';
import 'artisans_planning_screen.dart';
import 'pending_appointments_screen.dart';
import 'create_appointment_artisan_screen.dart';
import '../user/appointment_history_screen.dart';
import '../user/change_password_screen.dart';
import '../user/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final AdvancedDrawerController _advancedDrawerController;

  @override
  void initState() {
    super.initState();
    _advancedDrawerController = AdvancedDrawerController();
  }

  @override
  void dispose() {
    _advancedDrawerController.dispose();
    super.dispose();
  }

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

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
    if (confirm == true && mounted) {
      await authProvider.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: const WelcomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _changePassword() async {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.45; // 45% de la largeur de l'écran

    return AdvancedDrawer(
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            spreadRadius: 5.0,
            offset: Offset(5.0, 5.0),
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: SafeArea(
        child: Container(
          width: drawerWidth,
          height: double.infinity,
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                child: Image.asset(
                  'assets/images/logo-appli.png',
                  fit: BoxFit.cover,
                  width: drawerWidth,
                  height: double.infinity,
                ),
              ),
              
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Créer un compte'),
                onTap: () {
                  _advancedDrawerController.hideDrawer();
                  Navigator.push(
                    context,
                    FadeRoute(page: const RegisterScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Créer un rendez-vous'),
                onTap: () {
                  _advancedDrawerController.hideDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAppointmentArtisanScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Modifier mon mot de passe'),
                onTap: () {
                  _advancedDrawerController.hideDrawer();
                  _changePassword();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Déconnexion'),
                onTap: () {
                  _advancedDrawerController.hideDrawer();
                  _signOut();
                },
              ),
            ],
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_artisanTitles[_selectedIndex]),
          leading: IconButton(
            onPressed: _advancedDrawerController.showDrawer,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Icons.clear : Icons.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
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
      ),
    );
  }
}
