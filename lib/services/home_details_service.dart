import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktnsolutions/constants/profile_constants.dart';
import 'package:ktnsolutions/models/home_details.dart';

class HomeDetailsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'homeDetails';

  // Get home details (assuming there's only one document in the collection)
  Future<HomeDetails?> getHomeDetails() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      return HomeDetails.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error fetching home details: $e');
      return null;
    }
  }

  // Add or update home details
  Future<void> saveHomeDetails(HomeDetails homeDetails) async {
    try {
      if (homeDetails.id.isEmpty) {
        // Create new document
        final docRef = _firestore.collection(_collectionName).doc();
        await docRef.set(homeDetails.toJson()..['id'] = docRef.id);
      } else {
        // Update existing document
        await _firestore
            .collection(_collectionName)
            .doc(homeDetails.id)
            .update(homeDetails.toJson()..['updatedAt'] = FieldValue.serverTimestamp());
      }
    } catch (e) {
      print('Error saving home details: $e');
      rethrow;
    }
  }

  // Create initial home details using constants
  Future<void> createInitialHomeDetails() async {
    final homeDetails = HomeDetails(
      id: '',
      name: ProfileConstants.defaultName,
      designation: ProfileConstants.defaultDesignation,
      firmName: ProfileConstants.defaultFirmName,
      email: ProfileConstants.defaultEmail,
      phoneNumbers: ProfileConstants.defaultPhoneNumbers,
      offices: ProfileConstants.defaultOffices,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveHomeDetails(homeDetails);
  }
}
