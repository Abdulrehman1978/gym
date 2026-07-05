import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ironlog/core/constants/color_constants.dart';
import 'package:ironlog/features/home/home_provider.dart';
import 'package:ironlog/features/workout/workout_provider.dart';
import 'package:confetti/confetti.dart';

final _nextExercisesProvider = FutureProvider.family<String, int>((ref, workoutDayId) async {
  final exercises = await ref.watch(dayExercisesProvider(workoutDayId).future);
  return exercises
      .map((e) => e['name'] as String?)
      .where((n) => n != null)
      .cast<String>()
      .take(3)
      .join(' \u00B7 ');
});

class WorkoutCompleteScreen extends ConsumerStatefulWidget {
  final int sessionId;
  final int durationMinutes;
  final String date;
  final int workoutDayId;

  const WorkoutCompleteScreen({
    super.key,
    required this.sessionId,
    required this.durationMinutes,
    required this.date,
    required this.workoutDayId,
  });

  @override
  ConsumerState<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends ConsumerState<WorkoutCompleteScreen> {
  late ConfettiController _confettiController;
  int? _selectedMood;
  final TextEditingController _notesController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final service = ref.read(workoutServiceProvider);
      await service.completeWorkout(
        widget.sessionId,
        widget.durationMinutes,
        _selectedMood ?? 3,
        _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayAsync = ref.watch(workoutDayProvider(widget.workoutDayId));
    final setsAsync = ref.watch(sessionSetsProvider(widget.sessionId));
    final volumeAsync = ref.watch(sessionVolumeProvider(widget.sessionId));
    final prsAsync = ref.watch(sessionPRsProvider(widget.sessionId));
    final nextDayAsync = ref.watch(nextWorkoutDayProvider(widget.workoutDayId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: AppColors.white, size: 60),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'WORKOUT COMPLETE!',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  dayAsync.when(
                    data: (day) {
                      if (day == null) return const SizedBox();
                      return Text(
                        '${day['day_name'] as String? ?? ''} \u2014 ${day['workout_label'] as String? ?? ''}',
                        style: const TextStyle(color: AppColors.primary, fontSize: 16),
                      );
                    },
                    loading: () => const SizedBox(height: 16),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text('Duration', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.durationMinutes} min',
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: volumeAsync.when(
                            data: (vol) => Column(
                              children: [
                                const Text('Volume', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  '${vol.toStringAsFixed(0)} kg',
                                  style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            loading: () => const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                            error: (_, __) => Column(
                              children: [
                                const Text('Volume', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                const SizedBox(height: 4),
                                const Text('0 kg', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: setsAsync.when(
                            data: (sets) => Column(
                              children: [
                                const Text('Sets', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  '${sets.length}',
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            loading: () => const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                            error: (_, __) => Column(
                              children: [
                                const Text('Sets', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                const SizedBox(height: 4),
                                const Text('0', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  prsAsync.when(
                    data: (prs) {
                      if (prs.isEmpty) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gold, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text('\u{1F3C6}', style: TextStyle(fontSize: 20)),
                                  SizedBox(width: 8),
                                  Text(
                                    'NEW PERSONAL RECORDS',
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...prs.map((pr) {
                                final name = pr['exercise_name'] as String? ?? 'Exercise';
                                final weight = (pr['weight_kg'] as num).toDouble();
                                final reps = pr['reps'] as int;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    '$name: ${weight.toStringAsFixed(0)}kg \u00D7 $reps',
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'How did the workout feel?',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _moodButton(1, '\u{1F480}', 'Brutal'),
                      _moodButton(2, '\u{1F614}', 'Tough'),
                      _moodButton(3, '\u{1F610}', 'OK'),
                      _moodButton(4, '\u{1F60A}', 'Good'),
                      _moodButton(5, '\u{1F4AA}', 'Beast'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Any notes? (optional)',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  nextDayAsync.when(
                    data: (nextDay) {
                      if (nextDay == null) return const SizedBox();
                      final nextDayId = nextDay['id'] as int;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NEXT UP:',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${nextDay['day_name'] as String? ?? ''} \u2014 ${nextDay['workout_label'] as String? ?? ''}',
                              style: const TextStyle(color: AppColors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            ref.watch(_nextExercisesProvider(nextDayId)).when(
                              data: (names) => Text(
                                names,
                                style: const TextStyle(color: AppColors.primary, fontSize: 12),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.surfaceLight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                            )
                          : const Text('SAVE & FINISH', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.accent,
                AppColors.gold,
                AppColors.success,
                Colors.white,
              ],
              numberOfParticles: 20,
              maxBlastForce: 10,
              minBlastForce: 5,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodButton(int value, String emoji, String label) {
    final isSelected = _selectedMood == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
