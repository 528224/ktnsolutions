import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import '../models/urgent_call.dart';
import '../models/user.dart';

class UrgentCallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final String _collectionName = 'urgentCalls';

  // Send urgent call to multiple users
  Future<String> sendUrgentCall({
    required String fromUserId,
    required String fromUserName,
    required String fromUserMobile,
    required List<String> targetUserIds,
    required List<String> targetUserNames,
    String? message,
  }) async {
    try {
      final urgentCallId = Uuid().v4();
      
      final urgentCall = UrgentCall(
        id: urgentCallId,
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserMobile: fromUserMobile,
        targetUserIds: targetUserIds,
        targetUserNames: targetUserNames,
        createdAt: DateTime.now(),
        status: UrgentCallStatus.pending,
        message: message,
      );

      // Save to Firestore
      await _firestore
          .collection(_collectionName)
          .doc(urgentCallId)
          .set(urgentCall.toJson());

      // Send push notifications to target users
      await _sendPushNotifications(
        urgentCallId: urgentCallId,
        fromUserName: fromUserName,
        targetUserIds: targetUserIds,
        message: message,
      );

      return urgentCallId;
    } catch (e) {
      print('Error sending urgent call: $e');
      rethrow;
    }
  }

  // Send push notifications
  Future<void> _sendPushNotifications({
    required String urgentCallId,
    required String fromUserName,
    required List<String> targetUserIds,
    String? message,
  }) async {
    try {
      // Get FCM tokens for target users
      final tokens = await _getUserFCMTokens(targetUserIds);
      
      if (tokens.isEmpty) {
        print('No FCM tokens found for target users');
        return;
      }

      // Note: For production, you would use Firebase Admin SDK on your backend
      // to send messages to specific tokens. This is a placeholder implementation.
      // The actual implementation would require a backend service.
      
      print('Would send urgent call notification to ${tokens.length} users');
      print('From: $fromUserName');
      print('Message: ${message ?? 'Urgent call from $fromUserName'}');
      print('Urgent Call ID: $urgentCallId');
    } catch (e) {
      print('Error sending push notifications: $e');
    }
  }

  // Get FCM tokens for users
  Future<List<String>> _getUserFCMTokens(List<String> userIds) async {
    try {
      final tokens = <String>[];
      
      for (final userId in userIds) {
        final doc = await _firestore
            .collection('userTokens')
            .doc(userId)
            .get();
        
        if (doc.exists) {
          final token = doc.data()?['fcmToken'] as String?;
          if (token != null && token.isNotEmpty) {
            tokens.add(token);
          }
        }
      }
      
      return tokens;
    } catch (e) {
      print('Error getting FCM tokens: $e');
      return [];
    }
  }

  // Respond to urgent call
  Future<void> respondToUrgentCall({
    required String urgentCallId,
    required String userId,
    required String userName,
    required CallResponseType responseType,
    String? note,
  }) async {
    try {
      final response = CallResponse(
        userId: userId,
        userName: userName,
        responseType: responseType,
        respondedAt: DateTime.now(),
        note: note,
      );

      await _firestore
          .collection(_collectionName)
          .doc(urgentCallId)
          .update({
        'responses.$userId': response.toJson(),
      });
    } catch (e) {
      print('Error responding to urgent call: $e');
      rethrow;
    }
  }

  // Get urgent calls for a user
  Stream<List<UrgentCall>> getUrgentCallsForUser(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('targetUserIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UrgentCall.fromFirestore(doc))
          .toList();
    });
  }

  // Get urgent calls sent by a user
  Stream<List<UrgentCall>> getUrgentCallsSentByUser(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UrgentCall.fromFirestore(doc))
          .toList();
    });
  }

  // Update urgent call status
  Future<void> updateUrgentCallStatus({
    required String urgentCallId,
    required UrgentCallStatus status,
  }) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(urgentCallId)
          .update({
        'status': status.name,
      });
    } catch (e) {
      print('Error updating urgent call status: $e');
      rethrow;
    }
  }

  // Save user's FCM token
  Future<void> saveUserFCMToken(String userId, String fcmToken) async {
    try {
      await _firestore
          .collection('userTokens')
          .doc(userId)
          .set({
        'fcmToken': fcmToken,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Get user by mobile number
  Future<UserDetails?> getUserByMobile(String mobile) async {
    try {
      final snapshot = await _firestore
          .collection('allUsers')
          .where('mobile', isEqualTo: mobile)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      return UserDetails.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting user by mobile: $e');
      return null;
    }
  }
}
