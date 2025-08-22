import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktnsolutions/models/recognition.dart';

class RecognitionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'recognitions';

  // Get all recognitions sorted by published date
  Stream<List<Recognition>> getRecognitions() {
    return _firestore
        .collection(_collectionName)
        .orderBy('publishedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recognition.fromFirestore(doc))
            .toList());
  }

  // Get a single recognition by ID
  Future<Recognition?> getRecognition(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();
    if (!doc.exists) return null;
    return Recognition.fromFirestore(doc);
  }

  // Add a new recognition
  Future<void> addRecognition(Recognition recognition) async {
    final docRef = _firestore.collection(_collectionName).doc();
    await docRef.set(recognition.toJson()..['id'] = docRef.id);
  }

  // Update an existing recognition
  Future<void> updateRecognition(Recognition recognition) async {
    await _firestore
        .collection(_collectionName)
        .doc(recognition.id)
        .update(recognition.toJson()..['updatedAt'] = FieldValue.serverTimestamp());
  }

  // Delete a recognition
  Future<void> deleteRecognition(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  // Save or update recognition
  Future<void> saveRecognition(Recognition recognition) async {
    if (recognition.id.isEmpty) {
      await addRecognition(recognition);
    } else {
      await updateRecognition(recognition);
    }
  }
}
