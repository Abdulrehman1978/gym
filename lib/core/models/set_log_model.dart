class SetLog {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final int setNumber;
  final double weightKg;
  final int reps;
  final bool isWarmupSet;
  final bool completed;
  final int? rpeActual;
  final int? formRating;
  final String? timestamp;

  SetLog({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.isWarmupSet = false,
    this.completed = true,
    this.rpeActual,
    this.formRating,
    this.timestamp,
  });

  factory SetLog.fromMap(Map<String, dynamic> map) {
    return SetLog(
      id: map['id'] as int?,
      sessionId: map['sessionId'] as int,
      exerciseId: map['exerciseId'] as int,
      setNumber: map['setNumber'] as int,
      weightKg: (map['weightKg'] as num).toDouble(),
      reps: map['reps'] as int,
      isWarmupSet: (map['isWarmupSet'] as int? ?? 0) == 1,
      completed: (map['completed'] as int? ?? 1) == 1,
      rpeActual: map['rpeActual'] as int?,
      formRating: map['formRating'] as int?,
      timestamp: map['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'setNumber': setNumber,
      'weightKg': weightKg,
      'reps': reps,
      'isWarmupSet': isWarmupSet ? 1 : 0,
      'completed': completed ? 1 : 0,
      'rpeActual': rpeActual,
      'formRating': formRating,
      'timestamp': timestamp,
    };
  }

  SetLog copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    int? setNumber,
    double? weightKg,
    int? reps,
    bool? isWarmupSet,
    bool? completed,
    int? rpeActual,
    int? formRating,
    String? timestamp,
  }) {
    return SetLog(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      isWarmupSet: isWarmupSet ?? this.isWarmupSet,
      completed: completed ?? this.completed,
      rpeActual: rpeActual ?? this.rpeActual,
      formRating: formRating ?? this.formRating,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
