import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ktnsolutions/models/case_model.dart';

class CaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'cases';

  // Get all cases
  Future<List<LegalCase>> getCases() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('nextHearingDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => LegalCase.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting cases: $e');
      rethrow;
    }
  }

  // Get a single case by ID
  Future<LegalCase?> getCase(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return LegalCase.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting case: $e');
      rethrow;
    }
  }

  // Get case events
  Stream<List<CaseEvent>> getCaseEvents(String caseId) {
    return _firestore
        .collection('case_events')
        .where('caseId', isEqualTo: caseId)
        .orderBy('eventDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CaseEvent.fromFirestore(doc))
            .toList());
  }

  // Add a new case
  Future<void> addCase(LegalCase legalCase) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      await docRef.set(legalCase.toJson()
        ..addAll({
          'id': docRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }));
    } catch (e) {
      debugPrint('Error adding case: $e');
      rethrow;
    }
  }

  // Update an existing case
  Future<void> updateCase(LegalCase legalCase) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(legalCase.id)
          .update(legalCase.toJson()
            ..addAll({
              'updatedAt': FieldValue.serverTimestamp(),
            }));
    } catch (e) {
      debugPrint('Error updating case: $e');
      rethrow;
    }
  }

  // Delete a case
  Future<void> deleteCase(String id) async {
    try {
      // Delete case events first
      final events = await _firestore
          .collection('case_events')
          .where('caseId', isEqualTo: id)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in events.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the case
      batch.delete(_firestore.collection(_collectionName).doc(id));
      
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting case: $e');
      rethrow;
    }
  }

  // Add a case event
  Future<void> addCaseEvent(CaseEvent event) async {
    try {
      final docRef = _firestore.collection('case_events').doc();
      await docRef.set(event.toJson()
        ..addAll({
          'id': docRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }));
      
      // Update the case's next hearing date if this is a future event
      if (event.eventDate.isAfter(DateTime.now())) {
        final caseDoc = await _firestore.collection(_collectionName).doc(event.caseId).get();
        if (caseDoc.exists) {
          final nextHearingDate = caseDoc.data()?['nextHearingDate'] as Timestamp?;
          
          // Only update if the new event is earlier than the current next hearing date
          // or if there is no next hearing date set
          if (nextHearingDate == null || event.eventDate.isBefore(nextHearingDate.toDate())) {
            await _firestore.collection(_collectionName).doc(event.caseId).update({
              'nextHearingDate': event.eventDate,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error adding case event: $e');
      rethrow;
    }
  }

  // Update a case event
  Future<void> updateCaseEvent(CaseEvent event) async {
    try {
      await _firestore
          .collection('case_events')
          .doc(event.id)
          .update(event.toJson()
            ..addAll({
              'updatedAt': FieldValue.serverTimestamp(),
            }));
    } catch (e) {
      debugPrint('Error updating case event: $e');
      rethrow;
    }
  }

  // Delete a case event
  Future<void> deleteCaseEvent(String id) async {
    try {
      await _firestore.collection('case_events').doc(id).delete();
      
      // TODO: Update the case's next hearing date if needed
      // This would require finding the next upcoming event for the case
    } catch (e) {
      debugPrint('Error deleting case event: $e');
      rethrow;
    }
  }
}
