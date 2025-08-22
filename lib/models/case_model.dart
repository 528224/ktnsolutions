import 'package:cloud_firestore/cloud_firestore.dart';

enum CaseStatus { pending, inProgress, completed, adjourned, dismissed }

enum EventType {
  hearing,
  filing,
  deadline,
  general,
  other,
}

class CaseEvent {
  final String id;
  final String caseId;
  final String title;
  final String description;
  final EventType eventType;
  final DateTime eventDate;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CaseEvent({
    required this.id,
    required this.caseId,
    required this.title,
    required this.description,
    required this.eventType,
    required this.eventDate,
    this.notes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'title': title,
      'description': description,
      'eventType': eventType.toString().split('.').last,
      'eventDate': Timestamp.fromDate(eventDate),
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory CaseEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CaseEvent(
      id: doc.id,
      caseId: data['caseId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      eventType: EventType.values.firstWhere(
        (e) => e.toString() == 'EventType.${data['eventType'] ?? 'general'}' ,
        orElse: () => EventType.general,
      ),
      eventDate: (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
      createdBy: data['createdBy'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }
}

class LegalCase {
  final String id;
  final String caseNumber;
  final String title;
  final String courtName;
  final String clientName;
  final String clientContact;
  final String advocateName;
  final String? advocateContact;
  final String? notes;
  final CaseStatus status;
  final DateTime? nextHearingDate;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LegalCase({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.courtName,
    required this.clientName,
    required this.clientContact,
    required this.advocateName,
    this.advocateContact,
    this.notes,
    this.status = CaseStatus.pending,
    this.nextHearingDate,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'caseNumber': caseNumber,
      'title': title,
      'courtName': courtName,
      'clientName': clientName,
      'clientContact': clientContact,
      'advocateName': advocateName,
      'advocateContact': advocateContact,
      'notes': notes,
      'status': status.toString().split('.').last,
      'nextHearingDate': nextHearingDate != null ? Timestamp.fromDate(nextHearingDate!) : null,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory LegalCase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LegalCase(
      id: doc.id,
      caseNumber: data['caseNumber'] ?? '',
      title: data['title'] ?? '',
      courtName: data['courtName'] ?? '',
      clientName: data['clientName'] ?? '',
      clientContact: data['clientContact'] ?? '',
      advocateName: data['advocateName'] ?? '',
      advocateContact: data['advocateContact'],
      notes: data['notes'],
      status: CaseStatus.values.firstWhere(
        (e) => e.toString() == 'CaseStatus.${data['status']}',
        orElse: () => CaseStatus.pending,
      ),
      nextHearingDate: data['nextHearingDate']?.toDate(),
      createdBy: data['createdBy'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }
}
