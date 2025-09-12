import 'package:cloud_firestore/cloud_firestore.dart';
import 'posting.dart';
import 'task.dart';

class LegalCase {
  final String id;
  final String title;
  final List<Posting> previousPostings;
  final Posting? nextPosting;
  final String clientName;
  final String clientNumber;
  final List<Task> tasks;
  final DateTime? doneDate;

  LegalCase({
    required this.id,
    required this.title,
    required this.previousPostings,
    this.nextPosting,
    required this.clientName,
    required this.clientNumber,
    required this.tasks,
    this.doneDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'previousPostings': previousPostings.map((posting) => posting.toJson()).toList(),
      'nextPosting': nextPosting?.toJson(),
      'clientName': clientName,
      'clientNumber': clientNumber,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'doneDate': doneDate != null ? Timestamp.fromDate(doneDate!) : null,
    };
  }

  factory LegalCase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LegalCase(
      id: doc.id,
      title: data['title'] ?? '',
      previousPostings: (data['previousPostings'] as List<dynamic>?)
          ?.map((postingData) => Posting.fromJson(Map<String, dynamic>.from(postingData)))
          .toList() ?? [],
      nextPosting: data['nextPosting'] != null 
          ? Posting.fromJson(Map<String, dynamic>.from(data['nextPosting']))
          : null,
      clientName: data['clientName'] ?? '',
      clientNumber: data['clientNumber'] ?? '',
      tasks: (data['tasks'] as List<dynamic>?)
          ?.map((taskData) => Task.fromJson(Map<String, dynamic>.from(taskData)))
          .toList() ?? [],
      doneDate: data['doneDate']?.toDate(),
    );
  }

  factory LegalCase.fromJson(Map<String, dynamic> json) {
    return LegalCase(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      previousPostings: (json['previousPostings'] as List<dynamic>?)
          ?.map((postingData) => Posting.fromJson(Map<String, dynamic>.from(postingData)))
          .toList() ?? [],
      nextPosting: json['nextPosting'] != null 
          ? Posting.fromJson(Map<String, dynamic>.from(json['nextPosting']))
          : null,
      clientName: json['clientName'] ?? '',
      clientNumber: json['clientNumber'] ?? '',
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((taskData) => Task.fromJson(Map<String, dynamic>.from(taskData)))
          .toList() ?? [],
      doneDate: json['doneDate'] != null 
          ? (json['doneDate'] is Timestamp 
              ? (json['doneDate'] as Timestamp).toDate()
              : DateTime.parse(json['doneDate']))
          : null,
    );
  }

  LegalCase copyWith({
    String? id,
    String? title,
    List<Posting>? previousPostings,
    Posting? nextPosting,
    String? clientName,
    String? clientNumber,
    List<Task>? tasks,
    DateTime? doneDate,
  }) {
    return LegalCase(
      id: id ?? this.id,
      title: title ?? this.title,
      previousPostings: previousPostings ?? this.previousPostings,
      nextPosting: nextPosting ?? this.nextPosting,
      clientName: clientName ?? this.clientName,
      clientNumber: clientNumber ?? this.clientNumber,
      tasks: tasks ?? this.tasks,
      doneDate: doneDate ?? this.doneDate,
    );
  }

  bool get isCompleted => doneDate != null;
  
  int get completedTasksCount => tasks.where((task) => task.isCompleted).length;
  
  int get totalTasksCount => tasks.length;
  
  double get completionPercentage => 
      totalTasksCount > 0 ? (completedTasksCount / totalTasksCount) * 100 : 0.0;
}
