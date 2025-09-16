import 'package:cloud_firestore/cloud_firestore.dart';

class HomeDetails {
  final String id;
  final String name;
  final String designation;
  final String firmName;
  final String email;
  final List<String> phoneNumbers;
  final List<String> offices;
  final DateTime createdAt;
  final DateTime updatedAt;

  HomeDetails({
    required this.id,
    required this.name,
    required this.designation,
    required this.firmName,
    required this.email,
    required this.phoneNumbers,
    required this.offices,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HomeDetails.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HomeDetails(
      id: doc.id,
      name: data['name'] ?? '',
      designation: data['designation'] ?? '',
      firmName: data['firmName'] ?? '',
      email: data['email'] ?? '',
      phoneNumbers: List<String>.from(data['phoneNumbers'] ?? []),
      offices: List<String>.from(data['offices'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'designation': designation,
      'firmName': firmName,
      'email': email,
      'phoneNumbers': phoneNumbers,
      'offices': offices,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  HomeDetails copyWith({
    String? id,
    String? name,
    String? designation,
    String? firmName,
    String? email,
    List<String>? phoneNumbers,
    List<String>? offices,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HomeDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      firmName: firmName ?? this.firmName,
      email: email ?? this.email,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      offices: offices ?? this.offices,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
