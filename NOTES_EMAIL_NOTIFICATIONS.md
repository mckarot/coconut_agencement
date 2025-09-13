# Configuration du Système de Notifications par Email

## Contexte
Mise en place d'un système de notifications par email pour les rendez-vous :
- Email à l'artisan quand un client prend un rendez-vous (statut "en attente")
- Email au client quand l'artisan valide/refuse le rendez-vous

## Étapes Réalisées

### 1. Création des fichiers Cloud Functions
- `functions/package.json` : Configuration des dépendances
- `functions/index.js` : Fonctions Cloud Functions pour l'envoi d'emails

### 2. Mise à jour de package.json
Mis à jour pour utiliser Node.js 20 (compatible avec la version actuelle v24.7.0)

## Étapes Restantes

### Étape 1 : Configuration de SendGrid
1. Créer un compte gratuit sur https://sendgrid.com
2. Créer une clé API avec accès restreint :
   - Menu Settings → API Keys → Create API Key
   - Nom: "CoconutAgencement"
   - Restricted Access
   - Permission: Mail Send → Full Access
   - Copier la clé API générée

3. Configurer le Sender Identity :
   - Menu Settings → Sender Authentication → Verify a Single Sender
   - From Email: noreply@coconut-agencement.com
   - From Name: Coconut Agencement
   - Reply To: votre-email@contact.com

### Étape 2 : Configuration Firebase
```bash
# Depuis la racine du projet
firebase functions:config:set sendgrid.key="VOTRE_CLE_API_ICI"
```

### Étape 3 : Déploiement des fonctions
```bash
firebase deploy --only functions
```

### Étape 4 : Mise à jour du code Flutter
1. Ajouter dépendance : `cloud_functions: ^4.5.0`
2. Créer `lib/services/email_service.dart`
3. Mettre à jour `lib/providers/notification_provider.dart`
4. Adapter `lib/screens/user/time_slot_screen.dart`
5. Adapter `lib/screens/artisan/pending_appointments_screen.dart`

## Structure des emails

### Email à l'artisan (demande de rendez-vous)
- Objet: "Nouvelle demande de rendez-vous - [Nom du client]"
- Contenu: Détails du rendez-vous, demande de confirmation

### Email au client (statut du rendez-vous)
- Objet: "Rendez-vous confirmé/refusé - Coconut Agencement"
- Contenu: Statut du rendez-vous, message personnalisé

## Commandes utiles
```bash
# Installer les dépendances (dans functions/)
cd functions && npm install

# Déployer les fonctions
firebase deploy --only functions

# Tester localement
firebase emulators:start --only functions
```

## Prochaine étape
Après configuration de SendGrid : Déploiement des fonctions Cloud et intégration dans l'application Flutter.