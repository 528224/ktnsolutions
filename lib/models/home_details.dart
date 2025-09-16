import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktnsolutions/models/user.dart';
import 'package:ktnsolutions/models/court.dart';

class ProfileData {
  final String name;
  final String designation;
  final String firmName;
  final String email;
  final List<String> phoneNumbers;
  final List<String> offices;

  ProfileData({
    required this.name,
    required this.designation,
    required this.firmName,
    required this.email,
    required this.phoneNumbers,
    required this.offices,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      firmName: json['firmName'] ?? '',
      email: json['email'] ?? '',
      phoneNumbers: List<String>.from(json['phoneNumbers'] ?? []),
      offices: List<String>.from(json['offices'] ?? []),
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
    };
  }

  ProfileData copyWith({
    String? name,
    String? designation,
    String? firmName,
    String? email,
    List<String>? phoneNumbers,
    List<String>? offices,
  }) {
    return ProfileData(
      name: name ?? this.name,
      designation: designation ?? this.designation,
      firmName: firmName ?? this.firmName,
      email: email ?? this.email,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      offices: offices ?? this.offices,
    );
  }
}

class HomeDetails {
  final String id;
  final ProfileData profileData;
  final List<UserDetails> usersList;
  final List<Court> courtList;
  final DateTime createdAt;
  final DateTime updatedAt;

  HomeDetails({
    required this.id,
    required this.profileData,
    required this.usersList,
    required this.courtList,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HomeDetails.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HomeDetails(
      id: doc.id,
      profileData: ProfileData.fromJson(data['profileData'] as Map<String, dynamic>? ?? {}),
      usersList: (data['usersList'] as List<dynamic>?)
          ?.map((userData) => UserDetails.fromJson(userData as Map<String, dynamic>))
          .toList() ?? [],
      courtList: (data['courtList'] as List<dynamic>?)
          ?.map((courtData) => Court.fromJson(courtData as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileData': profileData.toJson(),
      'usersList': usersList.map((user) => user.toJson()).toList(),
      'courtList': courtList.map((court) => court.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  HomeDetails copyWith({
    String? id,
    ProfileData? profileData,
    List<UserDetails>? usersList,
    List<Court>? courtList,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HomeDetails(
      id: id ?? this.id,
      profileData: profileData ?? this.profileData,
      usersList: usersList ?? this.usersList,
      courtList: courtList ?? this.courtList,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convenience getters for easy access to profile data
  String get name => profileData.name;
  String get designation => profileData.designation;
  String get firmName => profileData.firmName;
  String get email => profileData.email;
  List<String> get phoneNumbers => profileData.phoneNumbers;
  List<String> get offices => profileData.offices;
}
