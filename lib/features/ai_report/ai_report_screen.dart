import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:ironlog/core/constants/app_constants.dart';
import 'package:ironlog/core/constants/color_constants.dart';
import 'package:ironlog/core/services/sync_service.dart';
import 'package:ironlog/core/database/database_helper.dart';
import 'package:ironlog/shared/widgets/bottom_nav.dart';

final latestReportProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final db = DatabaseHelper();
  final results = await db.query('weekly_summaries', orderBy: 'id DESC', limit: 1);
  if (results.isEmpty) return null;
  final report = results.first['ai_report'] as String?;
  if (report == null) return null;
  return jsonDecode(report) as Map<String, dynamic>;
});

class AIReportScreen extends ConsumerWidget {
  const AIReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(latestReportProvider);
    final syncService = SyncService(DatabaseHelper.instance, Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl)));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection status
              FutureBuilder(
                future: syncService.isOnline(),
                builder: (ctx, AsyncSnapshot<bool> snap) {
                  final online = snap.data ?? false;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: online ? AppColors.success.withValues(alpha: 0.1) : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(online ? Icons.sync : Icons.wifi_off, color: online ? AppColors.success : AppColors.grey, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          online ? 'Syncing your journey...' : 'AI Report available when online',
                          style: TextStyle(color: online ? AppColors.success : AppColors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Week summary card
              reportAsync.when(
                data: (report) {
                  if (report == null) return _emptyState();
                  final summary = report['week_summary'] as Map<String, dynamic>?;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text('WEEK OF ${_getCurrentWeekLabel()}', style: const TextStyle(color: AppColors.grey, fontSize: 12, letterSpacing: 1)),
                            const SizedBox(height: 12),
                            if (summary != null) ...[
                              Text(summary['sessions_quality'] as String? ?? '',
                                style: const TextStyle(color: AppColors.success, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Strongest: ${summary['strongest_muscle'] ?? 'N/A'}',
                                style: const TextStyle(color: AppColors.primaryLight, fontSize: 14)),
                              Text('Needs attention: ${summary['needs_attention'] ?? 'N/A'}',
                                style: const TextStyle(color: AppColors.warning, fontSize: 14)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Insights
                      const Text('AI INSIGHTS', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      ...((report['insights'] as List<dynamic>?) ?? []).map((insight) {
                        final i = insight as Map<String, dynamic>;
                        return _InsightCard(
                          icon: i['icon'] as String? ?? '\u{1F4A1}',
                          title: i['title'] as String? ?? '',
                          description: i['description'] as String? ?? '',
                          type: i['type'] as String? ?? 'suggestion',
                        );
                      }),

                      const SizedBox(height: 20),

                      // Muscle balance
                      const Text('MUSCLE BALANCE', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      ...((report['muscle_scores'] as Map<String, dynamic>?) ?? {}).entries.map((e) {
                        final score = (e.value as num).toDouble();
                        return _MuscleBalanceRow(muscle: e.key, percentage: score.toInt());
                      }),

                      const SizedBox(height: 20),

                      // Next week focus
                      const Text('NEXT WEEK FOCUS', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Based on your progress:', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            ...((report['next_week_focus'] as List<dynamic>?) ?? []).map((r) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('\u{2022} ', style: TextStyle(color: AppColors.primary)),
                                  Expanded(child: Text(r as String? ?? '', style: const TextStyle(color: AppColors.white, fontSize: 13))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Progressive overload suggestions
                      ...((report['progressive_overload'] as List<dynamic>?) ?? []).map((po) {
                        final p = po as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up, color: AppColors.success, size: 18),
                              const SizedBox(width: 8),
                              Text('${p['exercise'] ?? ''}: ${p['current'] ?? ''} \u{2192} ${p['suggested'] ?? ''}',
                                style: const TextStyle(color: AppColors.white, fontSize: 13)),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => _emptyState(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            const Icon(Icons.psychology, color: AppColors.grey, size: 64),
            const SizedBox(height: 16),
            const Text('No AI Report Yet', style: TextStyle(color: AppColors.white, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Complete workouts and connect to internet\nto get your personalized AI analysis.',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  String _getCurrentWeekLabel() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${monday.month}/${monday.day} - ${sunday.month}/${sunday.day}';
  }
}

class _InsightCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final String type;

  const _InsightCard({required this.icon, required this.title, required this.description, required this.type});

  Color get _borderColor {
    switch (type) {
      case 'positive': return AppColors.success;
      case 'warning': return AppColors.warning;
      default: return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: _borderColor, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleBalanceRow extends StatelessWidget {
  final String muscle;
  final int percentage;

  const _MuscleBalanceRow({required this.muscle, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(muscle[0].toUpperCase() + muscle.substring(1),
            style: const TextStyle(color: AppColors.white, fontSize: 13))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(
                  percentage >= 70 ? AppColors.primary :
                  percentage >= 50 ? AppColors.warning : AppColors.error,
                ),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 36),
          Text('$percentage%', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          if (percentage < 60)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.warning_amber, color: AppColors.warning, size: 14),
            ),
        ],
      ),
    );
  }
}
