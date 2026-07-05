import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ironlog/core/database/database_helper.dart';
import 'package:ironlog/core/models/workout_session_model.dart';
import 'package:ironlog/core/services/deload_service.dart';
import 'package:ironlog/core/services/pr_service.dart';
import 'package:ironlog/core/services/progression_service.dart';
import 'package:ironlog/core/services/recovery_service.dart';
import 'package:ironlog/core/services/workout_service.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final workoutServiceProvider = Provider<WorkoutService>((ref) => WorkoutService(ref.read(databaseProvider)));

final deloadServiceProvider = Provider<DeloadService>((ref) => DeloadService());

final progressionServiceProvider = Provider<ProgressionService>((ref) =>
    ProgressionService(ref.read(databaseProvider), ref.read(workoutServiceProvider)));

final recoveryServiceProvider = Provider<RecoveryService>((ref) =>
    RecoveryService(ref.read(databaseProvider)));

final prServiceProvider = Provider<PRService>((ref) => PRService(ref.read(databaseProvider)));

class HomeState {
  final List<WorkoutSession> recentSessions;
  final int currentStreak;
  final double totalVolume;
  final int completedThisWeek;
  final bool isLoading;
  final String? error;

  HomeState({
    this.recentSessions = const [],
    this.currentStreak = 0,
    this.totalVolume = 0.0,
    this.completedThisWeek = 0,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<WorkoutSession>? recentSessions,
    int? currentStreak,
    double? totalVolume,
    int? completedThisWeek,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      recentSessions: recentSessions ?? this.recentSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      totalVolume: totalVolume ?? this.totalVolume,
      completedThisWeek: completedThisWeek ?? this.completedThisWeek,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref _ref;

  HomeNotifier(this._ref) : super(HomeState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final workoutService = _ref.read(workoutServiceProvider);

      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final sunday = now.add(Duration(days: 7 - now.weekday));
      final weekStart = '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
      final weekEnd = '${sunday.year}-${sunday.month.toString().padLeft(2, '0')}-${sunday.day.toString().padLeft(2, '0')}';

      final results = await Future.wait([
        workoutService.getCurrentStreak(),
        workoutService.getTotalVolume(),
        workoutService.getSessionsCompletedInWeek(weekStart, weekEnd),
        workoutService.getRecentSessions(limit: 10),
      ]);

      state = state.copyWith(
        currentStreak: results[0] as int,
        totalVolume: results[1] as double,
        completedThisWeek: results[2] as int,
        recentSessions: results[3] as List<WorkoutSession>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> getTodaysWorkoutDay() async {
    final db = _ref.read(databaseProvider);
    final weekday = DateTime.now().weekday;

    if (weekday >= 1 && weekday <= 6) {
      final results = await db.query(
        'workout_days',
        where: 'day_number = ?',
        whereArgs: [weekday],
      );
      if (results.isNotEmpty) {
        return results.first.cast<String, dynamic>();
      }
    }
    return null;
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) => HomeNotifier(ref));
