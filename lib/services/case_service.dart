import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class CaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'cases';

  /// Fetch all cases from Firestore
  static Future<List<LegalCase>> getAllCases() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .get();

      return snapshot.docs
          .map((doc) => LegalCase.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cases: $e');
    }
  }

  /// Get a stream of all cases for real-time updates
  static Stream<List<LegalCase>> getCasesStream() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LegalCase.fromFirestore(doc))
            .toList());
  }

  /// Fetch a single case by ID
  static Future<LegalCase?> getCaseById(String caseId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(caseId)
          .get();

      if (doc.exists) {
        return LegalCase.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch case: $e');
    }
  }

  /// Add a new case to Firestore
  static Future<String> addCase(LegalCase case_) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(case_.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add case: $e');
    }
  }

  /// Update an existing case
  static Future<void> updateCase(String caseId, LegalCase case_) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(caseId)
          .update(case_.toJson());
    } catch (e) {
      throw Exception('Failed to update case: $e');
    }
  }

  /// Delete a case
  static Future<void> deleteCase(String caseId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(caseId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete case: $e');
    }
  }

  /// Mark a case as completed by setting doneDate
  static Future<void> completeCase(String caseId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(caseId)
          .update({
        'doneDate': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to complete case: $e');
    }
  }

  /// Get active cases (no doneDate)
  static Future<List<LegalCase>> getActiveCases() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('doneDate', isNull: true)
          .get();

      return snapshot.docs
          .map((doc) => LegalCase.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active cases: $e');
    }
  }

  /// Get completed cases (has doneDate)
  static Future<List<LegalCase>> getCompletedCases() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('doneDate', isNull: false)
          .orderBy('doneDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => LegalCase.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch completed cases: $e');
    }
  }

  /// Get cases by client name
  static Future<List<LegalCase>> getCasesByClient(String clientName) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('clientName', isEqualTo: clientName)
          .get();

      return snapshot.docs
          .map((doc) => LegalCase.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cases by client: $e');
    }
  }

  /// Search cases by title
  static Future<List<LegalCase>> searchCasesByTitle(String searchTerm) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('title', isGreaterThanOrEqualTo: searchTerm)
          .where('title', isLessThan: '${searchTerm}z')
          .orderBy('title')
          .get();

      return snapshot.docs
          .map((doc) => LegalCase.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search cases: $e');
    }
  }

  /// Complete a posting and optionally set a new posting
  static Future<void> completePosting({
    required String caseId,
    required String completionNote,
    Posting? newPosting,
  }) async {
    try {
      final case_ = await getCaseById(caseId);
      if (case_ == null) {
        throw Exception('Case not found');
      }

      final updatedCase = case_.completePosting(
        completionNote: completionNote,
        newPosting: newPosting,
      );

      await updateCase(caseId, updatedCase);
    } catch (e) {
      throw Exception('Failed to complete posting: $e');
    }
  }

  /// Add a new posting to a case
  static Future<void> addNewPosting({
    required String caseId,
    required Posting posting,
  }) async {
    try {
      final case_ = await getCaseById(caseId);
      if (case_ == null) {
        throw Exception('Case not found');
      }

      final updatedCase = case_.addNewPosting(posting);
      await updateCase(caseId, updatedCase);
    } catch (e) {
      throw Exception('Failed to add new posting: $e');
    }
  }

  /// Mark a case as completed (done)
  static Future<void> markCaseAsCompleted(String caseId) async {
    try {
      final case_ = await getCaseById(caseId);
      if (case_ == null) {
        throw Exception('Case not found');
      }

      final updatedCase = case_.markAsCompleted();
      await updateCase(caseId, updatedCase);
    } catch (e) {
      throw Exception('Failed to mark case as completed: $e');
    }
  }
}
