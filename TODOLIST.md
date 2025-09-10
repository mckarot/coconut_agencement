# Todo List - Application de Gestion de Rendez-vous pour Artisan

## Initialisation du projet (1-5)
- [x] 1. Créer un nouveau projet Flutter.
- [x] 2. Initialiser le dépôt Git.
- [x] 3. Configurer Firebase pour le projet (Authentication, Firestore, Storage).
- [x] 4. Ajouter les dépendances nécessaires dans `pubspec.yaml` (firebase_auth, cloud_firestore, firebase_storage, provider, etc.).
- [x] 5. Créer la structure de dossiers (ex: `lib/screens`, `lib/models`, `lib/services`, `lib/widgets`).

## Authentification (6-9)
- [x] 6. Mettre en place l'authentification Firebase.
- [x] 7. Créer l'écran de connexion/inscription.
- [x] 8. Implémenter la gestion des profils (client/artisan).
- [x] 9. Ajouter la persistance de l'état de connexion.

## Modèles de données (10-13)
- [x] 10. Définir le modèle `User` (client/artisan).
- [x] 11. Définir le modèle `Service` (nom, description, durée par défaut).
- [x] 12. Définir le modèle `Appointment` (client, artisan, service, date/heure, durée, statut).
- [x] 13. Définir le modèle `Profile` (artisan uniquement - photos, description, galerie).

## Gestion des services par l'artisan (14-17)
- [x] 14. Créer un écran pour lister les services de l'artisan.
- [x] 15. Implémenter la fonctionnalité d'ajout de service.
- [x] 16. Implémenter la fonctionnalité de modification de service.
- [x] 17. Implémenter la fonctionnalité de suppression de service.

## Calendrier et disponibilités (18-22)
- [x] 18. Créer un écran de calendrier pour afficher les disponibilités de l'artisan (7h-19h, lundi-samedi).
- [x] 19. Implémenter la sélection d'une date/heure par le client.
- [x] 20. Afficher les créneaux disponibles en fonction des rendez-vous existants.
- [x] 21. Permettre à l'artisan de voir son planning complet.
- [x] 22. Permettre à l'artisan de bloquer des périodes (vacances, arrêt maladie).

## Prise de rendez-vous par le client (23-26)
- [x] 23. Créer un écran pour que le client sélectionne un service.
- [x] 24. Permettre au client de choisir une date/heure disponible.
- [x] 25. Permettre au client de modifier la durée du rendez-vous (avec une suggestion par défaut).
- [x] 26. Envoyer la demande de rendez-vous à l'artisan.

## Validation des rendez-vous par l'artisan (27-30)
- [x] 27. Notifier l'artisan lorsqu'une demande de rendez-vous est reçue.
- [x] 28. Créer un écran pour que l'artisan voie les demandes en attente.
- [x] 29. Implémenter les boutons "Confirmer" et "Refuser" pour chaque demande.
- [x] 30. Mettre à jour le statut du rendez-vous dans la base de données.

## Notifications (31-33)
- [x] 31. Configurer Firebase Cloud Messaging (FCM) ou un système d'email.
- [x] 32. Envoyer une notification à l'artisan lors d'une nouvelle demande.
- [x] 33. Envoyer une notification au client lorsqu'un rendez-vous est confirmé/refusé.

## Personnalisation du profil artisan (34-37)
- [x] 34. Créer un écran de profil pour l'artisan.
- [x] 35. Permettre à l'artisan d'ajouter/modifier/supprimer des photos de réalisations.
- [x] 36. Permettre à l'artisan de modifier sa description.
- [x] 37. Créer une galerie des prestations effectuées.

## Historique des rendez-vous (38-40)
- [x] 38. Créer un écran pour afficher l'historique des rendez-vous.
- [x] 39. Afficher les rendez-vous passés, confirmés et refusés.
- [x] 40. Permettre à l'artisan et au client de voir leur historique respectif.

## Tests et déploiement (41-44)
- [ ] 41. Réaliser des tests fonctionnels sur chaque fonctionnalité.
- [ ] 42. Corriger les bugs identifiés.
- [ ] 43. Préparer le déploiement (icônes, descriptions, etc.).
- [ ] 44. Publier l'application sur les stores (Google Play/App Store).


corrige le point dans le calendrier user
time line pour historique user