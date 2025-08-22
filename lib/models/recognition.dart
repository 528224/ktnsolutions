
import 'package:cloud_firestore/cloud_firestore.dart';

class Recognition {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? link;
  final DateTime publishedDate;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Recognition({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.link,
    required this.publishedDate,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Recognition to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'link': link,
      'publishedDate': Timestamp.fromDate(publishedDate),
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create Recognition from Firestore document
  factory Recognition.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recognition(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      link: data['link'],
      publishedDate: (data['publishedDate'] as Timestamp).toDate(),
      createdBy: data['createdBy'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }
}
