class WeightUtils {
  static String formatWeight(double kg) {
    if (kg == kg.roundToDouble()) {
      return '${kg.round()}kg';
    }
    return '${kg.toStringAsFixed(1)}kg';
  }

  static double roundToNearest(double weight, double increment) {
    if (increment <= 0) return weight;
    return (weight / increment).round() * increment;
  }

  static double kgToLbs(double kg) {
    return kg * 2.20462;
  }

  static double lbsToKg(double lbs) {
    return lbs / 2.20462;
  }
}
