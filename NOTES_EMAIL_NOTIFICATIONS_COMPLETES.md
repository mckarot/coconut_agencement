# Configuration du Système de Notifications par Email

## Contexte
Mise en place d'un système de notifications par email pour les rendez-vous :
- Email à l'artisan quand un client prend un rendez-vous (statut \"en attente\")
- Email au client quand l'artisan valide/refuse le rendez-vous

## Étapes Réalisées

### 1. Création des fichiers Cloud Functions
- `functions/package.json` : Configuration des dépendances
- `functions/index.js` : Fonctions Cloud Functions pour l'envoi d'emails

### 2. Mise à jour de package.json
Mis à jour pour utiliser Node.js 20 (compatible avec la version actuelle v24.7.0)

## Étapes Complètes à Réaliser

### Étape 1 : Prérequis système
1. **Vérifier la version de Node.js** :
   ```bash
   node --version
   ```
2. **Si nécessaire, installer Node Version Manager (NVM)** :
   ```bash
   # Sur macOS/Linux
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   # Redémarrer le terminal
   nvm install 20
   nvm use 20
   ```

### Étape 2 : Configuration de SendGrid
1. **Créer un compte gratuit sur** https://sendgrid.com
   - Cliquer sur \"Start for Free\"
   - Remplir le formulaire d'inscription
   - Vérifier l'email de confirmation

