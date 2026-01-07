class Event {
  final String id;
  final String clubId;
  final String name;
  final String description;
  final DateTime dateTime;
  final String createdBy;

  Event({
    required this.id,
    required this.clubId,
    required this.name,
    required this.description,
    required this.dateTime,
    required this.createdBy,
  });

  factory Event.fromMap(String id, Map<String, dynamic> data) {
    return Event(
      id: id,
      clubId: data['clubId'],
      name: data['name'],
      description: data['description'],
      dateTime: DateTime.parse(data['dateTime']),
      createdBy: data['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clubId': clubId,
      'name': name,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
