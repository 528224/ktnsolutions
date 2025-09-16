import 'package:ktnsolutions/services/home_details_service.dart';

class ProfileInitializer {
  static final HomeDetailsService _homeDetailsService = HomeDetailsService();

  /// Initialize profile data in Firestore with default values
  /// This can be called from the Profile screen if no data exists
  static Future<bool> initializeProfileData() async {
    try {
      // Check if profile data already exists
      final existingData = await _homeDetailsService.getHomeDetails();
      
      if (existingData == null) {
        // Create initial profile data
        await _homeDetailsService.createInitialHomeDetails();
        return true; // Successfully initialized
      } else {
        return false; // Already exists
      }
    } catch (e) {
      print('Error initializing profile data: $e');
      rethrow;
    }
  }

  /// Force update profile data (overwrites existing data)
  static Future<void> forceUpdateProfileData() async {
    try {
      await _homeDetailsService.createInitialHomeDetails();
    } catch (e) {
      print('Error force updating profile data: $e');
      rethrow;
    }
  }
}
