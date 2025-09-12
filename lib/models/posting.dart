import 'package:cloud_firestore/cloud_firestore.dart';

class Posting {
  final String id;
  final String title;
  final DateTime date;
  final String staff;
  final String court;
  final String note;

  Posting({
    required this.id,
    required this.title,
    required this.date,
    required this.staff,
    required this.court,
    this.note = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'staff': staff,
      'court': court,
      'note': note,
    };
  }

  factory Posting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Posting(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      staff: data['staff'] ?? '',
      court: data['court'] ?? '',
      note: data['note'] ?? '',
    );
  }

  factory Posting.fromJson(Map<String, dynamic> json) {
    return Posting(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] is Timestamp 
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date']),
      staff: json['staff'] ?? '',
      court: json['court'] ?? '',
      note: json['note'] ?? '',
    );
  }

  Posting copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? staff,
    String? court,
    String? note,
  }) {
    return Posting(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      staff: staff ?? this.staff,
      court: court ?? this.court,
      note: note ?? this.note,
    );
  }
}
