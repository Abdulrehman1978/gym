import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:ironlog/core/database/database_helper.dart';

class SyncService {
  final DatabaseHelper _db;
  final Dio _dio;

  SyncService(this._db, this._dio);

  Future<bool> isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  Future<void> syncWorkoutSession(int sessionId) async {
    final session = await _db.getById('workout_sessions', sessionId);
    if (session == null) return;

    final sets = await _db.query(
      'set_logs',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    try {
      final response = await _dio.post('/sync', data: {
        'session': session,
        'sets': sets,
      });
      if (response.statusCode == 200) {
        await _db.update(
          'workout_sessions',
          {'synced_to_cloud': 1},
          where: 'id = ?',
          whereArgs: [sessionId],
        );
      }
    } catch (_) {}
  }

  Future<void> syncAllPending() async {
    final unsynced = await _db.query(
      'workout_sessions',
      where: 'synced_to_cloud = 0',
    );
    for (final session in unsynced) {
      await syncWorkoutSession(session['id'] as int);
    }
  }

  Future<void> generateAIReport() async {
    try {
      final response = await _dio.post('/ai-report', data: {
        'workout_summary': 'User completed push/pull sessions.',
        'pr_summary': 'Hit PR on Bench Press',
      });
      
      if (response.statusCode == 200) {
        final reportJson = jsonEncode(response.data);
        // Find existing week summary
        final summaries = await _db.query('weekly_summaries', orderBy: 'id DESC', limit: 1);
        if (summaries.isNotEmpty) {
          await _db.update(
            'weekly_summaries',
            {'ai_report': reportJson},
            where: 'id = ?',
            whereArgs: [summaries.first['id']],
          );
        } else {
          // If no weekly summary, create one
          final dbInstance = await _db.database;
          await dbInstance.insert('weekly_summaries', {
            'week_start': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
            'week_end': DateTime.now().toIso8601String(),
            'ai_report': reportJson,
          });
        }
      }
    } catch (_) {}
  }
}
