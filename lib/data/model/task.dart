class Task {
  final int? id;
  final String day;
  final String content;
  final String timeRange;
  final String location;
  final String organizer;
  final String notes;
  final int isCompleted;

  Task({
    this.id,
    required this.day,
    required this.content,
    required this.timeRange,
    required this.location,
    required this.organizer,
    required this.notes,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'content': content,
      'timeRange': timeRange,
      'location': location,
      'organizer': organizer,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      day: map['day'],
      content: map['content'],
      timeRange: map['timeRange'],
      location: map['location'],
      organizer: map['organizer'],
      notes: map['notes'],
      isCompleted: map['isCompleted'],
    );
  }
}
