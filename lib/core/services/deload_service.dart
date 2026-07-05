import 'package:ironlog/core/constants/app_constants.dart';

class DeloadService {
  bool isDeloadWeek(DateTime date) {
    final weekNumber = _getWeekNumber(date);
    return weekNumber % AppConstants.deloadWeekInterval == 0;
  }

  double getDeloadWeight(double normalWeight) {
    return normalWeight * AppConstants.deloadWeightFactor;
  }

  int getDeloadSets(int normalSets) {
    return normalSets - AppConstants.deloadSetReduction;
  }

  int _getWeekNumber(DateTime date) {
    final jan1 = DateTime(date.year, 1, 1);
    final days = date.difference(jan1).inDays;
    return ((days + jan1.weekday - 1) / 7).ceil();
  }
}
