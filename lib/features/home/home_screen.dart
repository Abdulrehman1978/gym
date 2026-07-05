import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ironlog/core/constants/color_constants.dart';
import 'package:ironlog/core/services/recovery_service.dart';
import 'package:ironlog/features/home/home_provider.dart';
import 'package:ironlog/shared/widgets/bottom_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, dynamic>? _todayWorkout;
  bool _isLoadingToday = true;
  final Map<String, RecoveryStatus> _recovery = {};
  final List<String> _recoveryGroups = ['Chest', 'Lats', 'Quads'];
  final Map<String, String> _recoveryLabels = {
    'Chest': 'Chest',
    'Lats': 'Back',
    'Quads': 'Legs',
  };
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    // Defer until after the first frame — Riverpod forbids modifying
    // a StateNotifier during the widget mount/build phase (initState).
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    ref.read(homeProvider.notifier).loadDashboard();

    final today = await ref.read(homeProvider.notifier).getTodaysWorkoutDay();

    for (final group in _recoveryGroups) {
      final status = await ref.read(recoveryServiceProvider).checkMuscleRecovery(group);
      _recovery[group] = status;
    }

    if (mounted) {
      setState(() {
        _todayWorkout = today;
        _isLoadingToday = false;
      });
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  bool _isTodayCompleted(HomeState state) {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    return state.recentSessions.any((s) => s.date == todayStr);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

    final dayNames = ['', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    final todayWeekday = DateTime.now().weekday;
    final todayName = todayWeekday >= 1 && todayWeekday <= 6 ? dayNames[todayWeekday] : 'REST DAY';

    final hasWorkoutToday = _todayWorkout != null;
    final workoutType = _todayWorkout?['type'] as String? ?? '';
    final workoutLabel = _todayWorkout?['label'] as String? ?? '';
    final completed = _isTodayCompleted(state);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'IronLog',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          StreamBuilder<List<ConnectivityResult>>(
            stream: _connectivity.onConnectivityChanged,
            builder: (context, snapshot) {
              final results = snapshot.data ?? [ConnectivityResult.none];
              final isOnline = !results.contains(ConnectivityResult.none);
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? AppColors.success : AppColors.textMuted,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading || _isLoadingToday
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : state.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Something went wrong.\nPull down to retry.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_greeting, Iron Warrior!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _TodayWorkoutCard(
                            dayName: todayName,
                            workoutType: workoutType,
                            workoutLabel: workoutLabel,
                            hasWorkout: hasWorkoutToday,
                            completed: completed,
                            onStartWorkout: () => Navigator.pushNamed(
                              context, '/workout',
                              arguments: _todayWorkout?['id'] as int? ?? todayWeekday,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _StatsRow(state: state),
                          if (_recovery.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _RecoverySection(
                              recovery: _recovery,
                              labels: _recoveryLabels,
                            ),
                          ],
                          const SizedBox(height: 20),
                          _QuickActions(
                            onLibrary: () => Navigator.pushNamed(context, '/library'),
                            onProgress: () => Navigator.pushNamed(context, '/progress'),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  final String dayName;
  final String workoutType;
  final String workoutLabel;
  final bool hasWorkout;
  final bool completed;
  final VoidCallback onStartWorkout;

  const _TodayWorkoutCard({
    required this.dayName,
    required this.workoutType,
    required this.workoutLabel,
    required this.hasWorkout,
    required this.completed,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayName,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasWorkout ? '$workoutType DAY' : 'REST DAY',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (completed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (hasWorkout && workoutLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              workoutLabel,
              style: const TextStyle(color: AppColors.primaryLight, fontSize: 13),
            ),
          ],
          if (hasWorkout && !completed) ...[
            const SizedBox(height: 4),
            Text(
              'exercises ready',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          if (hasWorkout && !completed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStartWorkout,
                child: const Text('START WORKOUT \u2192'),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final HomeState state;

  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            emoji: '\u{1F525}',
            value: '${state.currentStreak}',
            label: 'Day Streak',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            emoji: '\u{1F4AA}',
            value: '${state.totalVolume.toStringAsFixed(0)}',
            label: 'Total kg',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            emoji: '\u{1F4C5}',
            value: '${state.completedThisWeek}',
            label: 'This Week',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoverySection extends StatelessWidget {
  final Map<String, RecoveryStatus> recovery;
  final Map<String, String> labels;

  const _RecoverySection({
    required this.recovery,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECOVERY STATUS',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: recovery.entries.map((entry) {
              final status = entry.value;
              final displayName = labels[entry.key] ?? entry.key;
              Color statusColor;
              IconData statusIcon;
              switch (status) {
                case RecoveryStatus.fullyRecovered:
                  statusColor = AppColors.success;
                  statusIcon = Icons.check_circle;
                case RecoveryStatus.recovering:
                  statusColor = AppColors.warning;
                  statusIcon = Icons.access_time;
                case RecoveryStatus.needsRest:
                  statusColor = AppColors.error;
                  statusIcon = Icons.error_outline;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onLibrary;
  final VoidCallback onProgress;

  const _QuickActions({
    required this.onLibrary,
    required this.onProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onLibrary,
            icon: const Icon(Icons.menu_book, size: 18),
            label: const Text('Exercise Library'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onProgress,
            icon: const Icon(Icons.trending_up, size: 18),
            label: const Text('View Progress'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
