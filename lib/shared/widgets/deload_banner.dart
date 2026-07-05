import 'package:flutter/material.dart';
import 'package:ironlog/core/constants/color_constants.dart';

class DeloadBanner extends StatelessWidget {
  const DeloadBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Text('DELOAD WEEK', style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),
              SizedBox(width: 8),
              Text('🔄', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This week use 60% of your normal weights.',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Deload weeks prevent injury and you\'ll come back STRONGER.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
