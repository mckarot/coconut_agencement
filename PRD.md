# PRD - Application de Gestion de Rendez-vous pour Artisan

## 1. Introduction

### 1.1 Objectif
Développer une application mobile en Flutter permettant aux clients de prendre des rendez-vous avec un artisan spécialisé dans le montage de cuisines, l'agencement et le montage de meubles. L'application permettra à l'artisan de gérer son planning et à ses clients de visualiser ses disponibilités.

### 1.2 Parties prenantes
- **Artisan** : Utilise l'application pour gérer ses rendez-vous, ses services, son profil et sa galerie de réalisations.
- **Clients** : Utilisent l'application pour consulter les disponibilités de l'artisan et prendre des rendez-vous.
- **Développeur** : En charge du développement de l'application.

## 2. Fonctionnalités

### 2.1 Gestion des Rendez-vous
- **Création de services** : L'artisan peut créer, modifier et supprimer des types de services (ex : montage de cuisine, agencement de placard).
- **Prise de rendez-vous** :
  - Les clients consultent les disponibilités de l'artisan (7h à 19h, lundi à samedi).
  - Les clients sélectionnent un service et une date/heure.
  - La durée du rendez-vous est paramétrable, avec une suggestion par défaut (ex : 1/2 journée pour le montage d'une cuisine).
- **Validation des rendez-vous** : L'artisan reçoit une notification lorsqu'un client prend rendez-vous. Il peut confirmer ou refuser la demande.
- **Blocage de disponibilités** : L'artisan peut bloquer certaines périodes (vacances, arrêt maladie) où il n'est pas disponible.
- **Historique** : Tous les rendez-vous (passés, confirmés, refusés) sont stockés dans un historique.

### 2.2 Authentification et Profils
- **Authentification** :
  - Deux types de profils : Client et Artisan.
  - Authentification via Firebase Authentication.
- **Profils** :
  - **Artisan** :
    - Gestion de son planning.
    - Gestion des services proposés.
    - Personnalisation de son profil (photos de réalisations, description des services, galerie de prestations).
  - **Client** :
    - Consultation des disponibilités.
    - Prise de rendez-vous.
    - Historique des rendez-vous.

### 2.3 Notifications
- Notifications envoyées via Firebase (gratuit) lorsqu'un rendez-vous est pris, confirmé ou refusé.
- Notification par email.

### 2.4 Stockage des Données
- Base de données Firebase Firestore.
- Stockage des photos via Firebase Storage.
- Historique complet des rendez-vous.

## 3. Contraintes Techniques

### 3.1 Technologies
- **Frontend** : Flutter (Dart).
- **Backend** : Firebase (Authentication, Firestore, Storage, Cloud Functions pour les notifications).
- **Notifications** : Firebase Cloud Messaging (FCM) ou email via une solution intégrée à Firebase.

### 3.2 Hébergement
- Toutes les données seront stockées sur Firebase. Aucun hébergement externe n'est nécessaire.

## 4. Calendrier et Livrables

### 4.1 Phases de Développement
1. **Initialisation du projet** : Configuration de Firebase, structure de l'application Flutter.
2. **Authentification** : Mise en place des profils client et artisan.
3. **Gestion des services** : Création/modification/suppression des services par l'artisan.
4. **Calendrier et disponibilités** : Affichage des disponibilités et prise de rendez-vous par les clients.
5. **Validation des rendez-vous** : Système de confirmation/refus par l'artisan.
6. **Notifications** : Mise en place des notifications par email.
7. **Personnalisation du profil** : Ajout de photos, descriptions, galerie.
8. **Tests et déploiement** : Tests fonctionnels et déploiement de l'application.

### 4.2 Livrables
- Application mobile Flutter fonctionnelle.
- Documentation technique.
- Guide d'utilisation pour l'artisan et les clients.

## 5. Annexes

### 5.1 Références
- Documentation Flutter : https://flutter.dev/
- Documentation Firebase : https://firebase.google.com/