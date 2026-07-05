import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:ironlog/core/constants/color_constants.dart';
import 'package:ironlog/features/home/home_provider.dart';
import 'package:ironlog/core/utils/rm_calculator.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final int exerciseId;
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  Map<String, dynamic>? _exercise;
  List<Map<String, dynamic>> _personalRecords = [];
  double? _recommendedStartWeight;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = ref.read(databaseProvider);
    final exercise = await db.getById('exercises', widget.exerciseId);
    final dayExercises = await db.query('day_exercises',
      where: 'exercise_id = ?', whereArgs: [widget.exerciseId], limit: 1);
    final prs = await db.query('personal_records',
      where: 'exercise_id = ?', whereArgs: [widget.exerciseId],
      orderBy: 'date DESC', limit: 10);

    if (mounted) {
      setState(() {
        _exercise = exercise?.cast<String, dynamic>();
        _recommendedStartWeight = dayExercises.isNotEmpty
            ? (dayExercises.first['recommended_start_weight'] as num?)?.toDouble()
            : null;
        _personalRecords = prs.cast<Map<String, dynamic>>();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_exercise == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('Exercise not found', style: TextStyle(color: Colors.white))),
      );
    }

    final ex = _exercise!;
    final name = ex['name'] as String;
    final musclePrimary = ex['muscle_primary'] as String;
    final muscleSecondary = ex['muscle_secondary'] as String? ?? '';
    final equipment = ex['equipment'] as String;
    final exerciseType = ex['exercise_type'] as String;
    final animationAsset = ex['animation_asset'] as String;
    final formCues = (ex['form_cues'] as String?)?.split('|') ?? <String>[];
    final commonMistakes = (ex['common_mistakes'] as String?)?.split('|') ?? <String>[];
    final breathingCue = ex['breathing_cue'] as String?;
    final defaultRestSeconds = (ex['default_rest_seconds'] as num?)?.toInt() ?? 90;
    final isCompound = (ex['is_compound'] as int?) == 1;
    final defaultRpeTarget = (ex['default_rpe_target'] as num?)?.toInt() ?? 7;
    final typeLabel = isCompound ? 'Compound' : 'Isolation';
    final rpeRange = '$defaultRpeTarget-${defaultRpeTarget + 1}';
    final equipmentLabel = equipment.replaceAll('_', ' ').toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: const Color(0xFF2A2A2A),
                child: Center(
                  child: animationAsset.isNotEmpty
                      ? Lottie.asset('assets/$animationAsset', fit: BoxFit.contain)
                      : const Icon(Icons.fitness_center, color: Colors.white38, size: 80),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoCard(label: 'TYPE', value: typeLabel),
                      const SizedBox(width: 8),
                      _InfoCard(label: 'EQUIPMENT', value: equipmentLabel),
                      const SizedBox(width: 8),
                      _InfoCard(label: 'RPE TARGET', value: rpeRange),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('PRIMARY: $musclePrimary', style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                  if (muscleSecondary.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('SECONDARY: $muscleSecondary', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  const SizedBox(height: 20),
                  if (formCues.isNotEmpty && formCues.any((c) => c.trim().isNotEmpty)) ...[
                    const Text('FORM CUES', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    ...formCues.where((c) => c.trim().isNotEmpty).map((cue) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(cue.trim(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],
                  if (commonMistakes.isNotEmpty && commonMistakes.any((m) => m.trim().isNotEmpty)) ...[
                    const Text('COMMON MISTAKES', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    ...commonMistakes.where((m) => m.trim().isNotEmpty).map((mistake) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.cancel, color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(mistake.trim(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],
                  if (breathingCue != null && breathingCue.isNotEmpty) ...[
                    const Text('BREATHING', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.restBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.restBlue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.air, color: AppColors.restBlue, size: 24),
                          const SizedBox(width: 12),
                          Expanded(child: Text(breathingCue, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_recommendedStartWeight != null && _recommendedStartWeight! > 0) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('RECOMMENDED START: ${_recommendedStartWeight!.toStringAsFixed(0)}kg',
                            style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text('REST: $defaultRestSeconds seconds between sets',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_personalRecords.isNotEmpty) ...[
                    const Text('PERSONAL RECORDS', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Text('Date', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
                              const Expanded(child: Text('Weight', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
                              const Expanded(child: Text('Reps', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
                              const Expanded(child: Text('e1RM', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ..._personalRecords.map((pr) {
                            final weight = (pr['weight_kg'] as num).toDouble();
                            final reps = pr['reps'] as int;
                            final e1rm = (pr['estimated_1rm'] as num?)?.toDouble() ?? OneRepMaxCalculator.estimate1RM(weight, reps);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(child: Text(pr['date'] as String? ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                                  Expanded(child: Text(weight.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
                                  Expanded(child: Text('$reps', style: const TextStyle(color: Colors.white, fontSize: 13))),
                                  Expanded(child: Text('${e1rm.toStringAsFixed(1)} kg', style: const TextStyle(color: AppColors.primary, fontSize: 13))),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 9, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
