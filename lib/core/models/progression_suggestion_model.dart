class ProgressionSuggestion {
  final int exerciseId;
  final double currentWeight;
  final double suggestedWeight;
  final String message;

  ProgressionSuggestion({
    required this.exerciseId,
    required this.currentWeight,
    required this.suggestedWeight,
    required this.message,
  });
}
