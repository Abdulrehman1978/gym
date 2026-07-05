import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ironlog/core/constants/color_constants.dart';
import 'package:ironlog/features/home/home_provider.dart';
import 'package:ironlog/shared/widgets/bottom_nav.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedMuscleProvider = StateProvider<String>((ref) => 'All');

const List<String> muscleGroups = [
  'All', 'Chest', 'Upper Chest', 'Lower Chest', 'Side Delts', 'Front Delts',
  'Triceps', 'Lats', 'Mid Back', 'Full Back', 'Biceps', 'Brachialis',
  'Forearms', 'Quads', 'Hamstrings', 'Lower Abs', 'Obliques',
];

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  List<Map<String, dynamic>> _allExercises = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadExercises());
  }

  Future<void> _loadExercises() async {
    try {
      final db = ref.read(databaseProvider);
      final exercises = await db.query('exercises', orderBy: 'name');
      if (mounted) {
        setState(() {
          _allExercises = exercises.cast<Map<String, dynamic>>();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedMuscle = ref.watch(selectedMuscleProvider);

    final filtered = _allExercises.where((e) {
      final matchesSearch = searchQuery.isEmpty ||
          (e['name'] as String).toLowerCase().contains(searchQuery.toLowerCase());
      final matchesMuscle = selectedMuscle == 'All' ||
          (e['muscle_primary'] as String) == selectedMuscle;
      return matchesSearch && matchesMuscle;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('EXERCISE LIBRARY', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: muscleGroups.map((muscle) {
                  final isSelected = selectedMuscle == muscle;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(muscle, style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                      )),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                        width: 1,
                      ),
                      onSelected: (_) => ref.read(selectedMuscleProvider.notifier).state = muscle,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      shape: StadiumBorder(side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                      )),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            if (_loading) ...[
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('${filtered.length} exercises', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final ex = filtered[i];
                    final name = ex['name'] as String;
                    final musclePrimary = ex['muscle_primary'] as String;
                    final equipment = ex['equipment'] as String;
                    final exerciseType = ex['exercise_type'] as String;
                    final animationAsset = ex['animation_asset'] as String;
                    final exerciseId = ex['id'] as int;
                    final isCompound = (ex['is_compound'] as int?) == 1;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/exercise-detail', arguments: exerciseId),
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: animationAsset.isNotEmpty
                                    ? null
                                    : const Icon(Icons.fitness_center, color: Colors.white38, size: 28),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text('$musclePrimary \u{2022} ${equipment.replaceAll('_', ' ')}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(
                              isCompound ? Icons.compare_arrows : Icons.fitness_center,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}
