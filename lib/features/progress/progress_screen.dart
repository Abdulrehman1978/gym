import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ironlog/core/constants/color_constants.dart';
import 'package:ironlog/features/home/home_provider.dart';
import 'package:ironlog/core/utils/rm_calculator.dart';
import 'package:ironlog/shared/widgets/bottom_nav.dart';

final selectedExerciseForProgressProvider = StateProvider<int>((ref) => 1);
final weekOffsetProvider = StateProvider<int>((ref) => 0);

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _allPRs = [];
  Map<String, dynamic>? _weeklySummary;
  Map<int, double> _dailyVolume = {};
  int _sessionsCompleted = 0;
  double _totalVolume = 0;
  int _prCountThisWeek = 0;
  List<Map<String, dynamic>> _muscleVolume = [];
  List<Map<String, dynamic>> _bodyWeightData = [];
  String? _aiReport;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = ref.read(databaseProvider);
    final database = await db.database;
    final weekOffset = ref.read(weekOffsetProvider);
    final now = DateTime.now();
    final weekStart = now.add(Duration(days: -(now.weekday - 1) + (weekOffset * 7)));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final fmt = (DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final startStr = fmt(weekStart);
    final endStr = fmt(weekEnd);

    final results = await Future.wait([
      db.query('exercises', orderBy: 'name'),
      db.query('personal_records', orderBy: 'date DESC'),
      db.query('weekly_summaries', orderBy: 'id DESC', limit: 1),
      database.rawQuery('''
        SELECT ws.date, COALESCE(SUM(sl.weight_kg * sl.reps), 0) as volume
        FROM set_logs sl
        INNER JOIN workout_sessions ws ON sl.session_id = ws.id
        WHERE ws.date >= ? AND ws.date <= ? AND ws.completed = 1
        GROUP BY ws.date
      ''', [startStr, endStr]),
      database.rawQuery('''
        SELECT e.muscle_primary, COALESCE(SUM(sl.weight_kg * sl.reps), 0) as volume
        FROM set_logs sl
        INNER JOIN workout_sessions ws ON sl.session_id = ws.id
        INNER JOIN exercises e ON sl.exercise_id = e.id
        WHERE ws.date >= ? AND ws.date <= ? AND ws.completed = 1
        GROUP BY e.muscle_primary
        ORDER BY volume DESC
      ''', [startStr, endStr]),
      db.query('body_weight_log', orderBy: 'date ASC'),
      db.getCount('workout_sessions',
        where: 'date >= ? AND date <= ? AND completed = 1',
        whereArgs: [startStr, endStr]),
      database.rawQuery('''
        SELECT COALESCE(SUM(sl.weight_kg * sl.reps), 0) as volume
        FROM set_logs sl
        INNER JOIN workout_sessions ws ON sl.session_id = ws.id
        WHERE ws.date >= ? AND ws.date <= ? AND ws.completed = 1
      ''', [startStr, endStr]),
    ]);

    final exercises = (results[0] as List<Map<String, dynamic>>).cast<Map<String, dynamic>>();
    final allPRs = (results[1] as List<Map<String, dynamic>>).cast<Map<String, dynamic>>();
    final weeklySummaries = (results[2] as List<Map<String, dynamic>>).cast<Map<String, dynamic>>();
    final dailyVolumeRaw = (results[3] as List<Map<String, dynamic>>).cast<Map<String, dynamic>>();
    final muscleVolumeRaw = (results[4] as List<Map<String, dynamic>>).cast<Map<String, dynamic>>();
    final bodyWeightRaw = (results[5] as List<Map<String, dynamic>>).cast<Map<String, dynamic>>();
    final sessionsCount = results[6] as int;
    final totalVolumeRaw = (results[7] as List<Map<String, dynamic>>);

    final dailyVolumeMap = <int, double>{};
    for (int i = 1; i <= 6; i++) {
      dailyVolumeMap[i] = 0;
    }
    for (final row in dailyVolumeRaw) {
      final dateStr = row['date'] as String;
      final date = DateTime.tryParse(dateStr);
      if (date != null && date.weekday >= 1 && date.weekday <= 6) {
        dailyVolumeMap[date.weekday] = (row['volume'] as num).toDouble();
      }
    }

    final prsThisWeek = allPRs.where((pr) {
      final prDate = pr['date'] as String? ?? '';
      return prDate.compareTo(startStr) >= 0 && prDate.compareTo(endStr) <= 0;
    }).length;

    final totalVol = totalVolumeRaw.isNotEmpty ? (totalVolumeRaw.first['volume'] as num).toDouble() : 0.0;

    final aiReport = weeklySummaries.isNotEmpty
        ? weeklySummaries.first['ai_report'] as String?
        : null;

    if (mounted) {
      setState(() {
        _exercises = exercises;
        _allPRs = allPRs;
        _weeklySummary = weeklySummaries.isNotEmpty ? weeklySummaries.first : null;
        _dailyVolume = dailyVolumeMap;
        _sessionsCompleted = sessionsCount;
        _totalVolume = totalVol;
        _prCountThisWeek = prsThisWeek;
        _muscleVolume = muscleVolumeRaw;
        _bodyWeightData = bodyWeightRaw;
        _aiReport = aiReport;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekOffset = ref.watch(weekOffsetProvider);
    final now = DateTime.now();
    final weekStart = now.add(Duration(days: -(now.weekday - 1) + (weekOffset * 7)));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final startLabel = '${_monthAbbr(weekStart.month)} ${weekStart.day}';
    final endLabel = '${_monthAbbr(weekEnd.month)} ${weekEnd.day}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MY PROGRESS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                          onPressed: () {
                            ref.read(weekOffsetProvider.notifier).state = weekOffset - 1;
                            _loadData();
                          },
                        ),
                        Text('$startLabel - $endLabel', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                          onPressed: () {
                            ref.read(weekOffsetProvider.notifier).state = weekOffset + 1;
                            _loadData();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(label: 'Sessions', value: '$_sessionsCompleted/6'),
                        const SizedBox(width: 8),
                        _StatCard(label: 'Volume', value: '${_formatVolume(_totalVolume)} kg'),
                        const SizedBox(width: 8),
                        _StatCard(label: 'PRs', value: '$_prCountThisWeek this week'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('VOLUME THIS WEEK', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _dailyVolume.values.fold(0.0, (a, b) => a > b ? a : b) * 1.2,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                                  return Text(days[v.toInt()], style: const TextStyle(color: AppColors.textSecondary, fontSize: 10));
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFF2A2A2A), strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _dailyVolume.entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value,
                                  color: AppColors.primary,
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('STRENGTH PROGRESSION', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    _buildStrengthProgression(),
                    const SizedBox(height: 20),
                    const Text('MUSCLE VOLUME BREAKDOWN', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    _buildMuscleVolume(),
                    const SizedBox(height: 20),
                    if (_bodyWeightData.isNotEmpty) ...[
                      const Text('BODY WEIGHT', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      _buildBodyWeightChart(),
                      const SizedBox(height: 20),
                    ],
                    const Text('AI REPORT CARD', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    _buildAIReportCard(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 3, onTap: (i) {}),
    );
  }

  Widget _buildStrengthProgression() {
    final selectedId = ref.watch(selectedExerciseForProgressProvider);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _exercises.any((e) => e['id'] == selectedId) ? selectedId : (_exercises.isNotEmpty ? _exercises.first['id'] as int : 1),
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: Colors.white),
              items: _exercises.map((e) => DropdownMenuItem(
                value: e['id'] as int,
                child: Text(e['name'] as String, style: const TextStyle(color: Colors.white)),
              )).toList(),
              onChanged: (v) {
                if (v != null) {
                  ref.read(selectedExerciseForProgressProvider.notifier).state = v;
                  setState(() {});
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder(
          future: ref.read(workoutServiceProvider).getStrengthProgress(selectedId),
          builder: (ctx, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
            if (!snap.hasData || snap.data!.isEmpty) {
              return Container(
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('No data yet', style: TextStyle(color: AppColors.textMuted))),
              );
            }
            final data = snap.data!.reversed.toList();
            final spots = data.asMap().entries.map((e) {
              final weight = (e.value['max_weight'] as num).toDouble();
              final reps = (e.value['max_reps'] as num).toInt();
              final e1rm = OneRepMaxCalculator.estimate1RM(weight, reps);
              return FlSpot(e.key.toDouble(), e1rm);
            }).toList();

            return Container(
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, _) => Text('${v.toInt()}kg', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < data.length) {
                            final dateStr = data[idx]['date'] as String? ?? '';
                            return Text(dateStr.length >= 5 ? dateStr.substring(5) : dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 8));
                          }
                          return const Text('', style: TextStyle(fontSize: 8));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFF2A2A2A), strokeWidth: 1),
                    getDrawingVerticalLine: (_) => const FlLine(color: Colors.transparent),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMuscleVolume() {
    if (_muscleVolume.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('No volume data this week', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    final totalMuscleVol = _muscleVolume.fold<double>(0, (sum, m) => sum + (m['volume'] as num).toDouble());
    final colors = [AppColors.primary, AppColors.restBlue, AppColors.success, AppColors.accent, AppColors.warning, AppColors.error];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: _muscleVolume.asMap().entries.map((e) {
                  final i = e.key;
                  final m = e.value;
                  final vol = (m['volume'] as num).toDouble();
                  final pct = totalMuscleVol > 0 ? vol / totalMuscleVol : 0.0;
                  return PieChartSectionData(
                    color: colors[i % colors.length],
                    value: pct * 100,
                    title: '${(pct * 100).toStringAsFixed(0)}%',
                    radius: 30,
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._muscleVolume.asMap().entries.map((e) {
            final i = e.key;
            final m = e.value;
            final vol = (m['volume'] as num).toDouble();
            final pct = totalMuscleVol > 0 ? vol / totalMuscleVol : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(m['muscle_primary'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                  Text('${vol.toStringAsFixed(0)} kg', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('(${(pct * 100).toStringAsFixed(0)}%)', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBodyWeightChart() {
    if (_bodyWeightData.length < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('Not enough data points', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    final spots = _bodyWeightData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['weight_kg'] as num).toDouble());
    }).toList();

    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.accent,
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: AppColors.accent.withValues(alpha: 0.1)),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text('${v.toInt()}kg', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _bodyWeightData.length > 10 ? (_bodyWeightData.length / 5).ceilToDouble() : 1,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx >= 0 && idx < _bodyWeightData.length) {
                    final dateStr = _bodyWeightData[idx]['date'] as String? ?? '';
                    return Text(dateStr.length >= 5 ? dateStr.substring(5) : dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 8));
                  }
                  return const Text('', style: TextStyle(fontSize: 8));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFF2A2A2A), strokeWidth: 1),
            getDrawingVerticalLine: (_) => const FlLine(color: Colors.transparent),
          ),
        ),
      ),
    );
  }

  Widget _buildAIReportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('AI ANALYSIS', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _aiReport != null && _aiReport!.isNotEmpty
                ? 'Your last AI analysis is available for review.'
                : 'Complete workouts and sync to get your personalized AI analysis.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/ai-report'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('VIEW FULL REPORT'),
            ),
          ),
        ],
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatVolume(double vol) {
    if (vol >= 1000) {
      return '${(vol / 1000).toStringAsFixed(1)}k';
    }
    return vol.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
