import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ironlog/core/constants/color_constants.dart';

class WarmupBanner extends StatelessWidget {
  final String warmupSetsJson;
  final double workingWeight;

  const WarmupBanner({super.key, required this.warmupSetsJson, required this.workingWeight});

  @override
  Widget build(BuildContext context) {
    List<dynamic> sets;
    try {
      sets = jsonDecode(warmupSetsJson) as List<dynamic>;
    } catch (_) {
      sets = [];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'WARM UP — Do not log this',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...sets.asMap().entries.map((entry) {
            final i = entry.key + 1;
            final s = entry.value as Map<String, dynamic>;
            final percent = (s['percent'] as num).toDouble();
            final reps = (s['reps'] as num).toInt();
            final weight = (workingWeight * percent).roundToDouble();
            final desc = percent <= 0.5 ? 'Bar speed only' : 'Controlled';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                'Set $i: ${weight.toStringAsFixed(1)}kg × $reps reps (${(percent * 100).toInt()}%) — $desc',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            );
          }),
        ],
      ),
    );
  }
}
