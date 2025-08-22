import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ktnsolutions/screens/recognitions/web_recognitions_screen.dart';
import 'package:ktnsolutions/screens/main_home_screen.dart';
import 'di/dependencies.dart';
import 'firebase_options.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize dependencies
  await Dependencies().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // For web, show the recognitions screen directly without auth
    final isWeb = identical(0, 0.0); // Platform detection for web
    
    return GetMaterialApp(
      title: 'KTM Solutions',
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
        if (snapshot.hasData) {
          return const MainHomeScreen();
        }
        
        // If user is not logged in, show login screen
        return const PhoneAuthScreen();
      },
    );
  }
}
