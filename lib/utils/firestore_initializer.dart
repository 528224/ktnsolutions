import 'package:ktnsolutions/services/home_details_service.dart';

class FirestoreInitializer {
  static final HomeDetailsService _homeDetailsService = HomeDetailsService();

  /// Initialize homeDetails collection with hardcoded data
  /// This should be called once to set up the initial data
  static Future<void> initializeHomeDetails() async {
    try {
      // Check if homeDetails already exists
      final existingData = await _homeDetailsService.getHomeDetails();
      
      if (existingData == null) {
        // Create initial data
        await _homeDetailsService.createInitialHomeDetails();
        print('Home details initialized successfully');
      } else {
        print('Home details already exist, skipping initialization');
      }
    } catch (e) {
      print('Error initializing home details: $e');
      rethrow;
    }
  }
}
