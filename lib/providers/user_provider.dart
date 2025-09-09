import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateUserFromAuth(String? userId) {
    if (userId == null) {
      _user = null;
      _currentUserId = null;
      notifyListeners();
    } else if (userId != _currentUserId) {
      _currentUserId = userId;
      loadUser(userId);
    }
  }

  // Load user data from Firestore
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    // We notify here to show loading spinner immediately
    notifyListeners();

    try {
      print('Loading user with ID: $userId');
      _user = await _userService.getUserById(userId);
      print('User data loaded: $_user');
      if (_user != null) {
        print('User role: ${_user!.role}');
      }
    } catch (e) {
      print('Error loading user: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create or update user data
  Future<void> setUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.setUser(user);
      _user = user;
      _currentUserId = user.id;
    } catch (e) {
      _error = e.toString();
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
        _user = _user!.copyWith(role: role);
      }
    } catch (e) {
      _error = e.toString();
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
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  List<UserModel> _artisans = [];
  List<UserModel> get artisans => _artisans;

  // Get all artisans
  Future<void> fetchArtisans() async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      _artisans = await _userService.getArtisans();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<UserModel> _clients = [];
  List<UserModel> get clients => _clients;

  // Get all clients
  Future<void> fetchClients() async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      _clients = await _userService.getClients();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

