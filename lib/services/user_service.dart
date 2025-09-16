import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktnsolutions/models/user.dart';
import 'package:ktnsolutions/constants/profile_constants.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'allUsers';

  // Get all users
  Future<List<UserDetails>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.map((doc) => UserDetails.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return ProfileConstants.defaultUsers; // Return default users if Firestore fails
    }
  }

  // Get user by ID
  Future<UserDetails?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return UserDetails.fromFirestore(doc);
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }

  // Add or update user
  Future<void> saveUser(UserDetails user) async {
    try {
      if (user.id.isEmpty) {
        // Create new document
        final docRef = _firestore.collection(_collectionName).doc();
        await docRef.set(user.toJson()..['id'] = docRef.id);
      } else {
        // Update existing document
        await _firestore.collection(_collectionName).doc(user.id).set(user.toJson());
      }
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Initialize default users in Firestore
  Future<void> initializeDefaultUsers() async {
    try {
      final existingUsers = await getAllUsers();
      if (existingUsers.isEmpty) {
        final defaultUsers = ProfileConstants.defaultUsers;
        for (final user in defaultUsers) {
          await saveUser(user);
        }
        print('Default users initialized successfully');
      } else {
        print('Users already exist, skipping initialization');
      }
    } catch (e) {
      print('Error initializing default users: $e');
      rethrow;
    }
  }

}
