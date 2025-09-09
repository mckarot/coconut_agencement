import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();
      
      if (snapshot.exists) {
        return UserModel.fromMap(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }

  // Create or update user
  Future<void> setUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'utilisateur: $e');
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role == UserRole.artisan ? 'artisan' : 'client',
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du rôle: $e');
    }
  }

  // Get all artisans
  Future<List<UserModel>> getArtisans() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'artisan')
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des artisans: $e');
    }
  }

  // Get all clients
  Future<List<UserModel>> getClients() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'client')
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des clients: $e');
    }
  }
}
