class Club {
  final String id;
  final String name;
  final String description;
  final String ownerUid;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerUid,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'ownerUid': ownerUid,
      'createdAt': DateTime.now(),
    };
  }

  factory Club.fromMap(String id, Map<String, dynamic> map) {
  return Club(
    id: id,
    name: map['name'] ?? 'Unnamed Club',
    description: map['description'] ?? '',
    ownerUid: map['ownerUid'] ?? '',
  );
}

}

