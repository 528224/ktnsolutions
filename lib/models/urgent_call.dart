import 'package:cloud_firestore/cloud_firestore.dart';

class UrgentCall {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserMobile;
  final List<String> targetUserIds;
  final List<String> targetUserNames;
  final DateTime createdAt;
  final UrgentCallStatus status;
  final String? message;
  final Map<String, CallResponse> responses; // userId -> response

  UrgentCall({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserMobile,
    required this.targetUserIds,
    required this.targetUserNames,
    required this.createdAt,
    required this.status,
    this.message,
    this.responses = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserMobile': fromUserMobile,
      'targetUserIds': targetUserIds,
      'targetUserNames': targetUserNames,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'message': message,
      'responses': responses.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory UrgentCall.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UrgentCall(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? '',
      fromUserMobile: data['fromUserMobile'] ?? '',
      targetUserIds: List<String>.from(data['targetUserIds'] ?? []),
      targetUserNames: List<String>.from(data['targetUserNames'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: UrgentCallStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => UrgentCallStatus.pending,
      ),
      message: data['message'],
      responses: (data['responses'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, CallResponse.fromJson(value)),
      ),
    );
  }

  UrgentCall copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? fromUserMobile,
    List<String>? targetUserIds,
    List<String>? targetUserNames,
    DateTime? createdAt,
    UrgentCallStatus? status,
    String? message,
    Map<String, CallResponse>? responses,
  }) {
    return UrgentCall(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserMobile: fromUserMobile ?? this.fromUserMobile,
      targetUserIds: targetUserIds ?? this.targetUserIds,
      targetUserNames: targetUserNames ?? this.targetUserNames,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      message: message ?? this.message,
      responses: responses ?? this.responses,
    );
  }
}

enum UrgentCallStatus {
  pending,
  active,
  completed,
  cancelled,
}

class CallResponse {
  final String userId;
  final String userName;
  final CallResponseType responseType;
  final DateTime respondedAt;
  final String? note;

  CallResponse({
    required this.userId,
    required this.userName,
    required this.responseType,
    required this.respondedAt,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'responseType': responseType.name,
      'respondedAt': Timestamp.fromDate(respondedAt),
      'note': note,
    };
  }

  factory CallResponse.fromJson(Map<String, dynamic> json) {
    return CallResponse(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      responseType: CallResponseType.values.firstWhere(
        (e) => e.name == json['responseType'],
        orElse: () => CallResponseType.acknowledged,
      ),
      respondedAt: (json['respondedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: json['note'],
    );
  }
}

enum CallResponseType {
  acknowledged,
  calling_back,
  busy,
  unavailable,
}

