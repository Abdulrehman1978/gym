class Exercise {
  final int? id;
  final String name;
  final String musclePrimary;
  final String? muscleSecondary;
  final String equipment;
  final String animationAsset;
  final String exerciseType;
  final String formCues;
  final String commonMistakes;
  final String? breathingCue;
  final int defaultRestSeconds;
  final bool isCompound;
  final int defaultRpeTarget;

  Exercise({
    this.id,
    required this.name,
    required this.musclePrimary,
    this.muscleSecondary,
    required this.equipment,
    required this.animationAsset,
    required this.exerciseType,
    required this.formCues,
    required this.commonMistakes,
    this.breathingCue,
    this.defaultRestSeconds = 90,
    this.isCompound = false,
    this.defaultRpeTarget = 7,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      name: map['name'] as String,
      musclePrimary: map['musclePrimary'] as String,
      muscleSecondary: map['muscleSecondary'] as String?,
      equipment: map['equipment'] as String,
      animationAsset: map['animationAsset'] as String,
      exerciseType: map['exerciseType'] as String,
      formCues: map['formCues'] as String,
      commonMistakes: map['commonMistakes'] as String,
      breathingCue: map['breathingCue'] as String?,
      defaultRestSeconds: (map['defaultRestSeconds'] as num?)?.toInt() ?? 90,
      isCompound: (map['isCompound'] as int? ?? 0) == 1,
      defaultRpeTarget: (map['defaultRpeTarget'] as num?)?.toInt() ?? 7,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'musclePrimary': musclePrimary,
      'muscleSecondary': muscleSecondary,
      'equipment': equipment,
      'animationAsset': animationAsset,
      'exerciseType': exerciseType,
      'formCues': formCues,
      'commonMistakes': commonMistakes,
      'breathingCue': breathingCue,
      'defaultRestSeconds': defaultRestSeconds,
      'isCompound': isCompound ? 1 : 0,
      'defaultRpeTarget': defaultRpeTarget,
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? musclePrimary,
    String? muscleSecondary,
    String? equipment,
    String? animationAsset,
    String? exerciseType,
    String? formCues,
    String? commonMistakes,
    String? breathingCue,
    int? defaultRestSeconds,
    bool? isCompound,
    int? defaultRpeTarget,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      musclePrimary: musclePrimary ?? this.musclePrimary,
      muscleSecondary: muscleSecondary ?? this.muscleSecondary,
      equipment: equipment ?? this.equipment,
      animationAsset: animationAsset ?? this.animationAsset,
      exerciseType: exerciseType ?? this.exerciseType,
      formCues: formCues ?? this.formCues,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      breathingCue: breathingCue ?? this.breathingCue,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      isCompound: isCompound ?? this.isCompound,
      defaultRpeTarget: defaultRpeTarget ?? this.defaultRpeTarget,
    );
  }
}
