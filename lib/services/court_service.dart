import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktnsolutions/models/court.dart';
import 'package:ktnsolutions/constants/profile_constants.dart';

class CourtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'allCourts';

  // Get all courts
  Future<List<Court>> getAllCourts() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Court(name: data['name'] ?? '');
      }).toList();
    } catch (e) {
      print('Error fetching courts: $e');
      return ProfileConstants.defaultCourts; // Return default courts if Firestore fails
    }
  }

  // Add or update court
  Future<void> saveCourt(Court court) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      await docRef.set({
        'name': court.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving court: $e');
      rethrow;
    }
  }

  // Delete court
  Future<void> deleteCourt(String courtName) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('name', isEqualTo: courtName)
          .get();
      
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting court: $e');
      rethrow;
    }
  }

  // Initialize default courts in Firestore
  Future<void> initializeDefaultCourts() async {
    try {
      final existingCourts = await getAllCourts();
      if (existingCourts.isEmpty) {
        final defaultCourts = ProfileConstants.defaultCourts;
        for (final court in defaultCourts) {
          await saveCourt(court);
        }
        print('Default courts initialized successfully');
      } else {
        print('Courts already exist, skipping initialization');
      }
    } catch (e) {
      print('Error initializing default courts: $e');
      rethrow;
    }
  }

}
