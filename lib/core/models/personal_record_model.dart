class PersonalRecord {
  final int? id;
  final int exerciseId;
  final double weightKg;
  final int reps;
  final double? estimated1rm;
  final String date;
  final int? sessionId;

  PersonalRecord({
    this.id,
    required this.exerciseId,
    required this.weightKg,
    required this.reps,
    this.estimated1rm,
    required this.date,
    this.sessionId,
  });

  factory PersonalRecord.fromMap(Map<String, dynamic> map) {
    return PersonalRecord(
      id: map['id'] as int?,
      exerciseId: map['exerciseId'] as int,
      weightKg: (map['weightKg'] as num).toDouble(),
      reps: map['reps'] as int,
      estimated1rm: (map['estimated1rm'] as num?)?.toDouble(),
      date: map['date'] as String,
      sessionId: map['sessionId'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'exerciseId': exerciseId,
      'weightKg': weightKg,
      'reps': reps,
      'estimated1rm': estimated1rm,
      'date': date,
      'sessionId': sessionId,
    };
  }

  PersonalRecord copyWith({
    int? id,
    int? exerciseId,
    double? weightKg,
    int? reps,
    double? estimated1rm,
    String? date,
    int? sessionId,
  }) {
    return PersonalRecord(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      estimated1rm: estimated1rm ?? this.estimated1rm,
      date: date ?? this.date,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
