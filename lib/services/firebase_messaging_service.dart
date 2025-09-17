import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'urgent_call_service.dart';
import '../models/user.dart';
import '../services/global_data_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final UrgentCallService _urgentCallService = UrgentCallService();

  // Initialize Firebase Messaging
  static Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission for notifications');
    } else {
      print('User declined or has not accepted permission for notifications');
    }

    // Get FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      await _saveFCMToken(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_saveFCMToken);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Save FCM token to Firestore
  static Future<void> _saveFCMToken(String token) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.phoneNumber == null) return;

      // Get user ID from phone number
      final users = await GlobalDataService().getAllUsers();
      final currentUserData = users.firstWhere(
        (user) => user.mobile == currentUser!.phoneNumber,
        orElse: () => UserDetails(id: '', name: '', mobile: '', isAdmin: false),
      );

      if (currentUserData.id.isNotEmpty) {
        await _urgentCallService.saveUserFCMToken(currentUserData.id, token);
        print('FCM token saved for user: ${currentUserData.name}');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    
    if (message.data['type'] == 'urgent_call') {
      // Show in-app notification or dialog
      _showUrgentCallNotification(message);
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    
    if (message.data['type'] == 'urgent_call') {
      // Navigate to urgent call screen
      // This would need to be handled by the app's navigation system
    }
  }

  // Show urgent call notification in foreground
  static void _showUrgentCallNotification(RemoteMessage message) {
    // This would typically use a global navigator or state management
    // to show a dialog or snackbar
    print('Urgent call from: ${message.data['fromUserName']}');
    print('Message: ${message.data['message']}');
  }

  // Get FCM token
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  
  // Handle urgent call in background
  if (message.data['type'] == 'urgent_call') {
    print('Background urgent call from: ${message.data['fromUserName']}');
    // You can perform background tasks here like updating local database
  }
}

