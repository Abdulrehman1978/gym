class WorkoutSession {
  final int? id;
  final String date;
  final int workoutDayId;
  final String? startedAt;
  final String? completedAt;
  final int? durationMinutes;
  final bool completed;
  final int? overallFeeling;
  final bool isDeloadWeek;
  final String? notes;
  final bool syncedToCloud;

  WorkoutSession({
    this.id,
    required this.date,
    required this.workoutDayId,
    this.startedAt,
    this.completedAt,
    this.durationMinutes,
    this.completed = false,
    this.overallFeeling,
    this.isDeloadWeek = false,
    this.notes,
    this.syncedToCloud = false,
  });

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as int?,
      date: map['date'] as String,
      workoutDayId: map['workoutDayId'] as int,
      startedAt: map['startedAt'] as String?,
      completedAt: map['completedAt'] as String?,
      durationMinutes: map['durationMinutes'] as int?,
      completed: (map['completed'] as int? ?? 0) == 1,
      overallFeeling: map['overallFeeling'] as int?,
      isDeloadWeek: (map['isDeloadWeek'] as int? ?? 0) == 1,
      notes: map['notes'] as String?,
      syncedToCloud: (map['syncedToCloud'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'workoutDayId': workoutDayId,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'durationMinutes': durationMinutes,
      'completed': completed ? 1 : 0,
      'overallFeeling': overallFeeling,
      'isDeloadWeek': isDeloadWeek ? 1 : 0,
      'notes': notes,
      'syncedToCloud': syncedToCloud ? 1 : 0,
    };
  }

  WorkoutSession copyWith({
    int? id,
    String? date,
    int? workoutDayId,
    String? startedAt,
    String? completedAt,
    int? durationMinutes,
    bool? completed,
    int? overallFeeling,
    bool? isDeloadWeek,
    String? notes,
    bool? syncedToCloud,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      date: date ?? this.date,
      workoutDayId: workoutDayId ?? this.workoutDayId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completed: completed ?? this.completed,
      overallFeeling: overallFeeling ?? this.overallFeeling,
      isDeloadWeek: isDeloadWeek ?? this.isDeloadWeek,
      notes: notes ?? this.notes,
      syncedToCloud: syncedToCloud ?? this.syncedToCloud,
    );
  }
}
