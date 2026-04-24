class Task {
  int? id;
  String title;
  String description;
  int synced;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'synced': synced,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      synced: map['synced'] ?? 0,
    );
  }
}
