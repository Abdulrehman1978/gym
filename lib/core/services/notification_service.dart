import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _notifications.initialize(settings: initSettings);
  }

  Future<void> scheduleWeeklyNotifications() async {
    final messages = {
      DateTime.monday:
          'PUSH DAY — Chest, Shoulders, Triceps. Let\'s go! \u{1F4AA}',
      DateTime.tuesday:
          'PULL DAY — Back, Biceps, Forearms. Build that back! \u{1F9BE}',
      DateTime.wednesday:
          'LEG DAY — Don\'t skip it. Legs build the foundation. \u{1F9B5}',
      DateTime.thursday:
          'PUSH DAY — Variation day. New angles, more growth! \u{1F4AA}',
      DateTime.friday:
          'PULL DAY — Last two days. Finish strong! \u{1F9BE}',
      DateTime.saturday:
          'LEG DAY — Last session of the week. Make it count! \u{1F9B5}',
      DateTime.sunday:
          'Rest day. Eat well, sleep well. You earned it. \u{1F634}',
    };

    for (int day = DateTime.monday; day <= DateTime.sunday; day++) {
      final hour = day == DateTime.sunday ? 9 : 7;
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour);
      while (scheduledDate.weekday != day) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      await _notifications.show(
        id: day,
        title: 'IronLog',
        body: messages[day]!,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'workout_reminder',
            'Workout Reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}