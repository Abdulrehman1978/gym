import 'package:flutter/material.dart';
import 'package:ironlog/core/utils/date_utils.dart' as du;
import 'package:ironlog/features/home/home_screen.dart';
import 'package:ironlog/features/workout/active_workout_screen.dart';
import 'package:ironlog/features/workout/workout_complete_screen.dart';
import 'package:ironlog/features/exercise_detail/exercise_detail_screen.dart';
import 'package:ironlog/features/library/exercise_library_screen.dart';
import 'package:ironlog/features/progress/progress_screen.dart';
import 'package:ironlog/features/ai_report/ai_report_screen.dart';
import 'package:ironlog/shared/theme/app_theme.dart';

class IronLogApp extends StatelessWidget {
  const IronLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IronLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/workout':
            final args = settings.arguments;
            int workoutDayId;
            String date = du.DateUtils.todayDate();
            bool isDeloadWeek = false;
            if (args is Map) {
              workoutDayId = args['workoutDayId'] as int;
              date = args['date'] as String? ?? du.DateUtils.todayDate();
              isDeloadWeek = args['isDeloadWeek'] as bool? ?? false;
            } else {
              workoutDayId = args as int;
            }
            return MaterialPageRoute(
              builder: (_) => ActiveWorkoutScreen(
                workoutDayId: workoutDayId,
                date: date,
                isDeloadWeek: isDeloadWeek,
              ),
            );
          case '/workout-complete':
            final map = settings.arguments as Map;
            return MaterialPageRoute(
              builder: (_) => WorkoutCompleteScreen(
                sessionId: map['sessionId'] as int,
                durationMinutes: map['durationMinutes'] as int,
                date: map['date'] as String,
                workoutDayId: map['workoutDayId'] as int,
              ),
            );
          case '/exercise-detail':
            final exerciseId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => ExerciseDetailScreen(exerciseId: exerciseId),
            );
          case '/library':
            return MaterialPageRoute(builder: (_) => const LibraryScreen());
          case '/progress':
            return MaterialPageRoute(builder: (_) => const ProgressScreen());
          case '/ai-report':
            return MaterialPageRoute(builder: (_) => const AIReportScreen());
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
