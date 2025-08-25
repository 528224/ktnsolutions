import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Recognition {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? link;
  final DateTime publishedDate;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Recognition({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.link,
    required this.publishedDate,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Recognition to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'link': link,
      'publishedDate': Timestamp.fromDate(publishedDate),
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create Recognition from Firestore document
  factory Recognition.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recognition(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      link: data['link'],
      publishedDate: (data['publishedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Create a copy of the recognition with updated fields
  Recognition copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? link,
    DateTime? publishedDate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recognition(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      publishedDate: publishedDate ?? this.publishedDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Format published date as 'dd/MM/yyyy'
  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(publishedDate);
  }

  // Extract title/domain from link if available
  String? get sourceTitle {
    if (link == null) return null;
    
    try {
      Uri uri = Uri.parse(link!);
      
      // Handle Google redirect URLs
      if (uri.host == 'www.google.com' && uri.path == '/url') {
        final urlParam = uri.queryParameters['url'];
        if (urlParam != null) {
          try {
            final decodedUrl = Uri.decodeFull(urlParam);
            uri = Uri.parse(decodedUrl);
          } catch (e) {
            // If parsing fails, continue with main domain
          }
        }
      }
      
      // Remove www. and return the domain
      return uri.host.replaceFirst(RegExp('^www\\.'), '');
    } catch (e) {
      return null;
    }
  }

  // Get subtitle/displayURL (formatted for UI)
  String? get sourceSubTitle {
    if (link == null) return null;

    try {
      final uri = Uri.parse(link!);

      // Handle Google redirect URLs
      if (uri.host == 'www.google.com' && uri.path == '/url') {
        final urlParam = uri.queryParameters['url'];
        if (urlParam != null) {
          try {
            final decodedUrl = Uri.decodeFull(urlParam);
            final innerUri = Uri.parse(decodedUrl);
            return _formatDisplayUrl(innerUri);
          } catch (e) {
            // If parsing fails, continue with main domain
          }
        }
      }

      return _formatDisplayUrl(uri);
    } catch (e) {
      return null;
    }
  }


  // Get base URL for redirection (without path)
  String? get sourceUrl {
    if (link == null) return null;
    
    try {
      Uri uri = Uri.parse(link!);
      
      // Handle Google redirect URLs
      if (uri.host == 'www.google.com' && uri.path == '/url') {
        final urlParam = uri.queryParameters['url'];
        if (urlParam != null) {
          try {
            final decodedUrl = Uri.decodeFull(urlParam);
            uri = Uri.parse(decodedUrl);
          } catch (e) {
            // If parsing fails, continue with main domain
          }
        }
      }
      
      // Return the base URL with proper scheme
      final scheme = uri.scheme.isNotEmpty ? uri.scheme : 'https';
      return '$scheme://${uri.host}';
    } catch (e) {
      return null;
    }
  }

  // Get favicon URL
  String? get faviconUrl {
    if (link == null) return null;
    
    try {
      Uri uri = Uri.parse(link!);
      
      // Handle Google redirect URLs
      if (uri.host == 'www.google.com' && uri.path == '/url') {
        final urlParam = uri.queryParameters['url'];
        if (urlParam != null) {
          try {
            final decodedUrl = Uri.decodeFull(urlParam);
            uri = Uri.parse(decodedUrl);
          } catch (e) {
            // If parsing fails, continue with main domain
          }
        }
      }
      
      return '${uri.scheme}://${uri.host}/favicon.ico';
    } catch (e) {
      return null;
    }
  }

  // Helper method to format display URL
  String _formatDisplayUrl(Uri uri) {
    final scheme = uri.scheme.isNotEmpty ? '${uri.scheme}://' : 'https://';
    
    // Special handling for judiciary.karnataka.gov.in
    if (uri.host == 'judiciary.karnataka.gov.in') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty && pathSegments[0] == 'karjud' && pathSegments[1].startsWith('cino_det')) {
        return '${scheme}judiciary.karnataka.gov.in › karjud › cino_det';
      }
    }
    
    // Special handling for ecourtsindia.com
    if (uri.host == 'ecourtsindia.com') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty && pathSegments[0] == 'cnr' && pathSegments.length > 1) {
        return '${scheme}ecourtsindia.com › cnr > ${pathSegments[1]}';
      }
    }
    
    // Default formatting for other URLs
    final host = uri.host.replaceFirst('www.', '');
    final path = uri.path.isNotEmpty ? ' › ${uri.path.split('/').where((s) => s.isNotEmpty).join(' › ')}' : '';
    final fragment = uri.fragment.isNotEmpty ? ' #${uri.fragment}' : '';
    
    // Truncate if too long
    final fullUrl = '$scheme$host$path$fragment';
    return fullUrl.length > 50 ? '${fullUrl.substring(0, 47)}...' : fullUrl;
  }

  // Check if the recognition has a valid link
  bool get hasValidLink => link != null && Uri.tryParse(link!) != null;

  // Check if the recognition is empty
  bool get isEmpty => id.isEmpty;

  // Check if the recognition is not empty
  bool get isNotEmpty => !isEmpty;

  // Create an empty recognition
  static Recognition empty() {
    return Recognition(
      id: '',
      title: '',
      description: '',
      imageUrl: '',
      publishedDate: DateTime.now(),
    );
  }
}
