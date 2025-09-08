import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // Load user data from Firestore
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserModel? userData = await _userService.getUserById(userId);
      _user = userData;
    } catch (e) {
      throw Exception('Erreur lors du chargement de l\'utilisateur: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create or update user data
  Future<void> setUser(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.setUser(user);
      _user = user;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'utilisateur: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUserRole(userId, role);
      if (_user != null) {
        _user = UserModel(
          id: _user!.id,
          email: _user!.email,
          role: role,
          name: _user!.name,
          phone: _user!.phone,
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du rôle: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _userService.getUserById(userId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }
}