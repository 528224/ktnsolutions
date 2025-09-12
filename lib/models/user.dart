import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  final String id;
  final String name;
  final String mobile;
  final bool isAdmin;

  UserDetails({
    required this.id,
    required this.name,
    required this.mobile,
    required this.isAdmin,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'isAdmin': isAdmin,
    };
  }

  factory UserDetails.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDetails(
      id: doc.id,
      name: data['name'] ?? '',
      mobile: data['mobile'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  UserDetails copyWith({
    String? id,
    String? name,
    String? mobile,
    bool? isAdmin,
  }) {
    return UserDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

// Global array with user objects
final List<UserDetails> globalUsers = [
  UserDetails(
    id: '1',
    name: 'Prbhu',
    mobile: '+919544322000',
    isAdmin: true,
  ),
  UserDetails(
    id: '2',
    name: 'Cristo',
    mobile: '+919846476909',
    isAdmin: false,
  ),
  UserDetails(
    id: '3',
    name: 'Simjo',
    mobile: '+911234567890',
    isAdmin: true,
  ),
];
