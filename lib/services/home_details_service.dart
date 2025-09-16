import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktnsolutions/constants/profile_constants.dart';
import 'package:ktnsolutions/models/home_details.dart';
import 'package:ktnsolutions/models/user.dart';
import 'package:ktnsolutions/models/court.dart';

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
    final profileData = ProfileData(
      name: ProfileConstants.defaultName,
      designation: ProfileConstants.defaultDesignation,
      firmName: ProfileConstants.defaultFirmName,
      email: ProfileConstants.defaultEmail,
      phoneNumbers: ProfileConstants.defaultPhoneNumbers,
      offices: ProfileConstants.defaultOffices,
    );

    final homeDetails = HomeDetails(
      id: '',
      profileData: profileData,
      usersList: _getDefaultUsers(),
      courtList: _getDefaultCourts(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveHomeDetails(homeDetails);
  }

  // Get default users
  List<UserDetails> _getDefaultUsers() {
    return [
      UserDetails(
        id: '1',
        name: 'Prbhu',
        mobile: '+919544322000',
        isAdmin: true,
      ),
      UserDetails(
        id: '2',
        name: 'Cristo',
        mobile: '+919846476909',
        isAdmin: false,
      ),
      UserDetails(
        id: '3',
        name: 'Simjo',
        mobile: '+911234567890',
        isAdmin: true,
      ),
    ];
  }

  // Get default courts
  List<Court> _getDefaultCourts() {
    return [
      Court(name: 'Supreme Court of India'),
      Court(name: 'Delhi High Court'),
      Court(name: 'Kerala High Court'),
      Court(name: 'Karnataka High Court'),
      Court(name: 'Tamil Nadu High Court'),
      Court(name: 'Maharashtra High Court'),
      Court(name: 'Gujarat High Court'),
      Court(name: 'Rajasthan High Court'),
      Court(name: 'Punjab & Haryana High Court'),
      Court(name: 'Madhya Pradesh High Court'),
      Court(name: 'District Court - Thrissur'),
      Court(name: 'District Court - Palakkad'),
      Court(name: 'District Court - Ernakulam'),
      Court(name: 'District Court - Kozhikode'),
      Court(name: 'Family Court'),
      Court(name: 'Consumer Court'),
      Court(name: 'Labour Court'),
      Court(name: 'Other'),
    ];
  }
}
