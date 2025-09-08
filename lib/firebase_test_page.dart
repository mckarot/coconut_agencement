import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  bool _isFirebaseInitialized = false;
  String _initializationStatus = 'Non initialisé';

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _isFirebaseInitialized = true;
        _initializationStatus = 'Initialisation réussie !';
      });
    } catch (e) {
      setState(() {
        _initializationStatus = 'Erreur d\'initialisation: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firebase'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _initializationStatus,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Icon(
              _isFirebaseInitialized ? Icons.check_circle : Icons.error,
              color: _isFirebaseInitialized ? Colors.green : Colors.red,
              size: 50,
            ),
            const SizedBox(height: 20),
            if (!_isFirebaseInitialized)
              ElevatedButton(
                onPressed: _initializeFirebase,
                child: const Text('Réessayer'),
              ),
          ],
        ),
      ),
    );
  }
}