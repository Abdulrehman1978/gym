import 'package:ironlog/core/constants/app_constants.dart';
import 'package:ironlog/core/database/database_helper.dart';

enum RecoveryStatus {
  fullyRecovered,
  recovering,
  needsRest;

  String get label {
    switch (this) {
      case RecoveryStatus.fullyRecovered:
        return 'Fully Recovered \u2713';
      case RecoveryStatus.recovering:
        return 'Recovering';
      case RecoveryStatus.needsRest:
        return 'Needs Rest';
    }
  }

  String get colorHex {
    switch (this) {
      case RecoveryStatus.fullyRecovered:
        return '#00C853';
      case RecoveryStatus.recovering:
        return '#FFD600';
      case RecoveryStatus.needsRest:
        return '#D50000';
    }
  }
}

class RecoveryService {
  final DatabaseHelper _db;

  RecoveryService(this._db);

  Future<RecoveryStatus> checkMuscleRecovery(String muscleGroup) async {
    final db = await _db.database;
    final results = await db.rawQuery('''
      SELECT ws.date
      FROM workout_sessions ws
      INNER JOIN workout_days wd ON ws.workout_day_id = wd.id
      INNER JOIN day_exercises de ON wd.id = de.workout_day_id
      INNER JOIN exercises e ON de.exercise_id = e.id
      WHERE (e.muscle_primary = ? OR e.muscle_secondary = ?)
        AND ws.completed = 1
      ORDER BY ws.date DESC
      LIMIT 1
    ''', [muscleGroup, muscleGroup]);

    if (results.isEmpty) return RecoveryStatus.fullyRecovered;

    final lastDate = DateTime.parse(results.first['date'] as String);
    final hoursSince = DateTime.now().difference(lastDate).inHours;

    if (hoursSince >= AppConstants.recoveryHours) {
      return RecoveryStatus.fullyRecovered;
    } else if (hoursSince >= AppConstants.recoveryHours ~/ 2) {
      return RecoveryStatus.recovering;
    } else {
      return RecoveryStatus.needsRest;
    }
  }

  Future<Map<String, RecoveryStatus>> getAllMuscleRecovery() async {
    const muscleGroups = [
      'Chest',
      'Upper Chest',
      'Side Delts',
      'Front Delts',
      'Triceps',
      'Lats',
      'Mid Back',
      'Biceps',
      'Brachialis',
      'Forearms',
      'Quads',
      'Hamstrings',
      'Lower Abs',
      'Obliques',
    ];
    final results = <String, RecoveryStatus>{};
    for (final group in muscleGroups) {
      results[group] = await checkMuscleRecovery(group);
    }
    return results;
  }
}
