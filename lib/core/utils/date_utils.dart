import 'package:intl/intl.dart';

class DateUtils {
  static String todayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static String getWeekdayName(int weekday) {
    const names = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekday >= 1 && weekday <= 7 ? names[weekday] : '';
  }

  static String getWeekdayAbbrev(int weekday) {
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekday >= 1 && weekday <= 7 ? names[weekday] : '';
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat('EEEE, MMM dd').format(date);
  }

  static DateTime getMondayOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  static DateTime getSundayOfWeek(DateTime date) {
    final sunday = date.add(Duration(days: 7 - date.weekday));
    return DateTime(sunday.year, sunday.month, sunday.day);
  }

  static List<DateTime> getWeekDays(DateTime date) {
    final monday = getMondayOfWeek(date);
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  static String getRelativeDay(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    return DateFormat('EEEE').format(date);
  }
}
