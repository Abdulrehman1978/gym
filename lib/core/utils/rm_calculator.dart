class OneRepMaxCalculator {
  static double epleyFormula(double weight, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }

  static double brzyckiFormula(double weight, int reps) {
    if (reps <= 0) return 0;
    if (reps >= 37) return weight;
    return weight * (36 / (37 - reps));
  }

  static double estimate1RM(double weight, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    if (reps < 10) {
      return epleyFormula(weight, reps);
    }
    return brzyckiFormula(weight, reps);
  }

  static double estimateMaxWeight(double weight, int reps) {
    return estimate1RM(weight, reps);
  }
}
