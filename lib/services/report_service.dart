import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktnsolutions/models/case_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get cases by status for a specific time period
  Future<Map<CaseStatus, int>> getCaseStatusReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('cases');
      
      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      
      // Initialize counts for all statuses
      final counts = Map<CaseStatus, int>.fromIterable(
        CaseStatus.values,
        key: (status) => status,
        value: (_) => 0,
      );
      
      // Count cases by status
      for (var doc in snapshot.docs) {
        final status = CaseStatus.values.firstWhere(
          (e) => e.toString() == 'CaseStatus.${doc['status']}',
          orElse: () => CaseStatus.pending,
        );
        counts[status] = (counts[status] ?? 0) + 1;
      }
      
      return counts;
    } catch (e) {
      print('Error getting case status report: $e');
      rethrow;
    }
  }

  // Get upcoming hearings report
  Future<List<CaseEvent>> getUpcomingHearingsReport({
    required DateTime startDate,
    required DateTime endDate,
    String? advocateName,
  }) async {
    try {
      Query query = _firestore
          .collection('case_events')
          .where('eventType', isEqualTo: 'hearing')
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (advocateName != null && advocateName.isNotEmpty) {
        query = query.where('advocateName', isEqualTo: advocateName);
      }

      final snapshot = await query.orderBy('eventDate').get();
      
      return snapshot.docs
          .map((doc) => CaseEvent.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting upcoming hearings report: $e');
      rethrow;
    }
  }

  // Get cases by court
  Future<Map<String, int>> getCasesByCourtReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('cases');
      
      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final courtCounts = <String, int>{};
      
      for (var doc in snapshot.docs) {
        final courtName = doc['courtName'] as String? ?? 'Unknown';
        courtCounts[courtName] = (courtCounts[courtName] ?? 0) + 1;
      }
      
      return courtCounts;
    } catch (e) {
      print('Error getting cases by court report: $e');
      rethrow;
    }
  }
}
