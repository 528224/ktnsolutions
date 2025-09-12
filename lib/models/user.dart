import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String mobile;
  final bool isAdmin;

  User({
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

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      mobile: data['mobile'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? mobile,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

// Global array with user objects
final List<User> globalUsers = [
  User(
    id: '1',
    name: 'Prbhu',
    mobile: '+919544322000',
    isAdmin: true,
  ),
  User(
    id: '2',
    name: 'Cristo',
    mobile: '+919846476909',
    isAdmin: false,
  ),
  User(
    id: '3',
    name: 'Simjo',
    mobile: '+911234567890',
    isAdmin: true,
  ),
];
