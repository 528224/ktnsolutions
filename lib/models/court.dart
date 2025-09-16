class Court {
  final String name;

  Court({
    required this.name,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Court && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

// Note: globalCourts array has been moved to Firestore collection 'allCourts'
// Use GlobalDataService().getAllCourts() to fetch courts from Firestore
// Default values are maintained as fallback in the service
