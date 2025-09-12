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
  Court(
    name: 'Court1',
  ),
  Court(
    name: 'Court2',
  ),
];