2. **Créer une clé API avec accès restreint** :
   - Se connecter à SendGrid
   - Menu Settings → API Keys → Create API Key
   - Nom: \"CoconutAgencement\"
   - Restricted Access
   - Permissions: Mail Send → Full Access
   - Copier la clé API générée (elle ne sera affichée qu'une seule fois)

3. **Configurer le Sender Identity** :
   - Menu Settings → Sender Authentication → Verify a Single Sender
   - From Email: noreply@coconut-agencement.com (ou votre email)
   - From Name: Coconut Agencement
   - Reply To: votre-email@contact.com
   - Cliquer sur \"Create\"

### Étape 3 : Configuration Firebase
1. **Configurer la clé API dans Firebase** :
   ```bash
   # Depuis la racine du projet
   firebase functions:config:set sendgrid.key=\"SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\"
   ```

### Étape 4 : Installation et déploiement des fonctions
1. **Installer les dépendances** :
   ```bash
   cd functions
   npm install
   ```

2. **Déployer les fonctions Cloud Functions** :
   ```bash
   # Depuis la racine du projet
   firebase deploy --only functions
   ```

### Étape 5 : Mise à jour du code Flutter
1. **Ajouter la dépendance cloud_functions dans pubspec.yaml** :
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     cloud_functions: ^4.5.0
     # ... autres dépendances existantes
   ```

2. **Créer le service EmailService** (`lib/services/email_service.dart`) :
   ```dart
   import 'package:cloud_functions/cloud_functions.dart';
   import 'package:firebase_auth/firebase_auth.dart';

   class EmailService {
     static final FirebaseFunctions _functions = FirebaseFunctions.instance;

     static Future<void> sendAppointmentRequestEmail({
       required String artisanEmail,
       required String clientName,
       required DateTime appointmentDate,
       required String serviceName,
       String? clientEmail,
       String? artisanName,
     }) async {
       try {
         final user = FirebaseAuth.instance.currentUser;
         if (user == null) {
           throw Exception('Utilisateur non authentifié');
         }

         final HttpsCallable callable = _functions.httpsCallable(
           'sendAppointmentRequestEmail',
           options: HttpsCallableOptions(timeout: Duration(seconds: 30)),
         );

         await callable.call(<String, dynamic>{
           'artisanEmail': artisanEmail,
           'clientName': clientName,
           'appointmentDate': appointmentDate.toIso8601String(),
           'serviceName': serviceName,
           'clientEmail': clientEmail,
           'artisanName': artisanName,
         });

         print('Email de demande de rendez-vous envoyé avec succès');
       } catch (e) {
         print('Erreur lors de l\\'envoi de l\\'email de demande: $e');
         rethrow;
       }
     }

     static Future<void> sendAppointmentStatusEmail({
       required String clientEmail,
       required String artisanName,
       required DateTime appointmentDate,
       required String serviceName,
       required bool isConfirmed,
       String? clientName,
     }) async {
       try {
         final user = FirebaseAuth.instance.currentUser;
         if (user == null) {
           throw Exception('Utilisateur non authentifié');
         }

         final HttpsCallable callable = _functions.httpsCallable(
           'sendAppointmentStatusEmail',
           options: HttpsCallableOptions(timeout: Duration(seconds: 30)),
         );

         await callable.call(<String, dynamic>{
           'clientEmail': clientEmail,
           'artisanName': artisanName,
           'appointmentDate': appointmentDate.toIso8601String(),
           'serviceName': serviceName,
           'isConfirmed': isConfirmed,
           'clientName': clientName,
         });

         print('Email de statut de rendez-vous envoyé avec succès');
       } catch (e) {
         print('Erreur lors de l\\'envoi de l\\'email de statut: $e');
         rethrow;
       }
     }
   }
   ```

3. **Mettre à jour NotificationProvider** (`lib/providers/notification_provider.dart`) :
   ```dart
   import 'package:flutter/material.dart';
   import '../services/local_notification_service.dart';
   import '../services/email_service.dart';

   class NotificationProvider with ChangeNotifier {
     final LocalNotificationService _localNotificationService = 
         LocalNotificationService();
     bool _isLoading = false;

     bool get isLoading => _isLoading;

     Future<void> notifyArtisanOfNewAppointment({
       required String artisanEmail,
       required String clientName,
       required DateTime appointmentDate,
       required String serviceName,
       String? clientEmail,
       String? artisanName,
     }) async {
       _isLoading = true;
       notifyListeners();

       try {
         // Envoyer notification locale
         await _localNotificationService.scheduleNotification(
           title: 'Nouvelle demande de rendez-vous',
           body:
               '$clientName a demandé un rendez-vous pour le ${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}',
           scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
         );

         // Envoyer email à l'artisan
         await EmailService.sendAppointmentRequestEmail(
           artisanEmail: artisanEmail,
           clientName: clientName,
           appointmentDate: appointmentDate,
           serviceName: serviceName,
           clientEmail: clientEmail,
           artisanName: artisanName,
         );
       } catch (e) {
         print('Erreur lors de l\\'envoi de la notification: $e');
         throw Exception('Erreur lors de l\\'envoi de la notification: $e');
       } finally {
         _isLoading = false;
         notifyListeners();
       }
     }

     Future<void> notifyClientOfAppointmentStatus({
       required String clientEmail,
       required String artisanName,
       required DateTime appointmentDate,
       required String serviceName,
       required bool isConfirmed,
       String? clientName,
     }) async {
       _isLoading = true;
       notifyListeners();

       try {
         // Envoyer notification locale
         String status = isConfirmed ? 'confirmé' : 'refusé';
         await _localNotificationService.scheduleNotification(
           title: 'Rendez-vous $status',
           body:
               'Votre rendez-vous avec $artisanName pour le ${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year} a été $status',
           scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
         );

         // Envoyer email au client
         await EmailService.sendAppointmentStatusEmail(
           clientEmail: clientEmail,
           artisanName: artisanName,
           appointmentDate: appointmentDate,
           serviceName: serviceName,
           isConfirmed: isConfirmed,
           clientName: clientName,
         );
       } catch (e) {
         print('Erreur lors de l\\'envoi de la notification: $e');
         throw Exception('Erreur lors de l\\'envoi de la notification: $e');
       } finally {
         _isLoading = false;
         notifyListeners();
       }
     }
   }
   ```

4. **Adapter TimeSlotScreen** (`lib/screens/user/time_slot_screen.dart`) :
   - Dans la méthode `_bookAppointmentForSlot`, remplacer l'appel à `notifyArtisanOfNewAppointment` pour inclure les informations de l'artisan (email, nom)

5. **Adapter PendingAppointmentsScreen** (`lib/screens/artisan/pending_appointments_screen.dart`) :
   - Dans la méthode `_updateAppointmentStatus`, ajouter les appels à `notifyClientOfAppointmentStatus` avec les informations nécessaires

### Étape 6 : Tester le système complet
1. **Exécuter l'application en mode développement** :
   ```bash
   flutter run
   ```

2. **Créer un compte artisan avec un email valide**
3. **Créer un compte client**
4. **Se connecter en tant que client**
5. **Prendre un rendez-vous**
6. **Vérifier que l'artisan reçoit un email**
7. **Se connecter en tant qu'artisan**
8. **Confirmer ou refuser le rendez-vous**
9. **Vérifier que le client reçoit un email**

## Structure des emails

### Email à l'artisan (demande de rendez-vous)
- Objet: \"Nouvelle demande de rendez-vous - [Nom du client]\"
- Contenu: Détails du rendez-vous, demande de confirmation

### Email au client (statut du rendez-vous)
- Objet: \"Rendez-vous confirmé/refusé - Coconut Agencement\"
- Contenu: Statut du rendez-vous, message personnalisé

## Commandes utiles
```bash
# Installer les dépendances (dans functions/)
cd functions && npm install

# Déployer les fonctions
firebase deploy --only functions

# Tester localement
firebase emulators:start --only functions

# Vérifier la configuration SendGrid
firebase functions:config:get

# Mettre à jour la configuration
firebase functions:config:set sendgrid.key=\"NOUVELLE_CLE_API\"
```

## Problèmes courants et solutions

1. **Erreur \"Unsupported engine\"** :
   - Mettre à jour package.json avec la version Node.js correcte
   - Utiliser NVM pour gérer les versions de Node.js

2. **Emails non reçus** :
   - Vérifier que SendGrid est correctement configuré
   - Vérifier que l'expéditeur est vérifié
   - Consulter les logs Firebase Functions

3. **Erreurs d'authentification Firebase** :
   - S'assurer que l'utilisateur est connecté avant d'appeler les fonctions
   - Vérifier les règles de sécurité Firebase

4. **Timeout des fonctions** :
   - Augmenter le timeout dans HttpsCallableOptions
   - Vérifier la connectivité réseau

## Étapes futures (améliorations)
1. Ajout de notifications push Firebase Cloud Messaging
2. Personnalisation des templates d'emails
3. Ajout de tracking des ouvertures d'emails
4. Internationalisation des emails