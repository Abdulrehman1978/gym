class WeeklySummary {
  final int? id;
  final String weekStart;
  final String weekEnd;
  final int sessionsCompleted;
  final double totalVolumeKg;
  final String? aiReport;
  final bool synced;

  WeeklySummary({
    this.id,
    required this.weekStart,
    required this.weekEnd,
    this.sessionsCompleted = 0,
    this.totalVolumeKg = 0,
    this.aiReport,
    this.synced = false,
  });

  factory WeeklySummary.fromMap(Map<String, dynamic> map) {
    return WeeklySummary(
      id: map['id'] as int?,
      weekStart: map['weekStart'] as String,
      weekEnd: map['weekEnd'] as String,
      sessionsCompleted: (map['sessionsCompleted'] as num?)?.toInt() ?? 0,
      totalVolumeKg: (map['totalVolumeKg'] as num?)?.toDouble() ?? 0,
      aiReport: map['aiReport'] as String?,
      synced: (map['synced'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'weekStart': weekStart,
      'weekEnd': weekEnd,
      'sessionsCompleted': sessionsCompleted,
      'totalVolumeKg': totalVolumeKg,
      'aiReport': aiReport,
      'synced': synced ? 1 : 0,
    };
  }

  WeeklySummary copyWith({
    int? id,
    String? weekStart,
    String? weekEnd,
    int? sessionsCompleted,
    double? totalVolumeKg,
    String? aiReport,
    bool? synced,
  }) {
    return WeeklySummary(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      aiReport: aiReport ?? this.aiReport,
      synced: synced ?? this.synced,
    );
  }
}
