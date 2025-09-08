import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'profiles';

  // Récupérer un profil par ID d'artisan
  Future<ProfileModel?> getProfileByArtisanId(String artisanId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection(_collection).doc(artisanId).get();
      
      if (snapshot.exists) {
        return ProfileModel.fromMap(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  // Créer ou mettre à jour un profil
  Future<void> setProfile(ProfileModel profile) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(profile.id)
          .set(profile.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du profil: $e');
    }
  }

  // Mettre à jour un profil
  Future<void> updateProfile(String artisanId, ProfileModel profile) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(artisanId)
          .update(profile.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Ajouter une photo au profil
  Future<void> addPhotoToProfile(String artisanId, String photoUrl) async {
    try {
      await _firestore.collection(_collection).doc(artisanId).update({
        'photos': FieldValue.arrayUnion([photoUrl]),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la photo au profil: $e');
    }
  }

  // Supprimer une photo du profil
  Future<void> removePhotoFromProfile(String artisanId, String photoUrl) async {
    try {
      await _firestore.collection(_collection).doc(artisanId).update({
        'photos': FieldValue.arrayRemove([photoUrl]),
      });
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la photo du profil: $e;');
    }
  }
}