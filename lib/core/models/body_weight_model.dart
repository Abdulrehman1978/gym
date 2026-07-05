class BodyWeight {
  final int? id;
  final String date;
  final double weightKg;
  final String? notes;

  BodyWeight({
    this.id,
    required this.date,
    required this.weightKg,
    this.notes,
  });

  factory BodyWeight.fromMap(Map<String, dynamic> map) {
    return BodyWeight(
      id: map['id'] as int?,
      date: map['date'] as String,
      weightKg: (map['weightKg'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'weightKg': weightKg,
      'notes': notes,
    };
  }
}
