import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ironlog/core/models/set_log_model.dart';
import 'package:ironlog/core/models/workout_session_model.dart';
import 'package:ironlog/features/home/home_provider.dart';

class WorkoutState {
  final int? currentSessionId;
  final WorkoutSession? session;
  final List<SetLog> currentSets;
  final int currentExerciseIndex;
  final int currentSetNumber;
  final bool isResting;
  final int restSecondsRemaining;
  final int? activeTimerSeconds;
  final bool isComplete;

  WorkoutState({
    this.currentSessionId,
    this.session,
    this.currentSets = const [],
    this.currentExerciseIndex = 0,
    this.currentSetNumber = 1,
    this.isResting = false,
    this.restSecondsRemaining = 0,
    this.activeTimerSeconds,
    this.isComplete = false,
  });

  WorkoutState copyWith({
    int? currentSessionId,
    WorkoutSession? session,
    List<SetLog>? currentSets,
    int? currentExerciseIndex,
    int? currentSetNumber,
    bool? isResting,
    int? restSecondsRemaining,
    int? activeTimerSeconds,
    bool? isComplete,
  }) {
    return WorkoutState(
      currentSessionId: currentSessionId ?? this.currentSessionId,
      session: session ?? this.session,
      currentSets: currentSets ?? this.currentSets,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSetNumber: currentSetNumber ?? this.currentSetNumber,
      isResting: isResting ?? this.isResting,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
      activeTimerSeconds: activeTimerSeconds ?? this.activeTimerSeconds,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final Ref _ref;
  Timer? _restTimer;
  Timer? _activeTimer;

  WorkoutNotifier(this._ref) : super(WorkoutState());

  @override
  void dispose() {
    _restTimer?.cancel();
    _activeTimer?.cancel();
    super.dispose();
  }

  Future<void> startWorkout(int workoutDayId, String date, bool isDeloadWeek) async {
    final workoutService = _ref.read(workoutServiceProvider);
    final sessionId = await workoutService.startWorkout(workoutDayId, date, isDeloadWeek);

    state = state.copyWith(
      currentSessionId: sessionId,
      session: WorkoutSession(
        id: sessionId,
        date: date,
        workoutDayId: workoutDayId,
        isDeloadWeek: isDeloadWeek,
      ),
      currentSets: [],
      currentExerciseIndex: 0,
      currentSetNumber: 1,
      isComplete: false,
    );
  }

  Future<void> logSet(int exerciseId, int setNumber, double weight, int reps, {bool isWarmup = false, int? rpe}) async {
    final sessionId = state.currentSessionId;
    if (sessionId == null) return;

    final workoutService = _ref.read(workoutServiceProvider);
    await workoutService.logSet(sessionId, exerciseId, setNumber, weight, reps, isWarmup: isWarmup, rpe: rpe);

    final prService = _ref.read(prServiceProvider);
    await prService.checkForPR(exerciseId, weight, reps, sessionId);

    final setLog = SetLog(
      sessionId: sessionId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      weightKg: weight,
      reps: reps,
      isWarmupSet: isWarmup,
      rpeActual: rpe,
    );

    state = state.copyWith(
      currentSets: [...state.currentSets, setLog],
      currentSetNumber: setNumber + 1,
    );
  }

  Future<void> completeWorkout(int durationMinutes, int feeling, String? notes) async {
    final sessionId = state.currentSessionId;
    if (sessionId == null) return;

    final workoutService = _ref.read(workoutServiceProvider);
    await workoutService.completeWorkout(sessionId, durationMinutes, feeling, notes);

    _restTimer?.cancel();
    _activeTimer?.cancel();

    state = state.copyWith(isComplete: true, isResting: false);
  }

  void startRest(int seconds) {
    _restTimer?.cancel();
    state = state.copyWith(isResting: true, restSecondsRemaining: seconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.restSecondsRemaining > 0) {
        tickRest();
      } else {
        _restTimer?.cancel();
      }
    });
  }

  void skipRest() {
    _restTimer?.cancel();
    state = state.copyWith(isResting: false, restSecondsRemaining: 0);
  }

  void tickRest() {
    if (state.restSecondsRemaining > 0) {
      state = state.copyWith(restSecondsRemaining: state.restSecondsRemaining - 1);
    } else {
      _restTimer?.cancel();
      state = state.copyWith(isResting: false, restSecondsRemaining: 0);
    }
  }

  void nextExercise() {
    _restTimer?.cancel();
    state = state.copyWith(
      currentExerciseIndex: state.currentExerciseIndex + 1,
      currentSetNumber: 1,
      isResting: false,
      restSecondsRemaining: 0,
    );
  }

  void previousExercise() {
    if (state.currentExerciseIndex > 0) {
      _restTimer?.cancel();
      state = state.copyWith(
        currentExerciseIndex: state.currentExerciseIndex - 1,
        currentSetNumber: 1,
        isResting: false,
        restSecondsRemaining: 0,
      );
    }
  }
}

final workoutProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) => WorkoutNotifier(ref));

final dayExercisesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, workoutDayId) async {
  final db = ref.read(databaseProvider);
  final database = await db.database;
  return await database.rawQuery('''
    SELECT de.*, e.name, e.muscle_primary, e.default_rest_seconds, e.default_rpe_target, e.is_compound
    FROM day_exercises de
    INNER JOIN exercises e ON de.exercise_id = e.id
    WHERE de.workout_day_id = ?
    ORDER BY de.order_index
  ''', [workoutDayId]);
});

final workoutDayProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  final db = ref.read(databaseProvider);
  final results = await db.query('workout_days', where: 'id = ?', whereArgs: [id]);
  return results.isNotEmpty ? results.first.cast<String, dynamic>() : null;
});

final sessionSetsProvider = FutureProvider.family<List<SetLog>, int>((ref, sessionId) async {
  final workoutService = ref.read(workoutServiceProvider);
  return await workoutService.getSessionSets(sessionId);
});

final sessionVolumeProvider = FutureProvider.family<double, int>((ref, sessionId) async {
  final db = ref.read(databaseProvider);
  final database = await db.database;
  final result = await database.rawQuery('''
    SELECT COALESCE(SUM(weight_kg * reps), 0) as volume
    FROM set_logs
    WHERE session_id = ?
  ''', [sessionId]);
  return (result.first['volume'] as num).toDouble();
});

final sessionPRsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, sessionId) async {
  final db = ref.read(databaseProvider);
  final database = await db.database;
  return await database.rawQuery('''
    SELECT pr.*, e.name as exercise_name
    FROM personal_records pr
    INNER JOIN exercises e ON pr.exercise_id = e.id
    WHERE pr.session_id = ?
    ORDER BY pr.date DESC
  ''', [sessionId]);
});

final nextWorkoutDayProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, currentDayId) async {
  final db = ref.read(databaseProvider);
  final database = await db.database;
  final results = await database.rawQuery('''
    SELECT * FROM workout_days
    WHERE day_number > (SELECT day_number FROM workout_days WHERE id = ?)
    ORDER BY day_number
    LIMIT 1
  ''', [currentDayId]);
  if (results.isNotEmpty) return results.first;
  final mondayResults = await database.rawQuery("SELECT * FROM workout_days WHERE day_number = 1 LIMIT 1");
  return mondayResults.isNotEmpty ? mondayResults.first : null;
});
