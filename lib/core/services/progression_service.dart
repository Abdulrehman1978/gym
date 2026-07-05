import 'package:ironlog/core/constants/app_constants.dart';
import 'package:ironlog/core/database/database_helper.dart';
import 'package:ironlog/core/models/progression_suggestion_model.dart';
import 'package:ironlog/core/services/workout_service.dart';

class ProgressionService {
  final DatabaseHelper _db;
  final WorkoutService _workoutService;

  ProgressionService(this._db, this._workoutService);

  Future<ProgressionSuggestion?> checkProgression(int exerciseId, bool isLowerBody) async {
    final progress = await _workoutService.getStrengthProgress(exerciseId);
    if (progress.length < AppConstants.targetProgressSessions) return null;

    final lastTwo = progress.take(AppConstants.targetProgressSessions).toList();
    final firstWeight = (lastTwo[0]['max_weight'] as num).toDouble();
    final secondWeight = (lastTwo[1]['max_weight'] as num).toDouble();

    if (firstWeight != secondWeight) return null;

    final increment = isLowerBody
        ? AppConstants.lowerBodyProgressionKg
        : AppConstants.upperBodyProgressionKg;
    final suggestedWeight = firstWeight + increment;

    return ProgressionSuggestion(
      exerciseId: exerciseId,
      currentWeight: firstWeight,
      suggestedWeight: suggestedWeight,
      message:
          'Ready to progress from ${firstWeight}kg to ${suggestedWeight}kg!',
    );
  }

  Future<void> logProgression(int exerciseId, double oldWeight, double newWeight, String reason) async {
    await _db.insert('progression_log', {
      'exercise_id': exerciseId,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'old_weight': oldWeight,
      'new_weight': newWeight,
      'reason': reason,
    });
  }
}
