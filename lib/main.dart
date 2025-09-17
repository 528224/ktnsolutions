import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ktnsolutions/screens/recognitions/web_recognitions_screen.dart';
import 'package:ktnsolutions/screens/main_home_screen.dart';
import 'package:ktnsolutions/utils/firestore_initializer.dart';
import 'package:ktnsolutions/services/firebase_messaging_service.dart';
import 'firebase_options.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb){
    var currentFirebaseAuthUser = FirebaseAuth.instance.currentUser;
    if (currentFirebaseAuthUser?.uid == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  // Initialize Firebase Messaging (only for mobile)
  if (!kIsWeb) {
    await FirebaseMessagingService.initialize();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // For web, show the recognitions screen directly without auth
    // final isWeb = identical(0, 0.0); // Platform detection for web
    final isWeb = kIsWeb;

    return GetMaterialApp(
      title: 'KTN Solutions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: isWeb 
          ?  WebRecognitionsScreen() // Web version
          : _buildMobileApp(), // Original mobile app with auth
    );
  }

  Widget _buildMobileApp() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in, show main navigation
        if (snapshot.hasData && FirebaseAuth.instance.currentUser?.phoneNumber?.isNotEmpty == true) {
          return const MainHomeScreen();
        }
        
        // If user is not logged in, show login screen
        return const PhoneAuthScreen();
      },
    );
  }
}
