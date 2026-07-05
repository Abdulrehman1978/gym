import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:ironlog/core/database/database_helper.dart';

class SyncService {
  final DatabaseHelper _db;
  final Dio _dio;

  SyncService(this._db, this._dio);

  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
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
}
