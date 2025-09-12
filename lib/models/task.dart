import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String staff;
  final DateTime dueDate;
  final DateTime? doneDate;

  Task({
    required this.id,
    required this.title,
    required this.staff,
    required this.dueDate,
    this.doneDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'staff': staff,
      'dueDate': Timestamp.fromDate(dueDate),
      'doneDate': doneDate != null ? Timestamp.fromDate(doneDate!) : null,
    };
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      staff: data['staff'] ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      doneDate: data['doneDate']?.toDate(),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      staff: json['staff'] ?? '',
      dueDate: json['dueDate'] is Timestamp 
          ? (json['dueDate'] as Timestamp).toDate()
          : DateTime.parse(json['dueDate']),
      doneDate: json['doneDate'] != null 
          ? (json['doneDate'] is Timestamp 
              ? (json['doneDate'] as Timestamp).toDate()
              : DateTime.parse(json['doneDate']))
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? staff,
    DateTime? dueDate,
    DateTime? doneDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      staff: staff ?? this.staff,
      dueDate: dueDate ?? this.dueDate,
      doneDate: doneDate ?? this.doneDate,
    );
  }

  bool get isCompleted => doneDate != null;
}
