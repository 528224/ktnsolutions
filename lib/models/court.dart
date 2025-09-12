class Court {
  final String name;

  Court({
    required this.name,
  });

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Court && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

// Global list of courts
final List<Court> globalCourts = [
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
