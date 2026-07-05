import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ironlog/core/constants/color_constants.dart';
import 'package:ironlog/core/models/personal_record_model.dart';
import 'package:ironlog/features/home/home_provider.dart';
import 'package:ironlog/features/workout/workout_provider.dart';
import 'package:ironlog/shared/widgets/deload_banner.dart';
import 'package:ironlog/shared/widgets/pr_celebration.dart';
import 'package:ironlog/shared/widgets/rest_timer.dart';
import 'package:ironlog/shared/widgets/warmup_banner.dart';

class _SetEntry {
  String weight;
  String reps;
  bool completed;
  int? rpe;
  int? formRating;

  _SetEntry({this.weight = '', this.reps = '', this.completed = false});
}

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final int workoutDayId;
  final String date;
  final bool isDeloadWeek;

  const ActiveWorkoutScreen({
    super.key,
    required this.workoutDayId,
    required this.date,
    this.isDeloadWeek = false,
  });

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  late PageController _pageController;
  final Map<String, _SetEntry> _entries = {};
  PersonalRecord? _lastPR;
  int _currentPage = 0;
  int _numExtraSets = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutProvider.notifier).startWorkout(
        widget.workoutDayId,
        widget.date,
        widget.isDeloadWeek,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _entryKey(int exerciseIndex, int setNumber) => '$exerciseIndex-$setNumber';

  _SetEntry _entry(int exerciseIndex, int setNumber) {
    return _entries.putIfAbsent(_entryKey(exerciseIndex, setNumber), () => _SetEntry());
  }

  Future<void> _logSet(int exerciseIndex, int setNumber, int exerciseId, int restSeconds) async {
    final entry = _entry(exerciseIndex, setNumber);
    final weight = double.tryParse(entry.weight);
    final reps = int.tryParse(entry.reps);
    if (weight == null || reps == null || weight <= 0 || reps <= 0) return;

    final notifier = ref.read(workoutProvider.notifier);
    await notifier.logSet(exerciseId, setNumber, weight, reps, rpe: entry.rpe);

    final currentState = ref.read(workoutProvider);
    if (currentState.currentSessionId != null) {
      final prService = ref.read(prServiceProvider);
      final pr = await prService.checkForPR(
        exerciseId, weight, reps, currentState.currentSessionId!,
      );
      if (pr != null && mounted) {
        setState(() => _lastPR = pr);
      }
    }

    setState(() {
      entry.completed = true;
    });

    notifier.startRest(restSeconds);
  }

  void _addExtraSet() {
    setState(() => _numExtraSets++);
  }

  void _previousExercise() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _numExtraSets = 0;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextExercise(int totalExercises) {
    if (_currentPage + 1 < totalExercises) {
      setState(() {
        _currentPage++;
        _numExtraSets = 0;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishWorkout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('End workout?', style: TextStyle(color: AppColors.white)),
        content: const Text('Progress will be saved.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Going', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _completeWorkout();
            },
            child: const Text('Save & Finish'),
          ),
        ],
      ),
    );
  }

  void _completeWorkout() {
    final state = ref.read(workoutProvider);
    final sessionId = state.currentSessionId;
    if (sessionId == null) return;

    final startedAt = state.session?.startedAt ?? DateTime.now().toIso8601String();
    final started = DateTime.parse(startedAt);
    final duration = DateTime.now().difference(started).inMinutes;

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/workout-complete',
      arguments: {
        'sessionId': sessionId,
        'durationMinutes': duration,
        'date': widget.date,
        'workoutDayId': widget.workoutDayId,
      },
    );
  }

  bool _allSetsLogged(int totalSets) {
    if (totalSets == 0) return false;
    for (int i = 0; i < totalSets; i++) {
      final entry = _entry(_currentPage, i + 1);
      if (!entry.completed) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(dayExercisesProvider(widget.workoutDayId));
    final wState = ref.watch(workoutProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: exercisesAsync.when(
        data: (exercises) {
          if (exercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No exercises for this workout', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
                  ),
                ],
              ),
            );
          }

          final isLastExercise = _currentPage == exercises.length - 1;
          final totalSets = (exercises[_currentPage]['target_sets'] as int) + _numExtraSets;
          final allLogged = _allSetsLogged(totalSets);

          return SafeArea(
            child: Column(
              children: [
                _buildTopBar(exercises.length),
                if (widget.isDeloadWeek)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: DeloadBanner(),
                  ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: exercises.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
                      final exId = ex['exercise_id'] as int;
                      final ts = ex['target_sets'] as int;
                      final restSec = (ex['rest_seconds'] as num?)?.toInt() ?? (ex['default_rest_seconds'] as num?)?.toInt() ?? 90;
                      final hasWarm = (ex['has_warmup'] as int?) == 1;
                      final warmJson = ex['warmup_sets_json'] as String?;
                      final rpeTgt = ex['default_rpe_target'] as int? ?? 7;
                      final startWt = (ex['recommended_start_weight'] as num?)?.toDouble();
                      final repsMin = ex['target_reps_min'] as int;
                      final repsMax = ex['target_reps_max'] as int;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex['name'] as String? ?? '',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ex['muscle_primary'] as String? ?? '',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _infoChip('Target', '$ts \u00D7 $repsMin-$repsMax'),
                                const SizedBox(width: 12),
                                _infoChip('Rest', '${restSec}s'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (startWt != null)
                                  _infoChip('Start', '${startWt.toStringAsFixed(0)}kg'),
                                if (startWt != null) const SizedBox(width: 12),
                                _infoChip('RPE Target', '$rpeTgt'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (hasWarm && warmJson != null && startWt != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: WarmupBanner(
                                  warmupSetsJson: warmJson,
                                  workingWeight: startWt,
                                ),
                              ),
                            ...List.generate(ts + _numExtraSets, (i) {
                              return _buildSetRow(i + 1, exId, restSec);
                            }),
                            if (_lastPR != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: PRCelebration(
                                  exerciseName: ex['name'] as String? ?? '',
                                  weight: _lastPR!.weightKg,
                                  reps: _lastPR!.reps,
                                ),
                              ),
                            if (_allSetsLogged(ts))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _addExtraSet,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('+ Add Set'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                            if (wState.isResting)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: RestTimer(
                                  secondsRemaining: wState.restSecondsRemaining,
                                  onSkip: () => ref.read(workoutProvider.notifier).skipRest(),
                                ),
                              ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomNav(exercises.length, isLastExercise, allLogged),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }

  Widget _buildTopBar(int totalExercises) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: _finishWorkout,
          ),
          const Spacer(),
          Text(
            '${_currentPage + 1} / $totalExercises',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBottomNav(int totalExercises, bool isLastExercise, bool allLogged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceLight)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousExercise,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.surfaceLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            child: isLastExercise
                ? ElevatedButton(
                    onPressed: allLogged ? _finishWorkout : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Finish Workout', style: TextStyle(fontSize: 14)),
                  )
                : ElevatedButton(
                    onPressed: allLogged ? () => _nextExercise(totalExercises) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      allLogged ? 'Next Exercise \u2192' : 'Complete Sets',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSetRow(int setNumber, int exerciseId, int restSeconds) {
    final entry = _entry(_currentPage, setNumber);

    final hasPrev = setNumber > 1;
    final prevEntry = hasPrev ? _entry(_currentPage, setNumber - 1) : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: entry.completed ? AppColors.surfaceLight.withAlpha(80) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.completed ? AppColors.success.withAlpha(80) : AppColors.surfaceLight,
          width: entry.completed ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '$setNumber',
                  style: TextStyle(
                    color: entry.completed ? AppColors.success : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (hasPrev && prevEntry!.completed && !entry.completed)
                Text(
                  'Prev: ${prevEntry.weight}kg \u00D7 ${prevEntry.reps}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              if (hasPrev && prevEntry!.completed && !entry.completed) const Spacer(),
              if (!entry.completed) ...[
                const Spacer(),
                SizedBox(
                  width: 72,
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'kg',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (v) => entry.weight = v,
                  ),
                ),
                const Text('\u00D7', style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
                SizedBox(
                  width: 60,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'reps',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (v) => entry.reps = v,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _logSet(_currentPage, setNumber, exerciseId, restSeconds),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check, color: AppColors.white, size: 20),
                  ),
                ),
              ],
              if (entry.completed) ...[
                const Spacer(),
                Text(
                  '${entry.weight}kg \u00D7 ${entry.reps}',
                  style: const TextStyle(color: AppColors.success, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: AppColors.success, size: 22),
              ],
            ],
          ),
          if (entry.completed) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _RpeRow(
                  selected: entry.rpe,
                  onSelect: (rpe) => setState(() => entry.rpe = rpe),
                ),
                const SizedBox(width: 12),
                _FormRatingRow(
                  selected: entry.formRating,
                  onSelect: (r) => setState(() => entry.formRating = r),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RpeRow extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;

  const _RpeRow({required this.selected, required this.onSelect});

  static const _options = [
    (emoji: '\u{1F610}', label: '6', value: 6),
    (emoji: '\u{1F4AA}', label: '7', value: 7),
    (emoji: '\u{1F9E0}', label: '8', value: 8),
    (emoji: '\u{1F624}', label: '9', value: 9),
    (emoji: '\u{1F480}', label: '10', value: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _options.map((opt) {
        final isSelected = selected == opt.value;
        return GestureDetector(
          onTap: () => onSelect(opt.value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withAlpha(40) : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(opt.emoji, style: const TextStyle(fontSize: 16)),
                Text(opt.label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FormRatingRow extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;

  const _FormRatingRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final val = i + 1;
        final isSelected = selected == val;
        return GestureDetector(
          onTap: () => onSelect(val),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withAlpha(40) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              val <= (selected ?? 0) ? Icons.star : Icons.star_border,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
              size: 18,
            ),
          ),
        );
      }),
    );
  }
}
