import 'package:ironlog/core/database/database_helper.dart';
import 'package:ironlog/core/models/set_log_model.dart';
import 'package:ironlog/core/models/workout_session_model.dart';

class WorkoutService {
  final DatabaseHelper _db;

  WorkoutService(this._db);

  Future<int> startWorkout(int workoutDayId, String date, bool isDeloadWeek) async {
    return await _db.insert('workout_sessions', {
      'workout_day_id': workoutDayId,
      'date': date,
      'is_deload_week': isDeloadWeek ? 1 : 0,
      'started_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> logSet(int sessionId, int exerciseId, int setNumber, double weightKg, int reps,
      {bool isWarmup = false, int? rpe}) async {
    await _db.insert('set_logs', {
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'weight_kg': weightKg,
      'reps': reps,
      'is_warmup_set': isWarmup ? 1 : 0,
      'rpe_actual': rpe,
    });
  }

  Future<void> completeWorkout(int sessionId, int durationMinutes, int overallFeeling, String? notes) async {
    await _db.update(
      'workout_sessions',
      {
        'completed': 1,
        'duration_minutes': durationMinutes,
        'overall_feeling': overallFeeling,
        'notes': notes,
        'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<SetLog>> getSessionSets(int sessionId) async {
    final results = await _db.query(
      'set_logs',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'set_number',
    );
    return results.map((m) => SetLog.fromMap(m.cast<String, dynamic>())).toList();
  }

  Future<List<WorkoutSession>> getRecentSessions({int limit = 10}) async {
    final results = await _db.query(
      'workout_sessions',
      where: 'completed = 1',
      orderBy: 'date DESC',
      limit: limit,
    );
    return results.map((m) => WorkoutSession.fromMap(m.cast<String, dynamic>())).toList();
  }

  Future<Map<String, double>> getWeeklyVolume(String weekStart, String weekEnd) async {
    final db = await _db.database;
    final results = await db.rawQuery('''
      SELECT COALESCE(SUM(sl.weight_kg * sl.reps), 0) as volume
      FROM set_logs sl
      INNER JOIN workout_sessions ws ON sl.session_id = ws.id
      WHERE ws.date >= ? AND ws.date <= ? AND ws.completed = 1
    ''', [weekStart, weekEnd]);
    final volume = (results.first['volume'] as num).toDouble();
    return {'volume': volume};
  }

  Future<int> getSessionsCompletedInWeek(String weekStart, String weekEnd) async {
    return await _db.getCount(
      'workout_sessions',
      where: 'date >= ? AND date <= ? AND completed = 1',
      whereArgs: [weekStart, weekEnd],
    );
  }

  Future<int> getCurrentStreak() async {
    final results = await _db.query(
      'workout_sessions',
      where: 'completed = 1',
      orderBy: 'date DESC',
    );
    if (results.isEmpty) return 0;

    final uniqueDates = results
        .map((r) => r['date'] as String)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    final today = DateTime.now();
    for (final dateStr in uniqueDates) {
      final date = DateTime.parse(dateStr);
      final expected = today.subtract(Duration(days: streak));
      if (date.year == expected.year &&
          date.month == expected.month &&
          date.day == expected.day) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<double> getTotalVolume() async {
    final db = await _db.database;
    final results = await db.rawQuery('''
      SELECT COALESCE(SUM(sl.weight_kg * sl.reps), 0) as total
      FROM set_logs sl
      INNER JOIN workout_sessions ws ON sl.session_id = ws.id
      WHERE ws.completed = 1
    ''');
    return (results.first['total'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getStrengthProgress(int exerciseId) async {
    final db = await _db.database;
    return await db.rawQuery('''
      SELECT ws.date,
             MAX(sl.weight_kg) as max_weight,
             MAX(sl.reps) as max_reps,
             SUM(sl.weight_kg * sl.reps) as volume
      FROM set_logs sl
      INNER JOIN workout_sessions ws ON sl.session_id = ws.id
      WHERE sl.exercise_id = ? AND ws.completed = 1
      GROUP BY sl.session_id
      ORDER BY ws.date DESC
      LIMIT 10
    ''', [exerciseId]);
  }
}
