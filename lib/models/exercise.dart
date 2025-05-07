class Exercise {
  int? id;
  String name;
  DateTime date;
  int? duration; // in minutes
  int? reps;
  String? notes;

  Exercise({
    this.id,
    required this.name,
    required this.date,
    this.duration,
    this.reps,
    this.notes,
  });

  // Factory constructor to create an Exercise object from a map
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      duration: map['duration'],
      reps: map['reps'],
      notes: map['notes'],
    );
  }

  // Method to convert an Exercise object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'duration': duration,
      'reps': reps,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'Exercise{id: $id, name: $name, date: $date, duration: $duration, reps: $reps, notes: $notes}';
  }
}