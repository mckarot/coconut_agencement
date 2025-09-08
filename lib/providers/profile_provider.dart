import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  ProfileModel? _profile;
  bool _isLoading = false;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  // Charger le profil d'un artisan
  Future<void> loadProfile(String artisanId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      ProfileModel? profileData =
          await _profileService.getProfileByArtisanId(artisanId);
      _profile = profileData;
    } catch (e) {
      throw Exception('Erreur lors du chargement du profil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer ou mettre à jour un profil
  Future<void> setProfile(ProfileModel profile) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      await _profileService.setProfile(profile);
      _profile = profile;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du profil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour un profil
  Future<void> updateProfile(String artisanId, ProfileModel profile) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      await _profileService.updateProfile(artisanId, profile);
      _profile = profile;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter une photo au profil
  Future<void> addPhotoToProfile(String artisanId, String photoUrl) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      await _profileService.addPhotoToProfile(artisanId, photoUrl);
      
      // Mettre à jour le profil local
      if (_profile != null) {
        List<String> updatedPhotos = List<String>.from(_profile!.photos ?? []);
        updatedPhotos.add(photoUrl);
        
        _profile = ProfileModel(
          id: _profile!.id,
          businessName: _profile!.businessName,
          description: _profile!.description,
          photos: updatedPhotos,
          address: _profile!.address,
          phone: _profile!.phone,
          email: _profile!.email,
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la photo au profil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Supprimer une photo du profil
  Future<void> removePhotoFromProfile(String artisanId, String photoUrl) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      await _profileService.removePhotoFromProfile(artisanId, photoUrl);
      
      // Mettre à jour le profil local
      if (_profile != null) {
        List<String> updatedPhotos = List<String>.from(_profile!.photos ?? []);
        updatedPhotos.remove(photoUrl);
        
        _profile = ProfileModel(
          id: _profile!.id,
          businessName: _profile!.businessName,
          description: _profile!.description,
          photos: updatedPhotos,
          address: _profile!.address,
          phone: _profile!.phone,
          email: _profile!.email,
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la photo du profil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}