import 'package:ktnsolutions/models/user.dart';
import 'package:ktnsolutions/models/court.dart';
import 'package:ktnsolutions/services/home_details_service.dart';
import 'package:ktnsolutions/constants/profile_constants.dart';

class GlobalDataService {
  static final GlobalDataService _instance = GlobalDataService._internal();
  factory GlobalDataService() => _instance;
  GlobalDataService._internal();

  final HomeDetailsService _homeDetailsService = HomeDetailsService();

  List<UserDetails>? _cachedUsers;
  List<Court>? _cachedCourts;

  // Get all users (from cache or Firestore)
  Future<List<UserDetails>> getAllUsers() async {
    if (_cachedUsers != null) {
      print('GlobalDataService: Returning cached users (${_cachedUsers!.length} users)');
      return _cachedUsers!;
    }

    // Return default users immediately
    final defaultUsers = ProfileConstants.defaultUsers;
    print('GlobalDataService: Returning default users immediately (${defaultUsers.length} users)');
    
    // Fetch from Firestore in background and update cache
    _fetchUsersFromFirestore();
    
    return defaultUsers;
  }

  // Fetch users from Firestore in background
  Future<void> _fetchUsersFromFirestore() async {
    try {
      print('GlobalDataService: Fetching users from homeDetails in background...');
      final homeDetails = await _homeDetailsService.getHomeDetails();
      if (homeDetails != null) {
        _cachedUsers = homeDetails.usersList;
        print('GlobalDataService: Successfully fetched ${homeDetails.usersList.length} users from homeDetails');
      } else {
        print('GlobalDataService: No homeDetails found, keeping default users');
      }
    } catch (e) {
      print('GlobalDataService: Error fetching users from homeDetails: $e');
      // Keep using default users if Firestore fails
    }
  }

  // Get all courts (from cache or Firestore)
  Future<List<Court>> getAllCourts() async {
    if (_cachedCourts != null) {
      print('GlobalDataService: Returning cached courts (${_cachedCourts!.length} courts)');
      return _cachedCourts!;
    }

    // Try to get courts from Firestore first, fallback to defaults
    try {
      final homeDetails = await _homeDetailsService.getHomeDetails();
      if (homeDetails != null && homeDetails.courtList.isNotEmpty) {
        // Merge default courts with Firestore courts, removing duplicates
        final defaultCourts = ProfileConstants.defaultCourts;
        final firestoreCourts = homeDetails.courtList;
        
        // Create a map to track unique court names
        final Map<String, Court> uniqueCourts = {};
        
        // Add default courts first
        for (final court in defaultCourts) {
          uniqueCourts[court.name] = court;
        }
        
        // Add Firestore courts (will overwrite defaults if same name)
        for (final court in firestoreCourts) {
          uniqueCourts[court.name] = court;
        }
        
        _cachedCourts = uniqueCourts.values.toList();
        print('GlobalDataService: Returning merged courts (${_cachedCourts!.length} unique courts)');
        return _cachedCourts!;
      }
    } catch (e) {
      print('GlobalDataService: Error fetching courts from homeDetails: $e');
    }

    // Fallback to default courts
    final defaultCourts = ProfileConstants.defaultCourts;
    _cachedCourts = defaultCourts;
    print('GlobalDataService: Returning default courts (${defaultCourts.length} courts)');
    
    // Fetch from Firestore in background and update cache
    _fetchCourtsFromFirestore();
    
    return defaultCourts;
  }

  // Fetch courts from Firestore in background
  Future<void> _fetchCourtsFromFirestore() async {
    try {
      print('GlobalDataService: Fetching courts from homeDetails in background...');
      final homeDetails = await _homeDetailsService.getHomeDetails();
      if (homeDetails != null) {
        // Merge default courts with Firestore courts, removing duplicates
        final defaultCourts = ProfileConstants.defaultCourts;
        final firestoreCourts = homeDetails.courtList;
        
        // Create a map to track unique court names
        final Map<String, Court> uniqueCourts = {};
        
        // Add default courts first
        for (final court in defaultCourts) {
          uniqueCourts[court.name] = court;
        }
        
        // Add Firestore courts (will overwrite defaults if same name)
        for (final court in firestoreCourts) {
          uniqueCourts[court.name] = court;
        }
        
        _cachedCourts = uniqueCourts.values.toList();
        print('GlobalDataService: Successfully merged ${_cachedCourts!.length} unique courts from homeDetails');
      } else {
        print('GlobalDataService: No homeDetails found, keeping default courts');
      }
    } catch (e) {
      print('GlobalDataService: Error fetching courts from homeDetails: $e');
      // Keep using default courts if Firestore fails
    }
  }

  // Refresh users cache
  Future<void> refreshUsers() async {
    _cachedUsers = null;
    await _fetchUsersFromFirestore();
  }

  // Refresh courts cache
  Future<void> refreshCourts() async {
    _cachedCourts = null;
    await _fetchCourtsFromFirestore();
  }

  // Clear all caches
  void clearCache() {
    _cachedUsers = null;
    _cachedCourts = null;
  }

}
