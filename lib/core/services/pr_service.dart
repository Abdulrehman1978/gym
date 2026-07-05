import 'package:ironlog/core/database/database_helper.dart';
import 'package:ironlog/core/models/personal_record_model.dart';
import 'package:ironlog/core/utils/rm_calculator.dart';

class PRService {
  final DatabaseHelper _db;

  PRService(this._db);

  Future<PersonalRecord?> checkForPR(int exerciseId, double weightKg, int reps, int sessionId) async {
    final existing = await _db.query(
      'personal_records',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'weight_kg DESC, reps DESC',
      limit: 1,
    );

    bool isPR = false;
    if (existing.isEmpty) {
      isPR = true;
    } else {
      final oldWeight = (existing.first['weight_kg'] as num).toDouble();
      final oldReps = existing.first['reps'] as int;
      if ((weightKg > oldWeight && reps >= oldReps) ||
          (weightKg == oldWeight && reps > oldReps) ||
          (reps > oldReps && weightKg >= oldWeight)) {
        isPR = true;
      }
    }

    if (!isPR) return null;

    final pr = PersonalRecord(
      exerciseId: exerciseId,
      weightKg: weightKg,
      reps: reps,
        estimated1rm: OneRepMaxCalculator.estimate1RM(weightKg, reps),
      date: DateTime.now().toIso8601String().split('T')[0],
      sessionId: sessionId,
    );

    final id = await _db.insert('personal_records', pr.toMap());
    return pr.copyWith(id: id);
  }

  Future<List<Map<String, dynamic>>> getRecentPRs({int limit = 5}) async {
    final db = await _db.database;
    return await db.rawQuery('''
      SELECT pr.*, e.name as exercise_name
      FROM personal_records pr
      INNER JOIN exercises e ON pr.exercise_id = e.id
      ORDER BY pr.date DESC
      LIMIT ?
    ''', [limit]);
  }
}
