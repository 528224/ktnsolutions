import 'package:ktnsolutions/models/user.dart';
import 'package:ktnsolutions/models/court.dart';

class ProfileConstants {
  // Default profile information
  static const String defaultName = "Adv. PRABHU K N";
  static const String defaultDesignation = "Supreme Court & All High Courts";
  static const String defaultFirmName = "KTN Solutions Lawyers";
  static const String defaultEmail = "ktnsolutionslawyers@gmail.com";
  
  static const List<String> defaultPhoneNumbers = [
    "9388118177",
    "9544322000",
  ];
  
  static const List<String> defaultOffices = [
    "Chamber No.D 422, D Block, Additional Building Complex, Supreme Court, New Delhi - 110 001",
    "4th Floor, Peace Tower, Opp North Gate Of Collectorate & District Panchayath Ayyanthole, Thrissur - 680 003",
    "2nd Floor, Delma Express, Opposite Cherupushpam Girls Higher Secondary School, Vadakkencherry, Palakkad - 678 683",
  ];

  // Default users list
  static List<UserDetails> get defaultUsers => [
    UserDetails(
      id: '1',
      name: 'Prbhu',
      mobile: '+919544322000',
      isAdmin: true,
    ),
    UserDetails(
      id: '2',
      name: 'Cristo',
      mobile: '+919846476909',
      isAdmin: false,
    ),
    UserDetails(
      id: '3',
      name: 'Simjo',
      mobile: '+911234567890',
      isAdmin: true,
    ),
  ];

  // Default courts list
  static List<Court> get defaultCourts => [
    Court(name: 'Supreme Court of India'),
    Court(name: 'Delhi High Court'),
    Court(name: 'Kerala High Court'),
    Court(name: 'Karnataka High Court'),
    Court(name: 'Tamil Nadu High Court'),
    Court(name: 'Maharashtra High Court'),
    Court(name: 'Gujarat High Court'),
    Court(name: 'Rajasthan High Court'),
    Court(name: 'Punjab & Haryana High Court'),
    Court(name: 'Madhya Pradesh High Court'),
    Court(name: 'District Court - Thrissur'),
    Court(name: 'District Court - Palakkad'),
    Court(name: 'District Court - Ernakulam'),
    Court(name: 'District Court - Kozhikode'),
    Court(name: 'Family Court'),
    Court(name: 'Consumer Court'),
    Court(name: 'Labour Court'),
    Court(name: 'Other'),
  ];
}
